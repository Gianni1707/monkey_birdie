#!/usr/bin/env bash
# Build web di release per la pubblicazione (es. Cloudflare Pages).
#
# Fa due cose:
#   1) flutter build web --release con le chiavi Supabase da config/supabase.json
#      (la publishable key è pubblica: sta in un file committabile, non a mano).
#   2) rimuove assets/models/birdnet.tflite dal bundle: sul web il riconoscimento
#      del canto usa TensorFlow.js (web/birdnet/), NON il .tflite (solo Android).
#      Il file pesa ~50 MiB e sfora il limite di 25 MiB per file di Cloudflare Pages.
#
# Uso:  ./tool/build_web.sh
# Poi:  npx wrangler pages deploy build/web --project-name=monkeybirdie \
#           --branch=main --commit-dirty=true
set -euo pipefail

export PATH="/home/gianni/Progetti/flutter/bin:$PATH"

flutter build web --release --dart-define-from-file=config/supabase.json

# Modello TFLite del canto: inutile sul web e oltre il limite di Cloudflare Pages.
rm -f build/web/assets/assets/models/birdnet.tflite

echo "✓ build/web pronto per il deploy (birdnet.tflite rimosso: non serve sul web)."
