// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'MonkeyBirdie';

  @override
  String get login => 'Accedi';

  @override
  String get email => 'Email';

  @override
  String get emailInvalid => 'Email non valida';

  @override
  String get password => 'Password';

  @override
  String get passwordMin => 'Minimo 6 caratteri';

  @override
  String get noAccountRegister => 'Non hai un account? Registrati';

  @override
  String get noAccountQuestion => 'Non hai un account?';

  @override
  String get haveAccountQuestion => 'Hai già un account?';

  @override
  String get loginSubtitle => 'Il tuo diario di campo alato';

  @override
  String get registerSubtitle => 'Inizia la tua avventura ornitologica';

  @override
  String get emailHint => 'esempio@email.it';

  @override
  String get register => 'Registrati';

  @override
  String get username => 'Username';

  @override
  String get usernameMin => 'Minimo 3 caratteri';

  @override
  String get usernameTaken => 'Questo username è già in uso.';

  @override
  String get createAccount => 'Crea account';

  @override
  String get haveAccount => 'Ho già un account';

  @override
  String get registrationEmailConfirm =>
      'Registrazione completata: conferma via email.';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get recoverPasswordTitle => 'Recupera password';

  @override
  String get recoverPasswordSubtitle =>
      'Inserisci la tua email: ti invieremo un link per reimpostare la password.';

  @override
  String get sendRecoveryLink => 'Invia link di recupero';

  @override
  String get recoveryEmailSent =>
      'Se esiste un account con quell\'indirizzo, ti abbiamo inviato un\'email con il link per reimpostare la password.';

  @override
  String get backToLogin => 'Torna all\'accesso';

  @override
  String get newPasswordTitle => 'Nuova password';

  @override
  String get newPasswordSubtitle =>
      'Scegli una nuova password per il tuo account.';

  @override
  String get newPassword => 'Nuova password';

  @override
  String get confirmPassword => 'Conferma password';

  @override
  String get passwordsDoNotMatch => 'Le password non coincidono';

  @override
  String get updatePassword => 'Aggiorna password';

  @override
  String get passwordUpdated => 'Password aggiornata. Ora sei connesso.';

  @override
  String get updateAvailableTitle => 'Aggiornamento disponibile';

  @override
  String updateAvailableBody(String versione) {
    return 'È disponibile la versione $versione.';
  }

  @override
  String get updateLater => 'Più tardi';

  @override
  String get updateDownload => 'Scarica';

  @override
  String get nearbyTitle => 'Specie presenti in questa zona';

  @override
  String get nearbySeenRecently => 'Avvistato qui di recente';

  @override
  String get nearbyPresentInArea => 'Presente in zona';

  @override
  String get nearbyEnableLocation =>
      'Attiva la posizione per scoprire le specie della tua zona.';

  @override
  String get nearbyEnableButton => 'Attiva posizione';

  @override
  String get nearbyNoData => 'Nessun dato per questa zona.';

  @override
  String get nearbyGbifNote =>
      'Osservazioni storiche (GBIF), non una previsione.';

  @override
  String get listenCall => 'Ascolta il verso';

  @override
  String recordingCredit(String autore, String id) {
    return 'Registrazione di $autore · XC$id · xeno-canto';
  }

  @override
  String get landingEyebrow => 'Guida da campo digitale';

  @override
  String get landingHeroTitle =>
      'Riconosci gli uccelli dal canto o da una foto.';

  @override
  String get landingHeroSubtitle =>
      'Il tuo diario di campo digitale: identifica, colleziona e condividi ogni avvistamento.';

  @override
  String get landingStartNow => 'Inizia ora';

  @override
  String get landingHowTitle => 'Come funziona';

  @override
  String get landingStepWord => 'Passo';

  @override
  String get landingStep1 => 'Ascolta o fotografa';

  @override
  String get landingStep2 => 'Scopri la specie';

  @override
  String get landingStep3 => 'Salva nella collezione';

  @override
  String get landingFeaturesTitle => 'Tutto quello che serve sul campo';

  @override
  String get landingFeat1Title => 'Riconoscimento dal canto e dalla foto';

  @override
  String get landingFeat1Body => 'L\'IA identifica la specie in pochi secondi.';

  @override
  String get landingFeat2Title => 'Collezione e mappa';

  @override
  String get landingFeat2Body =>
      'Ogni avvistamento nella tua raccolta e sulla mappa.';

  @override
  String get landingFeat3Title => 'Schede da guida da campo';

  @override
  String get landingFeat3Body =>
      'Descrizione, habitat, dati e il verso di ogni specie.';

  @override
  String get landingFeat4Title => 'Amici e condivisione';

  @override
  String get landingFeat4Body =>
      'Segui gli amici e condividi i tuoi avvistamenti.';

  @override
  String get landingPreviewTitle => 'Dai un\'occhiata all\'app';

  @override
  String get landingPreviewSubtitle =>
      'Collezione, schede specie e mappa degli avvistamenti.';

  @override
  String get landingAvailEyebrow => 'Come si usa';

  @override
  String get landingAvailTitle => 'Disponibile su iPhone e Android';

  @override
  String get landingAvailSubtitle =>
      'L\'esperienza completa di MonkeyBirdie su entrambi i sistemi. Scegli il tuo dispositivo.';

  @override
  String get landingIphoneTitle => 'Su iPhone';

  @override
  String get landingIphoneTag => 'App web · Nessun download';

  @override
  String get landingIphoneBody =>
      'Nessuna installazione: apri MonkeyBirdie dal browser e, da Safari, tocca «Aggiungi a Home» per averla come un\'app.';

  @override
  String get landingIphoneButton => 'Apri l\'app';

  @override
  String get landingAndroidTitle => 'Su Android';

  @override
  String get landingAndroidTag => 'App nativa · Sempre aggiornata';

  @override
  String get landingAndroidBody =>
      'Scarica l\'app (file APK) e installala. Riceverai gli avvisi di aggiornamento direttamente nell\'app.';

  @override
  String get landingAndroidButton => 'Scarica per Android';

  @override
  String get landingAndroidNote =>
      'Ti verrà chiesto di consentire l\'installazione da questa origine: è normale per le app fuori dagli store.';

  @override
  String get landingClosing => 'Inizia a osservare in un modo nuovo.';

  @override
  String get landingEnter => 'Entra nell\'app';

  @override
  String get landingContacts => 'Contatti';

  @override
  String get landingGithub => 'GitHub';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacyBody =>
      'MonkeyBirdie è un progetto personale e non commerciale. I tuoi dati (account, avvistamenti, foto e posizione) sono conservati sul backend Supabase e servono solo a far funzionare l\'app: la tua collezione, la mappa e la condivisione con gli amici. Gli avvistamenti sono privati per impostazione predefinita e diventano visibili agli amici soltanto se attivi tu la condivisione. Non vendiamo dati e non usiamo tracciamento pubblicitario. Il riconoscimento delle specie avviene sul dispositivo. Per qualsiasi richiesta, o per cancellare il tuo account e i tuoi dati, scrivi a beneficogianni@gmail.com.';

  @override
  String get tabRecognize => 'Riconosci';

  @override
  String get tabHome => 'Home';

  @override
  String get tabMap => 'Mappa';

  @override
  String get tabCollection => 'Collezione';

  @override
  String homeWelcome(String name) {
    return 'Benvenuto $name';
  }

  @override
  String get homeSubtitle => 'Pronto per una nuova scoperta?';

  @override
  String get homeAudioTitle => 'Audio';

  @override
  String get homeAudioHint => 'Ascolta il canto';

  @override
  String get homePhotoTitle => 'Foto';

  @override
  String get homePhotoHint => 'Cattura l’istante';

  @override
  String get homeLatestSightings => 'I tuoi ultimi avvistamenti';

  @override
  String get seeAll => 'Vedi tutti';

  @override
  String get newsAndGuides => 'News e guide';

  @override
  String get tipOfTheDay => 'Consiglio del giorno';

  @override
  String get inThisPeriod => 'In questo periodo';

  @override
  String get birdOfTheDay => 'Uccello del giorno';

  @override
  String get guidesTitle => 'Guide e consigli';

  @override
  String get logout => 'Esci';

  @override
  String get language => 'Lingua';

  @override
  String get languageSystem => 'Automatica (sistema)';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get tapToRecord => 'Tocca per registrare un canto';

  @override
  String get orFromPhoto => 'oppure riconosci da una foto';

  @override
  String get takePhoto => 'Scatta foto';

  @override
  String get uploadPhoto => 'Carica foto';

  @override
  String get recordingTapToStop =>
      'Registrazione… tocca per fermare e analizzare';

  @override
  String get analyzingSong => 'Analisi del canto…';

  @override
  String get analyzingPhoto => 'Analisi della foto…';

  @override
  String get saving => 'Salvataggio…';

  @override
  String get results => 'Risultati';

  @override
  String get resultsIntro =>
      'Ecco i risultati più probabili del riconoscimento.';

  @override
  String get bestMatch => 'Migliore corrispondenza';

  @override
  String get otherPossibilities => 'Altre possibilità';

  @override
  String get notSure => 'Non sono sicuro';

  @override
  String get confirmAndSave => 'Conferma e salva';

  @override
  String get chooseSpecies =>
      'Scegli la specie corretta per salvare l’avvistamento:';

  @override
  String get uncertainPhoto =>
      'Non sono sicuro: la foto potrebbe essere sfocata o lontana. Controlla i candidati o riprova.';

  @override
  String get locationMissing =>
      'Posizione non rilevata: verrà salvato senza posizione precisa.';

  @override
  String get noSpecies => 'Nessuna specie riconosciuta. Riprova.';

  @override
  String get notInCatalog => 'non in catalogo';

  @override
  String get addedToCollection => 'Avvistamento aggiunto alla collezione.';

  @override
  String get restart => 'Ricomincia';

  @override
  String get sightingSaved => 'Avvistamento salvato!';

  @override
  String get micPermissionDenied => 'Permesso microfono negato.';

  @override
  String get cameraPermissionDenied => 'Permesso fotocamera negato.';

  @override
  String get galleryPermissionDenied => 'Permesso galleria negato.';

  @override
  String get speciesNotInCatalog =>
      'Specie non presente in catalogo: impossibile salvare.';

  @override
  String get emptyCollectionTitle => 'Collezione vuota';

  @override
  String get emptyCollectionSubtitle =>
      'Registra il canto di un uccello per iniziare.';

  @override
  String get speciesCard => 'Scheda specie';

  @override
  String rarityLabel(String value) {
    return 'Rarità: $value';
  }

  @override
  String dangerLabel(String value) {
    return 'Pericolo: $value';
  }

  @override
  String get description => 'Descrizione';

  @override
  String get habitat => 'Habitat';

  @override
  String get habitatComingSoon => 'Mappa dell’habitat in arrivo nella Fase 2.';

  @override
  String get whereItLives => 'Dove vive';

  @override
  String get morphology => 'Morfologia';

  @override
  String get lengthLabel => 'Lunghezza';

  @override
  String get weightLabel => 'Peso';

  @override
  String get eggsLabel => 'Uova';

  @override
  String get nestLabel => 'Nido';

  @override
  String get notAvailable => 'n/d';

  @override
  String get morphologySource => 'Dati morfologici: BIRDBASE';

  @override
  String descriptionSource(String fonte) {
    return 'Fonte: $fonte';
  }

  @override
  String get share => 'Condividi';

  @override
  String get habitatDistribution => 'Habitat e distribuzione';

  @override
  String get distributionSource => 'Dati di distribuzione: GBIF';

  @override
  String get distributionUnavailable =>
      'Dati di distribuzione non disponibili.';

  @override
  String get tapToExpand => 'Tocca per ingrandire';

  @override
  String get rarityCommon => 'comune';

  @override
  String get rarityUncommon => 'poco comune';

  @override
  String get rarityRare => 'rara';

  @override
  String get rarityVeryRare => 'molto rara';

  @override
  String get dangerNone => 'nessuno';

  @override
  String get dangerLow => 'basso';

  @override
  String get dangerMedium => 'medio';

  @override
  String get dangerHigh => 'alto';

  @override
  String get tabProfile => 'Profilo';

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get bio => 'Bio';

  @override
  String get profileBioEmpty =>
      'Nessuna bio. Tocca «Modifica profilo» per aggiungerne una.';

  @override
  String get nameField => 'Nome';

  @override
  String get locationField => 'Località';

  @override
  String get experienceField => 'Livello di esperienza';

  @override
  String get experienceUnset => 'Non impostato';

  @override
  String get experienceBeginner => 'Principiante';

  @override
  String get experienceIntermediate => 'Intermedio';

  @override
  String get experienceExpert => 'Esperto';

  @override
  String get experiencePreferNotToSay => 'Preferisco non dirlo';

  @override
  String get levelBeginner => 'Principiante';

  @override
  String get levelEnthusiast => 'Appassionato';

  @override
  String get levelExpert => 'Esperto';

  @override
  String get levelMaster => 'Maestro';

  @override
  String get levelMax => 'livello massimo raggiunto';

  @override
  String levelProgress(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ancora $count specie al prossimo livello',
      one: 'ancora 1 specie al prossimo livello',
    );
    return '$_temp0';
  }

  @override
  String get removePhoto => 'Rimuovi foto';

  @override
  String get favorites => 'Uccelli preferiti';

  @override
  String get addFavorite => 'Aggiungi preferito';

  @override
  String get removeFavorite => 'Togli dai preferiti';

  @override
  String get noFavorites =>
      'Nessun preferito. Aggiungi le specie che ami dal catalogo.';

  @override
  String get searchSpeciesHint => 'Cerca una specie…';

  @override
  String get searchSpeciesTypeHint =>
      'Scrivi almeno 2 lettere per cercare una specie.';

  @override
  String get searchSpeciesNoResults => 'Nessuna specie trovata.';

  @override
  String get confirmLocationTitle => 'Conferma la posizione';

  @override
  String get confirmLocationAuto =>
      'Trascina il segnaposto per correggere il punto.';

  @override
  String get confirmLocationManual =>
      'Tocca la mappa per posizionare l’avvistamento.';

  @override
  String get confirm => 'Conferma';

  @override
  String get cancel => 'Annulla';

  @override
  String get mapEmptyTitle => 'Nessun avvistamento sulla mappa';

  @override
  String get mapEmptySubtitle =>
      'Salva un avvistamento con la posizione per vederlo qui.';

  @override
  String get mapUnavailable => 'Mappa non disponibile (sei offline?).';

  @override
  String get speciesCardButton => 'Scheda specie';

  @override
  String get searchPlaceHint => 'Cerca un luogo…';

  @override
  String get searchNoResults => 'Nessun luogo trovato.';

  @override
  String get myLocation => 'La mia posizione';

  @override
  String get tabSightings => 'Avvistati';

  @override
  String get tabCollections => 'Raccolte';

  @override
  String get deleteSighting => 'Elimina avvistamento';

  @override
  String get deleteSightingTitle => 'Eliminare l’avvistamento?';

  @override
  String get deleteSightingBody => 'L’azione è irreversibile.';

  @override
  String get deleteAction => 'Elimina';

  @override
  String get sightingDeleted => 'Avvistamento eliminato.';

  @override
  String get tabWishlist => 'Desideri';

  @override
  String get addToWishlist => 'Voglio avvistarlo';

  @override
  String get removeFromWishlist => 'Togli dai desideri';

  @override
  String get emptyWishlistTitle => 'Nessun desiderio';

  @override
  String get emptyWishlistSubtitle =>
      'Aggiungi le specie che vuoi ancora avvistare.';

  @override
  String get alreadySpotted => 'Già avvistata 🎉';

  @override
  String get wishlistNote => 'Nota';

  @override
  String get wishlistNoteHint => 'Nota (opzionale)';

  @override
  String get dangerNotReported => 'non segnalato';

  @override
  String difficultyEstimateLabel(String value) {
    return 'Difficoltà (stima): $value';
  }

  @override
  String get difficultyCommon => 'comune';

  @override
  String get difficultyUncommon => 'poco comune';

  @override
  String get difficultyHard => 'difficile';

  @override
  String get difficultyVeryRare => 'molto raro';

  @override
  String get difficultyNA => 'n/d';

  @override
  String get collections => 'Raccolte';

  @override
  String get newCollection => 'Nuova raccolta';

  @override
  String get create => 'Crea';

  @override
  String get save => 'Salva';

  @override
  String get done => 'Fatto';

  @override
  String get delete => 'Elimina';

  @override
  String get renameCollection => 'Rinomina';

  @override
  String get deleteCollection => 'Elimina raccolta';

  @override
  String get collectionName => 'Nome';

  @override
  String get collectionDescriptionOptional => 'Descrizione (facoltativa)';

  @override
  String get collectionNameEmpty => 'Il nome non può essere vuoto.';

  @override
  String get collectionNameDuplicate =>
      'Esiste già una raccolta con questo nome.';

  @override
  String deleteCollectionConfirm(String nome) {
    return 'Eliminare la raccolta «$nome»? Gli avvistamenti non verranno cancellati.';
  }

  @override
  String get addToCollection => 'Aggiungi a una raccolta';

  @override
  String get showOnMap => 'Mostra sulla mappa';

  @override
  String get addSightings => 'Aggiungi avvistamenti';

  @override
  String addSelectedCount(int count) {
    return 'Aggiungi ($count)';
  }

  @override
  String get allSightingsInCollection =>
      'Tutti i tuoi avvistamenti sono già in questa raccolta.';

  @override
  String get removeFromCollection => 'Togli dalla raccolta';

  @override
  String get removeFromCollectionConfirm =>
      'Togliere questo avvistamento dalla raccolta? Resta comunque nella tua collezione.';

  @override
  String get noCollectionsYet => 'Non hai ancora raccolte.';

  @override
  String get collectionsEmptyTitle => 'Nessuna raccolta';

  @override
  String get collectionsEmptySubtitle =>
      'Crea raccolte per organizzare i tuoi avvistamenti in gruppi.';

  @override
  String get identified => 'Identificati';

  @override
  String get identifiedSubtitle =>
      'Specie avvistate e documentate nei tuoi viaggi.';

  @override
  String get settings => 'Impostazioni';

  @override
  String get settingsSubtitle =>
      'Gestisci le preferenze del tuo diario di campo.';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountSubtitle => 'Gestisci profilo e condivisione';

  @override
  String get aboutTitle => 'Informazioni';

  @override
  String get aboutSubtitle => 'Versione dell\'app';

  @override
  String get languageSubtitle => 'Seleziona la lingua dell\'interfaccia';

  @override
  String get languageAutoShort => 'Auto';

  @override
  String get versionLabel => 'Versione';

  @override
  String get nonCommercialNote =>
      'MonkeyBirdie è un progetto non commerciale, a costo zero.';

  @override
  String get profileSaved => 'Profilo aggiornato.';

  @override
  String get statSharedSightings => 'Avvistamenti condivisi';

  @override
  String get statSpecies => 'Specie';

  @override
  String get favoriteBirds => 'Uccelli preferiti';

  @override
  String get recentSightings => 'Avvistamenti recenti';

  @override
  String get collectionsHeading => 'Le mie Raccolte';

  @override
  String get collectionsHeadingSub => 'Il tuo archivio di osservazioni.';

  @override
  String get startNewCollection => 'Inizia una nuova raccolta';

  @override
  String get startNewCollectionSub =>
      'Raggruppa le tue osservazioni per viaggio, stagione o habitat.';

  @override
  String get wishlistHeading => 'Lista dei desideri';

  @override
  String get wishlistHeadingSub =>
      'Specie che vorresti avvistare o che hai già incontrato.';

  @override
  String get addSpecies => 'Aggiungi specie';

  @override
  String get statusToSpot => 'Da avvistare';

  @override
  String get statusSpotted => 'Già avvistata';

  @override
  String get collectionDetailEmptyTitle => 'Raccolta vuota';

  @override
  String get collectionDetailEmptySubtitle =>
      'Aggiungi avvistamenti dalla Collezione (segnalibro) o dalla mappa.';

  @override
  String speciesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count specie',
      one: '1 specie',
      zero: 'Nessuna specie',
    );
    return '$_temp0';
  }

  @override
  String sightingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avvistamenti',
      one: '1 avvistamento',
      zero: 'Nessun avvistamento',
    );
    return '$_temp0';
  }

  @override
  String get locationUnavailable => 'Posizione non disponibile.';

  @override
  String get shareAllTitle => 'Condividi i miei avvistamenti';

  @override
  String get shareAllSubtitle =>
      'Gli amici vedranno tutti i tuoi avvistamenti sulla mappa e nel tuo profilo.';

  @override
  String get shareWithFriends => 'Condividi con gli amici';

  @override
  String get sharedWithFriends => 'Condiviso con gli amici';

  @override
  String spottedBy(String username) {
    return 'Avvistato da @$username';
  }

  @override
  String get sharedSightings => 'Avvistamenti condivisi';

  @override
  String get noSharedSightings => 'Nessun avvistamento condiviso.';

  @override
  String get friends => 'Amici';

  @override
  String get searchUsers => 'Cerca utenti';

  @override
  String get searchUsersHint => 'Cerca per username…';

  @override
  String get searchUsersTypeHint => 'Scrivi almeno 2 lettere.';

  @override
  String get searchUsersNoResults => 'Nessun utente trovato.';

  @override
  String get requests => 'Richieste';

  @override
  String get requestsIncoming => 'In arrivo';

  @override
  String get requestsOutgoing => 'In uscita';

  @override
  String get noFriendsTitle => 'Nessun amico';

  @override
  String get noFriendsSubtitle =>
      'Cerca utenti per username e invia una richiesta.';

  @override
  String get noRequestsTitle => 'Nessuna richiesta';

  @override
  String get noRequestsSubtitle =>
      'Le richieste in arrivo e in uscita compaiono qui.';

  @override
  String get addFriend => 'Aggiungi';

  @override
  String get cancelRequest => 'Annulla richiesta';

  @override
  String get accept => 'Accetta';

  @override
  String get reject => 'Rifiuta';

  @override
  String get friendLabel => 'Amico';

  @override
  String get removeFriend => 'Rimuovi amico';

  @override
  String removeFriendConfirm(String username) {
    return 'Rimuovere @$username dagli amici?';
  }

  @override
  String get retry => 'Riprova';
}
