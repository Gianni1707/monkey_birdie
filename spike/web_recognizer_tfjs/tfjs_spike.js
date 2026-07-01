/* Spike di validazione TF.js: modello BirdNET UFFICIALE (LayersModel) in-browser.
 * Il mel-spectrogram è calcolato dal custom layer MelSpecLayerSimple via
 * tf.signal.stft (FFT supportata nativamente da TF.js) — risolve il blocco
 * incontrato con tfjs-tflite.
 *
 * Il MelSpecLayerSimple qui sotto è preso VERBATIM dal main.js ufficiale
 * incluso nello zip BirdNET_v2.4_tfjs.zip (Zenodo 15050749). */

const $ = (id) => document.getElementById(id);
const setStatus = (m) => { $('status').textContent += m + '\n'; console.log(m); };

(function iso() {
  const el = $('iso');
  const v = self.crossOriginIsolated === true;
  el.textContent = v ? 'attiva' : 'assente (non serve per TF.js single-thread)';
})();

// ---- Custom layer ufficiale BirdNET (mel-spectrogram in JS) ----
class MelSpecLayerSimple extends tf.layers.Layer {
  constructor(config) {
    super(config);
    this.sampleRate = config.sampleRate;
    this.specShape = config.specShape;
    this.frameStep = config.frameStep;
    this.frameLength = config.frameLength;
    this.fmin = config.fmin;
    this.fmax = config.fmax;
    this.melFilterbank = tf.tensor2d(config.melFilterbank);
  }
  build(inputShape) {
    this.magScale = this.addWeight(
      'magnitude_scaling', [], 'float32',
      tf.initializers.constant({ value: 1.23 }),
    );
    super.build(inputShape);
  }
  computeOutputShape(inputShape) {
    return [inputShape[0], this.specShape[0], this.specShape[1], 1];
  }
  call(inputs) {
    return tf.tidy(() => {
      inputs = inputs[0];
      const inputList = tf.split(inputs, inputs.shape[0]);
      const specBatch = inputList.map((input) => {
        input = input.squeeze();
        input = tf.sub(input, tf.min(input, -1, true));
        input = tf.div(input, tf.max(input, -1, true).add(0.000001));
        input = tf.sub(input, 0.5);
        input = tf.mul(input, 2.0);
        let spec = tf.signal.stft(input, this.frameLength, this.frameStep, this.frameLength, tf.signal.hannWindow);
        spec = tf.cast(spec, 'float32');
        spec = tf.matMul(spec, this.melFilterbank);
        spec = spec.pow(2.0);
        spec = spec.pow(tf.div(1.0, tf.add(1.0, tf.exp(this.magScale.read()))));
        spec = tf.reverse(spec, -1);
        spec = tf.transpose(spec);
        spec = spec.expandDims(-1);
        return spec;
      });
      return tf.stack(specBatch);
    });
  }
  static get className() { return 'MelSpecLayerSimple'; }
}
tf.serialization.registerClass(MelSpecLayerSimple);

// ---- Caricamento modello + label (una sola volta) ----
let _model = null, _labels = null;
async function getModel() {
  if (_model) return _model;
  await tf.ready();
  setStatus('TF.js backend: ' + tf.getBackend());
  setStatus('Carico il modello (la prima volta può volerci)…');
  const t = performance.now();
  _model = await tf.loadLayersModel('model/model.json', {
    custom_objects: { MelSpecLayerSimple },
  });
  setStatus(`Modello caricato in ${(performance.now() - t).toFixed(0)} ms`);
  _labels = await (await fetch('model/labels.json')).json();
  setStatus(`Label: ${_labels.length}`);
  return _model;
}

async function loadClip48k(url) {
  const ab = await (await fetch(url)).arrayBuffer();
  const ctx = new (window.AudioContext || window.webkitAudioContext)({ sampleRate: 48000 });
  const buf = await ctx.decodeAudioData(ab);
  const data = buf.getChannelData(0);
  const N = 144000;
  const out = new Float32Array(N);
  out.set(data.subarray(0, Math.min(N, data.length)));
  return out;
}

async function run(url, atteso) {
  try {
    $('result').innerHTML = '';
    const model = await getModel();
    const samples = await loadClip48k(url);
    const input = tf.tensor(samples).reshape([1, 144000]);

    const t = performance.now();
    const pred = model.predict(input);
    const probs = await pred.data();
    const dt = performance.now() - t;
    setStatus(`Inferenza: ${dt.toFixed(0)} ms — output: ${probs.length} classi`);

    const top = [...probs.keys()].sort((a, b) => probs[b] - probs[a]).slice(0, 5);
    let html = `<p><b>Clip:</b> ${url}${atteso ? ` — <b>atteso:</b> ${atteso}` : ''} · <b>inferenza:</b> ${dt.toFixed(0)} ms</p>`;
    html += '<table><tr><th>#</th><th>Specie (label)</th><th>score</th></tr>';
    for (const i of top) html += `<tr><td>${i}</td><td>${_labels[i]}</td><td>${probs[i].toFixed(4)}</td></tr>`;
    html += '</table>';
    $('result').innerHTML = html;
    setStatus(`Top-1: ${_labels[top[0]]}  (${probs[top[0]].toFixed(4)})`);
    setStatus('OK ✅');
    tf.dispose([input, pred]);
  } catch (err) {
    setStatus('❌ ERRORE: ' + (err && err.message ? err.message : err));
    console.error(err);
  }
}

window.addEventListener('load', () => {
  $('btnBlackbird').disabled = false;
  $('btnSample').disabled = false;
  $('btnBlackbird').addEventListener('click', () => run('blackbird_3s_48k.wav', 'Eurasian Blackbird / Turdus merula'));
  $('btnSample').addEventListener('click', () => run('sample.wav', '(sample BirdNET)'));
});
