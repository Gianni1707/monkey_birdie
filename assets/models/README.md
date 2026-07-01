# Modello BirdNET (on-device)

Questo file `.tflite` **non è versionato** (è grande; vedi `.gitignore`).

## Cosa scaricare
Metti qui il modello audio BirdNET in formato TFLite, rinominandolo:

```
assets/models/birdnet.tflite
```

E la label list corrispondente (stesso ordine degli output del modello) in:

```
assets/labels/birdnet_labels.txt      # formato: Nome_scientifico_Nome comune
```

Fonte: progetto **BirdNET-Analyzer** (kahst/BirdNET-Analyzer), modello FP32/INT8
"audio". Licenza modelli: **CC BY-NC-SA 4.0** → uso consentito solo perché questo
progetto è **non commerciale**.

## Contratto col codice
`lib/ml/birdnet/birdnet_service.dart` assume:
- input  `[1, 144000]` float32 (segnale grezzo, 48 kHz mono, 3 s)
- output `[1, N]` logit, con `N` = numero di righe in `birdnet_labels.txt`

Se il variant scelto differisce (input spettrogramma, output già in probabilità,
quantizzazione INT8), adatta `birdnet_service.dart` e `audio_preprocessor.dart`.

> Il file `birdnet_labels.txt` attualmente nel repo è un **placeholder** di 20
> specie: sostituiscilo con la label list reale prima di usare il modello vero,
> e rigenera il seed completo con `tool/genera_seed_specie.dart`.
