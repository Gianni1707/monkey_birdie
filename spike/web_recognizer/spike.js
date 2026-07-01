/* Spike di validazione: BirdNET .tflite eseguito nel browser con tfjs-tflite.
 * Obiettivo: (1) il modello carica e gira (op supportate), (2) le predizioni
 * sono sensate, (3) la latenza è accettabile su browser mobile.
 * Il preprocessing replica il DSP Dart: mono, resample a 48kHz, finestra 3s
 * (144000 campioni) a energia massima.
 *
 * I tre file vengono AUTO-CARICATI dalla stessa cartella (nomi fissi sotto);
 * i selettori manuali restano come fallback. */

const WINDOW = 144000;       // 3s @ 48kHz
const TARGET_RATE = 48000;

// Nomi fissi auto-caricati (preparati nella cartella spike/web_recognizer/).
const AUTO = { model: 'birdnet.tflite', labels: 'birdnet_labels.txt', audio: 'sample_3s_48k.wav' };

const $ = (id) => document.getElementById(id);
const log = (m) => { $('log').textContent += m + '\n'; };

let modelBlob = null, labels = [], audioBuf = null;

// stato cross-origin isolation (serve COOP/COEP + secure context per i thread WASM)
(function showIso() {
  const iso = self.crossOriginIsolated === true;
  const el = $('iso');
  el.textContent = iso ? 'ATTIVA (multi-thread)' : 'assente (single-thread, fallback)';
  el.className = 'badge ' + (iso ? 'ok' : 'warn');
})();

function setLabelsFromText(txt) {
  labels = txt.split(/\r?\n/).map((l) => l.trim()).filter(Boolean).map((l) => {
    const i = l.indexOf('_');
    return i > 0 ? { sci: l.slice(0, i), common: l.slice(i + 1), raw: l } : { sci: l, common: l, raw: l };
  });
  log(`Label caricate: ${labels.length}`);
}

$('model').addEventListener('change', (e) => { modelBlob = e.target.files[0]; maybeEnable(); });
$('labels').addEventListener('change', async (e) => { setLabelsFromText(await e.target.files[0].text()); maybeEnable(); });
$('audio').addEventListener('change', async (e) => {
  audioBuf = await e.target.files[0].arrayBuffer();
  log(`Audio caricato: ${e.target.files[0].name} (${audioBuf.byteLength} byte)`);
  maybeEnable();
});

function maybeEnable() { $('run').disabled = !(modelBlob && labels.length && audioBuf); }

// Auto-caricamento dei tre file dalla cartella (se presenti).
async function autoLoad() {
  log('Auto-caricamento file dalla cartella…');
  try {
    const m = await fetch(AUTO.model);
    if (m.ok) { modelBlob = await m.blob(); log(`✓ ${AUTO.model} (${modelBlob.size} byte)`); }
  } catch (_) { log(`· ${AUTO.model} non trovato: usa il selettore.`); }
  try {
    const l = await fetch(AUTO.labels);
    if (l.ok) setLabelsFromText(await l.text());
  } catch (_) { log(`· ${AUTO.labels} non trovato: usa il selettore.`); }
  try {
    const a = await fetch(AUTO.audio);
    if (a.ok) { audioBuf = await a.arrayBuffer(); log(`✓ ${AUTO.audio} (${audioBuf.byteLength} byte)`); }
  } catch (_) { log(`· ${AUTO.audio} non trovato: usa il selettore.`); }
  maybeEnable();
  log($('run').disabled ? 'Mancano dei file: completali col selettore.' : 'Pronto ✅ — premi “Esegui riconoscimento”.');
}

async function decodeTo48kWindow(arrayBuffer) {
  const AC = window.AudioContext || window.webkitAudioContext;
  const ctx = new AC();
  const decoded = await ctx.decodeAudioData(arrayBuffer.slice(0));
  const ch = decoded.numberOfChannels, len = decoded.length;
  const mono = new Float32Array(len);
  for (let c = 0; c < ch; c++) {
    const d = decoded.getChannelData(c);
    for (let i = 0; i < len; i++) mono[i] += d[i] / ch;
  }
  // resample a 48kHz con OfflineAudioContext
  const outLen = Math.ceil((len / decoded.sampleRate) * TARGET_RATE);
  const off = new OfflineAudioContext(1, outLen, TARGET_RATE);
  const buf = off.createBuffer(1, len, decoded.sampleRate);
  buf.copyToChannel(mono, 0);
  const src = off.createBufferSource();
  src.buffer = buf; src.connect(off.destination); src.start();
  const rendered = await off.startRendering();
  return bestWindow(rendered.getChannelData(0));
}

function bestWindow(s) {
  if (s.length <= WINDOW) { const out = new Float32Array(WINDOW); out.set(s); return out; }
  let bestStart = 0, bestE = -1; const hop = WINDOW >> 1;
  for (let start = 0; start + WINDOW <= s.length; start += hop) {
    let e = 0;
    for (let i = start; i < start + WINDOW; i += 16) { const v = s[i]; e += v * v; }
    if (e > bestE) { bestE = e; bestStart = start; }
  }
  return s.subarray(bestStart, bestStart + WINDOW);
}

const sigmoid = (x) => 1 / (1 + Math.exp(-x));

$('run').addEventListener('click', async () => {
  $('log').textContent = ''; $('result').innerHTML = '';
  try {
    // I file .wasm di tfjs-tflite stanno in /wasm/ (non /dist/): va indicato.
    tflite.setWasmPath('https://cdn.jsdelivr.net/npm/@tensorflow/tfjs-tflite@0.0.1-alpha.10/wasm/');
    await tf.ready();
    log('TF.js backend: ' + tf.getBackend());
    const modelUrl = URL.createObjectURL(modelBlob);

    const t0 = performance.now();
    const model = await tflite.loadTFLiteModel(modelUrl);
    const tLoad = performance.now() - t0;
    log(`Modello caricato in ${tLoad.toFixed(0)} ms`);

    const window = await decodeTo48kWindow(audioBuf);
    log(`Finestra audio: ${window.length} campioni @48kHz`);

    const input = tf.tensor(window, [1, WINDOW], 'float32');
    // warmup (la 1ª inferenza include compilazione kernel)
    let warm = model.predict(input); await warm.data(); tf.dispose(warm);

    const t1 = performance.now();
    const out = model.predict(input);
    const data = await out.data();
    const tInfer = performance.now() - t1;
    log(`Inferenza (post-warmup): ${tInfer.toFixed(0)} ms — output: ${data.length} classi`);

    if (data.length !== labels.length) {
      log(`⚠️ ATTENZIONE: output modello (${data.length}) ≠ numero label (${labels.length}). ` +
          `Verifica che la label list combaci con il modello.`);
    }

    const k = Math.max(1, Math.min(20, parseInt($('topk').value || '5', 10)));
    const scored = Array.from(data, (v, i) => ({ i, p: sigmoid(v) }))
      .sort((a, b) => b.p - a.p).slice(0, k);

    let html = '<table><tr><th>#</th><th>Specie</th><th>Confidenza</th><th>idx</th></tr>';
    for (const s of scored) {
      const lab = labels[s.i] || { common: '(fuori label)', sci: '' };
      html += `<tr><td>${s.i}</td><td>${lab.common}<br><i>${lab.sci}</i></td>` +
              `<td>${(s.p * 100).toFixed(1)}%</td><td>${s.i}</td></tr>`;
    }
    html += '</table>';
    html += `<p><b>Latenza load:</b> ${tLoad.toFixed(0)} ms · ` +
            `<b>inferenza:</b> ${tInfer.toFixed(0)} ms · ` +
            `<b>isolation:</b> ${self.crossOriginIsolated ? 'sì (multi-thread)' : 'no (single-thread)'}</p>`;
    $('result').innerHTML = html;

    tf.dispose([input, out]);
    log('OK ✅  — copia questi numeri nel template risultati del README.');
  } catch (err) {
    log('❌ ERRORE: ' + (err && err.message ? err.message : err));
    log('Se l’errore cita op non supportate, è il segnale per valutare l’opzione 2 (TF.js). NON convertire senza avvisare.');
    console.error(err);
  }
});

autoLoad();
