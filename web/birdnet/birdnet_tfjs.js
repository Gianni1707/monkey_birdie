/* Shim TF.js per il riconoscimento BirdNET sul web/PWA.
 * Funzioni globali chiamate dal lato Dart (js_interop):
 *   window.birdnetLoad()           -> Promise<void>
 *   window.birdnetAnalyzeUrl(url)  -> Promise<Float32Array>   (6522 score)
 *
 * Mel-spectrogram via custom layer MelSpecLayerSimple (tf.signal.stft, FFT
 * nativa TF.js). Layer VERBATIM dall'esempio ufficiale BirdNET_v2.4_tfjs.zip.
 *
 * DECODIFICA AUDIO ROBUSTA / SAFARI-PROOF:
 *   sul web `record` (encoder wav) cattura PCM grezzo via AudioWorklet e
 *   produce un WAV 48kHz mono. Qui PARSIAMO il WAV a mano (PCM16) invece di
 *   affidarci a decodeAudioData/AudioContext({sampleRate}), che su iOS Safari
 *   è inaffidabile. Fallback a decodeAudioData solo se il blob non è WAV. */
(function () {
  // ---------- Custom layer ufficiale BirdNET ----------
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

  const MODEL_URL = 'birdnet/model/model.json';
  const WINDOW = 144000;     // 3s @ 48kHz
  const TARGET_RATE = 48000;
  let _model = null;

  async function ensureModel() {
    if (_model) return _model;
    await tf.ready();
    _model = await tf.loadLayersModel(MODEL_URL, { custom_objects: { MelSpecLayerSimple } });
    return _model;
  }

  // ---------- DSP audio robusto (mirror del lato nativo) ----------
  function parseWav(buffer) {
    const bytes = new Uint8Array(buffer);
    const dv = new DataView(buffer);
    const tag = (o) => String.fromCharCode(bytes[o], bytes[o + 1], bytes[o + 2], bytes[o + 3]);
    if (bytes.length < 44 || tag(0) !== 'RIFF' || tag(8) !== 'WAVE') return null;

    let channels = 1, rate = TARGET_RATE, bits = 16, dataOff = -1, dataLen = 0, p = 12;
    while (p + 8 <= bytes.length) {
      const id = tag(p);
      const size = dv.getUint32(p + 4, true);
      const body = p + 8;
      if (id === 'fmt ') {
        channels = dv.getUint16(body + 2, true);
        rate = dv.getUint32(body + 4, true);
        bits = dv.getUint16(body + 14, true);
      } else if (id === 'data') {
        dataOff = body; dataLen = size;
      }
      p = body + size + (size % 2);
    }
    if (dataOff < 0 || bits !== 16) return null; // gestiamo solo PCM16

    const frames = Math.floor(dataLen / (2 * channels));
    const out = new Float32Array(frames);
    let s = dataOff;
    for (let i = 0; i < frames; i++) {
      let acc = 0;
      for (let c = 0; c < channels; c++) { acc += dv.getInt16(s, true) / 32768; s += 2; }
      out[i] = acc / channels;
    }
    return { samples: out, rate };
  }

  function resampleLinear(input, from, to) {
    if (from === to || input.length === 0) return input;
    const ratio = to / from;
    const outLen = Math.round(input.length * ratio);
    const out = new Float32Array(outLen);
    const maxIdx = input.length - 1;
    for (let i = 0; i < outLen; i++) {
      const sp = i / ratio;
      const i0 = Math.floor(sp);
      const i1 = Math.min(i0 + 1, maxIdx);
      const f = sp - i0;
      out[i] = input[i0] * (1 - f) + input[i1] * f;
    }
    return out;
  }

  function bestWindow(s) {
    if (s.length <= WINDOW) { const o = new Float32Array(WINDOW); o.set(s); return o; }
    let bs = 0, be = -1; const hop = WINDOW >> 1;
    for (let st = 0; st + WINDOW <= s.length; st += hop) {
      let e = 0;
      for (let i = st; i < st + WINDOW; i += 16) { const v = s[i]; e += v * v; }
      if (e > be) { be = e; bs = st; }
    }
    return s.subarray(bs, bs + WINDOW);
  }

  // Decode robusto: WAV a mano (Safari-proof) con fallback a decodeAudioData.
  async function decodeTo48kWindow(url) {
    const buf = await (await fetch(url)).arrayBuffer();

    let samples, rate;
    const wav = parseWav(buf);
    if (wav) {
      samples = wav.samples; rate = wav.rate;
    } else {
      const Ctx = window.AudioContext || window.webkitAudioContext;
      const ctx = new Ctx(); // niente sampleRate forzato (iOS Safari lo rifiuta)
      const audioBuf = await new Promise((res, rej) => {
        const p = ctx.decodeAudioData(buf.slice(0), res, rej);
        if (p && p.then) p.then(res, rej); // Safari vecchio: solo callback
      });
      const ch = audioBuf.numberOfChannels, len = audioBuf.length;
      samples = new Float32Array(len);
      for (let c = 0; c < ch; c++) {
        const d = audioBuf.getChannelData(c);
        for (let i = 0; i < len; i++) samples[i] += d[i] / ch;
      }
      rate = audioBuf.sampleRate;
      try { ctx.close(); } catch (_) { /* noop */ }
    }

    return bestWindow(resampleLinear(samples, rate, TARGET_RATE));
  }

  window.birdnetLoad = async function () { await ensureModel(); };

  window.birdnetAnalyzeUrl = async function (url) {
    const model = await ensureModel();
    const samples = await decodeTo48kWindow(url);
    const input = tf.tensor(samples).reshape([1, WINDOW]);
    const pred = model.predict(input);
    const data = await pred.data();
    tf.dispose([input, pred]);
    return new Float32Array(data); // 6522 score (0..1)
  };
})();
