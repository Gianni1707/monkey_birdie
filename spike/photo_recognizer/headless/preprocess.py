#!/usr/bin/env python3
"""Pre-elabora le foto di esempio in tensori RGB 224x224 uint8 (raw .bin) per run.mjs.
Node non decodifica i JPEG comodamente; lo facciamo qui con Pillow.
    python3 preprocess.py
Richiede: Pillow, numpy.
"""
import os
from PIL import Image
import numpy as np

SIZE = 224
SAMPLES = {
    'robin': '../samples/robin_Erithacus_rubecula.jpg',
    'greattit': '../samples/greattit_Parus_major.jpg',
    'blackbird': '../samples/blackbird_Turdus_merula.jpg',
}
here = os.path.dirname(os.path.abspath(__file__))
for name, rel in SAMPLES.items():
    path = os.path.join(here, rel)
    im = Image.open(path).convert('RGB').resize((SIZE, SIZE), Image.BILINEAR)
    arr = np.asarray(im, dtype=np.uint8)
    assert arr.shape == (SIZE, SIZE, 3), arr.shape
    out = os.path.join(here, name + '_224u8.bin')
    arr.tofile(out)
    print(f'{name}: {arr.shape} -> {os.path.basename(out)} ({arr.size} bytes)')
