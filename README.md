# Monkey Bird 🐦

App di bird watching: riconoscimento **on-device** del canto, collezione, mappa e
social. Backend **Supabase** (Postgres + PostGIS, Auth, Storage), client **Flutter**.
Progetto **non commerciale** (free tier / open source).

## Due piattaforme, un solo codebase
- **Android nativo** (`flutter build apk`): riconoscimento con **TFLite** (`tflite_flutter`).
- **Web / PWA** (`flutter build web`): è la versione per **iPhone/Apple** (Safari →
  installabile sulla home) e desktop; riconoscimento in-browser con **TF.js**.

Niente target iOS nativo, niente store: Android si condivide come **APK**, Apple via
**link alla PWA**.

> Stato: **Fase 1 (MVP)** — login, registrazione canto → riconoscimento → salvataggio
> avvistamento geolocalizzato, collezione + scheda specie.

---

## Architettura del riconoscimento
Tutto dietro un'unica interfaccia `BirdRecognizer`, con impl scelta a compile-time
(conditional import):

```
lib/ml/
  recognizer/
    bird_recognizer.dart          interfaccia
    bird_recognizer_factory.dart  if(dart.library.io)->io  if(dart.library.js_interop)->web
    bird_recognizer_io.dart       Android: tflite_flutter
    bird_recognizer_web.dart      Web: TF.js via js_interop (shim web/birdnet/birdnet_tfjs.js)
    bird_recognizer_stub.dart     fallback
  audio/audio_dsp.dart            DSP puro condiviso (decode WAV, resample, finestra 3s)
  birdnet/birdnet_labels.dart     parsing label + BirdNetPrediction
```
Il web non importa `tflite_flutter`; Android non tira il JS interop. Cambiare runtime
web non tocca il resto dell'app.

**Perché due runtime:** il modello BirdNET incorpora il mel-spectrogram (STFT/FFT) nel
grafo. `tfjs-tflite` non esegue la FFT (abort in invoke), quindi sul web si usa il
**modello TF.js ufficiale** (LayersModel con custom layer `MelSpecLayerSimple`, FFT via
`tf.signal.stft`). Backend **WebGL** → **nessun bisogno di COOP/COEP / cross-origin
isolation**: la PWA gira su qualsiasi host statico HTTPS.

---

## 1. Prerequisiti
- Flutter ≥ 3.22 (testato su 3.44 / Dart 3.12)
- Un progetto **Supabase** (piano Free)
- Per Android: device fisico (mic + GPS); per iPhone: Safari (PWA)

## 2. Setup Supabase
SQL Editor, in quest'ordine:
1. `schema.sql` — tabelle, RLS, trigger
2. `supabase/migrations/0002_geo_helpers.sql` — RPC insert + view geo (PostgREST non
   serializza i tipi `geography`)
3. `supabase/migrations/0003_specie_birdnet_label.sql` — colonna `birdnet_label`
4. `supabase/seed/specie_full_seed.sql` — catalogo completo (6516 specie, generato dalle
   label BirdNET) — oppure `specie_seed.sql` per il set starter

Auth: per l'MVP disattiva *Confirm email*. Copia **Project URL** e **anon/publishable key**.

## 3. Modelli BirdNET (non versionati, vedi .gitignore)
Fonte: **Zenodo 15050749** (BirdNET-Analyzer team). Licenza modelli **CC BY-NC-SA 4.0**
→ ok solo perché non commerciale.
- **Android**: `assets/models/birdnet.tflite` (da `BirdNET_v2.4_tflite.zip` → `audio-model.tflite`)
- **Web**: `web/birdnet/model/` (da `BirdNET_v2.4_tfjs.zip`, cartella `model/`: `model.json` + shard + `labels.json`)
- **Label**: `assets/labels/birdnet_labels.txt` (6522, formato `Sci_Common`, da `labels/en_us.txt`)

## 4. Build & dipendenze
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # genera *.freezed.dart / *.g.dart
```
Permessi Android (mic + posizione + internet) sono già in
`android/app/src/main/AndroidManifest.xml`.

## 5. Avvio
**Android (device):**
```bash
flutter run -d <device> \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
```
**Web / PWA:**
```bash
flutter build web \
  --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
# servi build/web con un host statico HTTPS (Cloudflare Pages / Netlify / ecc.)
```
Su iPhone: apri il link in Safari → Condividi → *Aggiungi a Home*.

---

## Distribuzione
- **Android**: condividi `build/app/outputs/flutter-apk/app-release.apk`.
- **Apple/desktop**: condividi il **link della PWA**. Nessuno store.

## Scelte/limiti Fase 1
- **Audio non caricato su Storage** (free tier 1GB): solo metadati + posizione.
- Riconoscimento **solo canto** (foto → fase successiva).
- Mapping BirdNET→catalogo per `birdnet_label` (fallback: nome scientifico).
- **Da validare on-device**: su web il formato del file registrato (`record` →
  `decodeAudioData`) può variare per browser, in particolare iOS Safari.

## Spike di validazione (storia tecnica)
`spike/web_recognizer/` (tfjs-tflite, fallito su FFT) e `spike/web_recognizer_tfjs/`
(TF.js ufficiale, OK: merlo → *Turdus merula*, ~273 ms). Cartelle standalone, non
parte dell'app.

## Roadmap
1. **MVP** (questa fase) — UT01, UT02, UT04
2. Mappa avvistamenti (UT03) + habitat (UT05) — MapLibre (`maplibre_gl` Android / GL JS web) + OpenFreeMap
3. Raccolte (UT06), lista desideri (UT07), profilo (UT09)
4. Social: amici e condivisione (UT08)
5. Riconoscimento da foto on-device
