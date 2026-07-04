/* Shim tfjs-tflite per il riconoscimento uccelli DA FOTO sul web/PWA.
 * Funzioni globali chiamate dal lato Dart (js_interop):
 *   window.birdImageLoad()             -> Promise<void>
 *   window.birdImageAnalyzeUrl(url)    -> Promise<Float32Array>   (965 score 0..255)
 *
 * Modello: AIY Vision Classifier Birds V1 (.tflite), eseguito con tfjs-tflite (WASM).
 * Op standard (conv/pool) -> nessun COOP/COEP, nessun runtime "threaded".
 * Convive con TF.js 4.22 già caricato per l'audio (verificato compatibile).
 *
 * DOWNSCALE PROGRESSIVO: i browser mobili (Chrome Android) degradano il downscale
 * di una foto grande a 224 fatto in un solo passo -> aliasing -> input corrotto e
 * specie sbagliata a bassa confidenza. Dimezziamo a tappe (media delle aree). */
(function () {
  const MODEL_URL = 'birds_image/model/birds_V1.tflite';
  const WASM_PREFIX =
    'https://cdn.jsdelivr.net/npm/@tensorflow/tfjs-tflite@0.0.1-alpha.10/wasm/';
  const SIZE = 224;
  let _model = null;

  async function ensureModel() {
    if (_model) return _model;
    await tf.ready();
    tflite.setWasmPath(WASM_PREFIX);
    _model = await tflite.loadTFLiteModel(MODEL_URL);
    return _model;
  }

  function loadImage(url) {
    return new Promise((res, rej) => {
      const img = new Image();
      img.onload = () => res(img);
      img.onerror = rej;
      img.src = url;
    });
  }

  // Downscale progressivo (dimezzamenti) fino a 224 -> ImageData 224x224 RGBA.
  function drawTo224(img) {
    let w = img.naturalWidth || img.width;
    let h = img.naturalHeight || img.height;
    let cv = document.createElement('canvas');
    cv.width = w; cv.height = h;
    let ctx = cv.getContext('2d');
    ctx.imageSmoothingEnabled = true; ctx.imageSmoothingQuality = 'high';
    ctx.drawImage(img, 0, 0);
    while (w > SIZE * 2 || h > SIZE * 2) {
      const nw = Math.max(SIZE, w >> 1);
      const nh = Math.max(SIZE, h >> 1);
      const next = document.createElement('canvas');
      next.width = nw; next.height = nh;
      const nctx = next.getContext('2d');
      nctx.imageSmoothingEnabled = true; nctx.imageSmoothingQuality = 'high';
      nctx.drawImage(cv, 0, 0, w, h, 0, 0, nw, nh);
      cv = next; w = nw; h = nh;
    }
    const out = document.createElement('canvas');
    out.width = SIZE; out.height = SIZE;
    const octx = out.getContext('2d');
    octx.imageSmoothingEnabled = true; octx.imageSmoothingQuality = 'high';
    octx.drawImage(cv, 0, 0, w, h, 0, 0, SIZE, SIZE);
    return octx.getImageData(0, 0, SIZE, SIZE);
  }

  window.birdImageLoad = async function () { await ensureModel(); };

  window.birdImageAnalyzeUrl = async function (url) {
    const model = await ensureModel();
    const img = await loadImage(url);
    const { data } = drawTo224(img); // RGBA
    const rgb = new Int32Array(SIZE * SIZE * 3);
    for (let i = 0, j = 0; i < data.length; i += 4) {
      rgb[j++] = data[i]; rgb[j++] = data[i + 1]; rgb[j++] = data[i + 2];
    }
    const input = tf.tensor(rgb, [1, SIZE, SIZE, 3], 'int32');
    const out = model.predict(input);
    const scores = await (Array.isArray(out) ? out[0] : out).data();
    tf.dispose([input, Array.isArray(out) ? out[0] : out]);
    return new Float32Array(scores); // 965 score grezzi (0..255)
  };
})();
