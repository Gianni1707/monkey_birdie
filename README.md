# MonkeyBirdie

App di bird watching che riconosce gli uccelli dal canto e dalle foto direttamente sul
dispositivo, li raccoglie, li mostra su mappa e permette di condividerli. È un progetto
personale, non commerciale, costruito su servizi gratuiti (Flutter + Supabase).

Versione web: https://monkeybirdie.com

## Come è fatta

Un solo codebase Flutter con due destinazioni:

- Android nativo: riconoscimento con TensorFlow Lite (`tflite_flutter`).
- Web / PWA: è anche la versione per iPhone (si installa da Safari) e desktop; qui il
  riconoscimento gira nel browser con TensorFlow.js.

Non c'è un'app iOS nativa e non si passa dagli store: Android si distribuisce come APK
firmato, Apple tramite il link alla PWA.

Il backend è Supabase: Postgres con PostGIS, autenticazione e storage. Ogni utente vede
solo i propri dati grazie alla Row Level Security; gli avvistamenti si condividono solo
se si attiva l'apposito interruttore.

## Cosa fa

- Riconoscimento del canto (BirdNET) e delle foto (AIY Birds V1), tutto on-device.
- Collezione degli avvistamenti con foto, data e luogo.
- Mappa degli avvistamenti (`flutter_map` + tile OpenStreetMap).
- Schede specie con descrizione, morfologia, ordine tassonomico, distribuzione (GBIF) e
  nome comune in italiano.
- Raccolte, lista dei desideri, preferiti.
- Profilo con avatar e badge; amici e condivisione.
- "Uccelli nei dintorni": specie presenti nella zona dalla posizione (dati GBIF +
  avvistamenti condivisi da te e dagli amici).
- Ascolto del verso nella scheda specie (registrazioni da xeno-canto, con attribuzione).
- Recupero password e, sulla versione Android, avviso quando esce un aggiornamento.
- Interfaccia in italiano e inglese.

## Il riconoscimento

Tutto passa da un'interfaccia comune (`BirdRecognizer`), con l'implementazione scelta a
compile-time tramite conditional import:

```
lib/ml/recognizer/
  bird_recognizer.dart          interfaccia
  bird_recognizer_factory.dart  io -> Android (tflite),  js_interop -> Web (TF.js)
  bird_recognizer_io.dart       Android: tflite_flutter
  bird_recognizer_web.dart      Web: TF.js (shim web/birdnet/birdnet_tfjs.js)
```

Servono due runtime perché il modello BirdNET incorpora nel grafo il calcolo del
mel-spettrogramma (STFT/FFT): `tfjs-tflite` non esegue la FFT, quindi sul web si usa il
modello TF.js ufficiale (con custom layer e FFT via `tf.signal.stft`). Gira su backend
WebGL, perciò non servono header COOP/COEP e la PWA sta su qualsiasi host statico HTTPS.
Lo stesso schema vale per il riconoscimento da foto.

## Requisiti

- Flutter ≥ 3.22 (sviluppato su 3.44 / Dart 3.12)
- Un progetto Supabase (piano gratuito)
- Per Android: un dispositivo fisico (serve microfono e GPS)

## Configurazione Supabase

Nel SQL Editor, in quest'ordine: `schema.sql`, poi le migrazioni in `supabase/migrations/`
in ordine numerico, poi i seed opzionali in `supabase/seed/` (catalogo specie, nomi
italiani, descrizioni, morfologia, ecc.). Per lo sviluppo conviene disattivare la conferma
email in Auth; per la produzione va configurato un SMTP (l'email integrata di Supabase ha
un limite molto basso).

Le chiavi non vanno passate a mano: stanno in `config/supabase.json` (solo Project URL e
publishable key, che è pubblica ed è protetta dalla RLS) e il build le legge con
`--dart-define-from-file`.

## Modelli

I modelli non sono nel repository (troppo grossi, vedi `.gitignore`). Vanno scaricati e
messi in:

- Canto, Android: `assets/models/birdnet.tflite`
- Canto, Web: `web/birdnet/model/`
- Foto, Android: `assets/models/birds_V1.tflite`
- Foto, Web: `web/birds_image/model/birds_V1.tflite`

BirdNET viene da Zenodo (record 15050749), AIY Birds V1 da Kaggle. Il modello BirdNET è
sotto licenza CC BY-NC-SA 4.0: è utilizzabile qui solo perché il progetto non è commerciale.

## Build

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # genera i file freezed/json
```

Web (release, poi deploy su un host statico HTTPS):

```bash
./tool/build_web.sh          # build release + rimuove birdnet.tflite (inutile sul web)
```

Android (APK di release firmato): serve un keystore e un file `android/key.properties` con
le credenziali (entrambi fuori dal repository). Poi:

```bash
flutter build apk --release --dart-define-from-file=config/supabase.json
# risultato: build/app/outputs/flutter-apk/app-release.apk
```

## Attribuzioni

Modelli di riconoscimento: BirdNET (CC BY-NC-SA 4.0) e AIY Vision Birds V1 (Apache 2.0).
Foto delle specie da iNaturalist, mappe da OpenStreetMap, distribuzione e tassonomia da
GBIF, dati morfologici da BIRDBASE, descrizioni da Wikipedia, registrazioni dei versi da
xeno-canto (Creative Commons, con attribuzione all'autore). Progetto non commerciale.
