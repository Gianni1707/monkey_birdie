// Validazione HEADLESS di AIY Birds V1 (.tflite) via tfjs-tflite (WASM) in Node.
// Risponde a: carica+invoca (op support)? #output == #label? top-1 sensata? latenza?
// tfjs-tflite è pensato per il browser: qui polyfilliamo il minimo (document/location/fetch)
// e forziamo la variante WASM non-threaded per farlo girare in Node.
//   1) npm install --legacy-peer-deps @tensorflow/tfjs-tflite@0.0.1-alpha.10 \
//        @tensorflow/tfjs-core@3.21.0 @tensorflow/tfjs-backend-cpu@3.21.0
//   2) python3 preprocess.py         # crea *_224u8.bin da ../samples
//   3) node run.mjs
import { readFileSync, existsSync } from 'node:fs';
import { basename } from 'node:path';
import { performance } from 'node:perf_hooks';
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);

const HERE = new URL('./', import.meta.url).pathname;
const MODEL = HERE + '../model/birds_V1.tflite';
const LABELMAP = HERE + '../aiy_birds_labelmap.csv';
const WASM_DIR = HERE + 'node_modules/@tensorflow/tfjs-tflite/wasm/';

// Ogni .js/.wasm richiesto dal loader vive in WASM_DIR: risolvi per basename se il path è mangled.
function resolveLocal(u) {
  const p = String(u).replace(/^file:\/\//, '');
  if (existsSync(p)) return p;
  const alt = WASM_DIR + basename(p);
  return existsSync(alt) ? alt : p;
}

// --- Polyfill minimi per far girare tfjs-tflite (browser-oriented) in Node ---
globalThis.self = globalThis.self || globalThis;
globalThis.window = globalThis;
// La feature-detect prova a postare un SharedArrayBuffer per rilevare i thread:
// facciamola fallire -> variante WASM non-threaded (in Node non abbiamo i pthread worker).
globalThis.MessageChannel = class {
  constructor() {
    this.port1 = { postMessage() { throw new Error('threads off'); }, close() {} };
    this.port2 = { postMessage() {}, close() {} };
  }
};
globalThis.location = globalThis.location || { href: 'file:///', origin: 'file://', protocol: 'file:' };
// tfjs-tflite carica il factory Emscripten con document.createElement('script'):
// il factory supporta CommonJS, quindi lo require()-iamo e chiamiamo onload.
globalThis.document = globalThis.document || {
  currentScript: null,
  head: { appendChild() {}, removeChild() {} },
  createElement() {
    const el = {
      _src: null, _onload: null, _onerror: null,
      setAttribute(k, v) { if (k === 'src') { el._src = v; el._go(); } },
      set src(v) { el._src = v; el._go(); }, get src() { return el._src; },
      set onload(fn) { el._onload = fn; }, set onerror(fn) { el._onerror = fn; },
      _go() {
        try {
          globalThis.window.tflite_web_api_ModuleFactory = require(resolveLocal(el._src));
          setTimeout(() => el._onload && el._onload(), 0);
        } catch (err) { setTimeout(() => el._onerror && el._onerror(err), 0); }
      },
    };
    return el;
  },
};
const realFetch = globalThis.fetch;
globalThis.fetch = async (input, init) => {
  const u = typeof input === 'string' ? input : (input && input.url) || String(input);
  if (u.startsWith('http://') || u.startsWith('https://')) return realFetch(input, init);
  return new Response(readFileSync(resolveLocal(u)),
    { status: 200, headers: u.endsWith('.wasm') ? { 'Content-Type': 'application/wasm' } : {} });
};

const log = (...a) => console.log(...a);

// labelmap CSV "id,name": l'id È l'indice del logit (964 = background).
function parseLabelmap(text) {
  const arr = [];
  for (const line of text.split('\n')) {
    const t = line.trim();
    if (!t || t.startsWith('id,')) continue;
    const c = t.indexOf(',');
    if (c < 0) continue;
    const id = parseInt(t.slice(0, c), 10);
    if (!Number.isNaN(id)) arr[id] = t.slice(c + 1);
  }
  return arr;
}

const tf = await import('@tensorflow/tfjs-core');
await import('@tensorflow/tfjs-backend-cpu');
await tf.setBackend('cpu');
await tf.ready();
log('tfjs-core backend:', tf.getBackend());

const tflite = await import('@tensorflow/tfjs-tflite');
tflite.setWasmPath(WASM_DIR);

const labels = parseLabelmap(readFileSync(LABELMAP, 'utf8'));
log('labels:', labels.length, '(964 =', JSON.stringify(labels[964]) + ')');

const modelBytes = readFileSync(MODEL);
const ab = modelBytes.buffer.slice(modelBytes.byteOffset, modelBytes.byteOffset + modelBytes.byteLength);

let model;
const tLoad = performance.now();
try {
  model = await tflite.loadTFLiteModel(ab);
} catch (e) {
  log('❌ LOAD FAILED (op/runtime):', e && e.message ? e.message : e);
  process.exit(2);
}
log(`✅ model loaded in ${(performance.now() - tLoad).toFixed(0)} ms`);
log('INPUT :', JSON.stringify(model.inputs));
log('OUTPUT:', JSON.stringify(model.outputs));

const inShape = model.inputs[0].shape;                 // [1,224,224,3]
const H = inShape[1], W = inShape[2], C = inShape[3];

function makeInput(u8) { return tf.tensor(Array.from(u8), inShape, 'int32'); }
function topK(arr, k) {
  return [...arr.keys()].sort((a, b) => arr[b] - arr[a]).slice(0, k)
    .map(i => ({ i, label: labels[i] ?? '(out of labels)', score: arr[i] }));
}

// op-support + #output check su input a zero
{
  const z = makeInput(new Uint8Array(H * W * C));
  const zo = model.predict(z);
  const d = await (Array.isArray(zo) ? zo[0] : zo).data();
  log(`✅ invoke OK (op support) — output=${d.length}, #labels=${labels.length}, match=${d.length === labels.length}`);
  tf.dispose(z);
}

const cases = [
  ['robin', 'Erithacus rubecula', 556],
  ['greattit', 'Parus major', 695],
  ['blackbird', 'Turdus merula', 481],
];
for (const [name, expSci, expIdx] of cases) {
  const binPath = HERE + name + '_224u8.bin';
  if (!existsSync(binPath)) { log(`(skip ${name}: manca ${name}_224u8.bin — lancia preprocess.py)`); continue; }
  const u8 = new Uint8Array(readFileSync(binPath));
  const x = makeInput(u8);
  const t = performance.now();
  const out = model.predict(x);
  const scores = await (Array.isArray(out) ? out[0] : out).data();
  const dt = performance.now() - t;
  const rank = [...scores.keys()].sort((a, b) => scores[b] - scores[a]).indexOf(expIdx);
  log(`\n${name}  (atteso ${expSci}, idx ${expIdx}) — ${dt.toFixed(0)} ms`);
  for (const r of topK(scores, 3)) log(`   #${r.i}\t${r.score.toFixed(0)}\t~${(r.score / 255).toFixed(3)}\t${r.label}`);
  log(`   -> ${rank === 0 ? 'TOP-1 ✅' : 'rank #' + (rank + 1)}  (score atteso ${scores[expIdx].toFixed(0)}/255)`);
  tf.dispose([x, Array.isArray(out) ? out[0] : out]);
}
log('\nDONE');
