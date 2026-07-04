# Spike foto — validazione headless (Node)

Fa girare lo **stesso** `model/birds_V1.tflite` via `tfjs-tflite` (WASM) **senza
browser**, per validare op-support / #output / top-1 / latenza in modo riproducibile.

`tfjs-tflite` è pensato per il browser: `run.mjs` polyfilla il minimo indispensabile
(`document`/`location`/`fetch`, factory Emscripten via `require`) e **forza la variante
WASM non-threaded** (in Node non ci sono i pthread worker del browser).

## Come rieseguire
```bash
cd spike/photo_recognizer/headless
npm install --legacy-peer-deps \
  @tensorflow/tfjs-tflite@0.0.1-alpha.10 \
  @tensorflow/tfjs-core@3.21.0 \
  @tensorflow/tfjs-backend-cpu@3.21.0
python3 preprocess.py     # crea *_224u8.bin dalle foto in ../samples (serve Pillow+numpy)
node run.mjs
```

## Esito atteso (laptop CPU WASM SIMD)
```
✅ invoke OK (op support) — output=965, #labels=965, match=true
robin      -> Erithacus rubecula  232/255 (~0.910)  TOP-1 ✅
greattit   -> Parus major         236/255 (~0.925)  TOP-1 ✅
blackbird  -> Turdus merula       251/255 (~0.984)  TOP-1 ✅
inferenza ~14 ms/foto, load ~60 ms
```

Nota: è la **prova del concetto** headless. Il target Web reale (iPhone Safari,
fotocamera) va confermato con lo spike browser in `../` (`python3 ../serve.py`).
