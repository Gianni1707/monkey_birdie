/* Spike di validazione FOTO: AIY Vision Classifier Birds V1 (.tflite) in-browser via tfjs-tflite.
 * Gate prima di cablare l'impl web del riconoscimento immagini:
 *   (1) op supportate (carica + invoke senza abort),
 *   (2) #output == #label,
 *   (3) top-1 sensata su una foto nota,
 *   (4) latenza accettabile (misurala anche su iPhone Safari).
 * Standalone: non dipende dall'app Flutter, non tocca lib/. */

const MODEL_URL = 'model/birds_V1.tflite';
const LABELMAP_URL = 'aiy_birds_labelmap.csv';
// I .wasm/.js del runtime tfjs-tflite stanno in /wasm/ (NON /dist/) del pacchetto.
const WASM_PREFIX = 'https://cdn.jsdelivr.net/npm/@tensorflow/tfjs-tflite@0.0.1-alpha.10/wasm/';
const INPUT_SIZE = 224;

const $ = (id) => document.getElementById(id);
const setStatus = (m) => { $('status').textContent += m + '\n'; console.log(m); };

let _model = null;
let _labels = null; // array indicizzato per logit id (964 = background)

// labelmap CSV: righe "id,name" (header id,name). L'id È l'indice del logit.
function parseLabelmap(text) {
  const arr = [];
  for (const line of text.split('\n')) {
    const t = line.trim();
    if (!t || t.startsWith('id,')) continue;
    const c = t.indexOf(',');
    if (c < 0) continue;
    const id = parseInt(t.slice(0, c), 10);
    const name = t.slice(c + 1);
    if (!Number.isNaN(id)) arr[id] = name;
  }
  return arr;
}

async function load() {
  if (_model) return _model;
  await tf.ready();
  // Il modello gira nel WASM di tfjs-tflite; il backend tfjs serve solo per i tensori.
  // CPU è Safari-proof e sufficiente (input piccolo).
  try { await tf.setBackend('cpu'); } catch (_) {}
  setStatus('tfjs backend: ' + tf.getBackend());

  tflite.setWasmPath(WASM_PREFIX);
  setStatus('Carico il modello…');
  const t = performance.now();
  _model = await tflite.loadTFLiteModel(MODEL_URL);
  setStatus(`Modello caricato in ${(performance.now() - t).toFixed(0)} ms`);

  _labels = parseLabelmap(await (await fetch(LABELMAP_URL)).text());
  setStatus(`Label: ${_labels.length} (id 964 = "${_labels[964] ?? '?'}")`);

  try {
    setStatus('INPUT : ' + JSON.stringify(_model.inputs));
    setStatus('OUTPUT: ' + JSON.stringify(_model.outputs));
  } catch (_) {}
  return _model;
}

// Downscale PROGRESSIVO (dimezzamenti) fino a 224: i browser mobili (Chrome Android)
// degradano il downscale di una foto enorme fatto in un solo passo -> aliasing ->
// input corrotto e classificazione sbagliata. Dimezzare a tappe fa la media delle aree.
function drawTo224(img) {
  let w = img.naturalWidth || img.width;
  let h = img.naturalHeight || img.height;
  let cv = document.createElement('canvas');
  cv.width = w; cv.height = h;
  let ctx = cv.getContext('2d');
  ctx.imageSmoothingEnabled = true; ctx.imageSmoothingQuality = 'high';
  ctx.drawImage(img, 0, 0);
  while (w > INPUT_SIZE * 2 || h > INPUT_SIZE * 2) {
    const nw = Math.max(INPUT_SIZE, w >> 1);
    const nh = Math.max(INPUT_SIZE, h >> 1);
    const next = document.createElement('canvas');
    next.width = nw; next.height = nh;
    const nctx = next.getContext('2d');
    nctx.imageSmoothingEnabled = true; nctx.imageSmoothingQuality = 'high';
    nctx.drawImage(cv, 0, 0, w, h, 0, 0, nw, nh);
    cv = next; w = nw; h = nh;
  }
  const out = document.createElement('canvas');
  out.width = INPUT_SIZE; out.height = INPUT_SIZE;
  const octx = out.getContext('2d');
  octx.imageSmoothingEnabled = true; octx.imageSmoothingQuality = 'high';
  octx.drawImage(cv, 0, 0, w, h, 0, 0, INPUT_SIZE, INPUT_SIZE);
  return octx.getImageData(0, 0, INPUT_SIZE, INPUT_SIZE);
}

// Foto (File o <img>) -> Int32 RGB [1,224,224,3] (l'input del modello è uint8 0..255, niente normalizzazione).
function imageToTensor(img) {
  const { data } = drawTo224(img); // RGBA
  const rgb = new Int32Array(INPUT_SIZE * INPUT_SIZE * 3);
  for (let i = 0, j = 0; i < data.length; i += 4) {
    rgb[j++] = data[i]; rgb[j++] = data[i + 1]; rgb[j++] = data[i + 2];
  }
  return tf.tensor(rgb, [1, INPUT_SIZE, INPUT_SIZE, 3], 'int32');
}

function loadImage(src) {
  return new Promise((res, rej) => {
    const img = new Image();
    img.onload = () => res(img);
    img.onerror = rej;
    img.src = src;
  });
}

async function analyze(src, atteso) {
  try {
    $('result').innerHTML = '';
    await load();
    const img = await loadImage(src);
    $('preview').src = src; $('preview').style.display = 'block';

    const x = imageToTensor(img);
    const t = performance.now();
    const out = _model.predict(x);
    const scores = await (Array.isArray(out) ? out[0] : out).data();
    const dt = performance.now() - t;

    const match = scores.length === _labels.length;
    setStatus(`Inferenza: ${dt.toFixed(0)} ms — output: ${scores.length} classi, label: ${_labels.length}` +
      (match ? ' ✅ combaciano' : ' ⚠️ NON combaciano!'));

    const top = [...scores.keys()].sort((a, b) => scores[b] - scores[a]).slice(0, 5);
    // Output quantizzato uint8: score/255 ≈ probabilità.
    let html = `<p><b>Atteso:</b> ${atteso || '—'} · <b>inferenza:</b> ${dt.toFixed(0)} ms</p>`;
    html += '<table><tr><th>#id</th><th>Specie (label)</th><th>score</th><th>~prob</th></tr>';
    for (const i of top) {
      html += `<tr><td>${i}</td><td>${_labels[i] ?? '(fuori label)'}</td>` +
        `<td>${scores[i].toFixed(1)}</td><td>${(scores[i] / 255).toFixed(3)}</td></tr>`;
    }
    html += '</table>';
    $('result').innerHTML = html;
    setStatus(`Top-1: ${_labels[top[0]]}  (~${(scores[top[0]] / 255).toFixed(3)})`);
    setStatus('OK ✅');
    tf.dispose([x, Array.isArray(out) ? out[0] : out]);
  } catch (err) {
    setStatus('❌ ERRORE (op non supportata? runtime?): ' + (err && err.message ? err.message : err));
    console.error(err);
  }
}

const SAMPLES = [
  ['samples/robin_Erithacus_rubecula.jpg', 'Erithacus rubecula (pettirosso)'],
  ['samples/greattit_Parus_major.jpg', 'Parus major (cinciallegra)'],
  ['samples/blackbird_Turdus_merula.jpg', 'Turdus merula (merlo)'],
];

window.addEventListener('load', () => {
  $('btnLoad').addEventListener('click', async () => {
    $('btnLoad').disabled = true;
    try {
      await load();
      $('file').disabled = false;
      $('btnSamples').disabled = false;
    } catch (err) {
      setStatus('❌ Caricamento modello FALLITO: ' + (err && err.message ? err.message : err));
      console.error(err);
      $('btnLoad').disabled = false; // permetti un nuovo tentativo
    }
  });

  $('file').addEventListener('change', (e) => {
    const f = e.target.files && e.target.files[0];
    if (f) analyze(URL.createObjectURL(f), '(foto utente)');
  });

  const box = $('sampleBtns');
  $('btnSamples').addEventListener('click', () => {
    box.innerHTML = '';
    for (const [url, label] of SAMPLES) {
      const b = document.createElement('button');
      b.textContent = '▶ ' + label;
      b.addEventListener('click', () => analyze(url, label));
      box.appendChild(b);
    }
  });
});
