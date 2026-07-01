# Spike — riconoscimento BirdNET nel browser (tfjs-tflite)

**Scopo (gate prima di cablare l'impl web):** verificare che lo *stesso*
`birdnet.tflite` giri in-browser via `@tensorflow/tfjs-tflite` con
(1) **op supportate**, (2) **predizioni sensate**, (3) **latenza accettabile su
browser mobile**. Se fallisce → si valuta l'opzione 2 (conversione a TF.js).
**Non convertire nulla senza prima avvisare.**

Questo spike è **standalone**: non dipende dall'app Flutter, non tocca `lib/`.

## Cosa ti serve
- `birdnet.tflite` (il modello reale)
- `birdnet_labels.txt` (label list nello stesso ordine di output del modello)
- una **clip di test** di ≥3s con un canto noto (per giudicare se la top-1 è sensata)

## A) Run rapido (correttezza + latenza, single-thread)
Va bene un server statico qualsiasi, anche senza isolation:
```bash
cd spike/web_recognizer
python3 -m http.server 8765
```
- Sul **laptop**: apri http://localhost:8765, carica i 3 file, premi *Esegui*.
- Sul **telefono** (stessa Wi-Fi): apri `http://IP-DEL-LAPTOP:8765`.
  Misura così la latenza single-thread su mobile (il caso peggiore, utile).

## B) Run isolato (multi-thread WASM)
Per attivare i thread serve cross-origin isolation (COOP/COEP) **e** un secure context:
```bash
cd spike/web_recognizer
python3 serve.py 8765      # aggiunge COOP/COEP
```
- Su **localhost** (laptop) la pagina mostrerà *isolation ATTIVA*.
- Su **mobile** i thread richiedono **HTTPS**: usa un tunnel (es.
  `cloudflared tunnel --url http://localhost:8765`) e apri l'URL https sul telefono.
- Se con `require-corp` i CDN si bloccano (errore di caricamento script/WASM),
  resta sul run A per la correttezza, e per i thread self-hosta gli script:
  scarica `tf.min.js` e `tf-tflite.min.js` accanto a `index.html` e cambia i due
  `<script src=...>` in percorsi locali.

## Cosa guardare
- La pagina stampa: tempo di **load**, tempo di **inferenza** (post-warmup),
  numero di **classi** in output e la **top-K** mappata sulle label.
- ⚠️ Se "output modello ≠ numero label", la label list non combacia col modello.
- Se compare un errore su **op non supportate**, annotalo: è il segnale per l'opzione 2.

## Template risultati (incollami questo compilato)
```
Modello / variant BirdNET: ____________________  (FP32 / INT8 / ...)
N. classi output: ______   N. label: ______   (combaciano? sì/no)

Laptop (Chrome, localhost):
  isolation: sì/no   load: ____ ms   inferenza: ____ ms
  top-1 sensata? sì/no   (atteso: __________  ottenuto: __________)

Telefono (____________, browser ______):
  isolation: sì/no   load: ____ ms   inferenza: ____ ms
  top-1 sensata? sì/no

Errori op non supportate? sì/no — quali: __________________________
Giudizio latenza mobile: accettabile / borderline / inutilizzabile
```
