// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Monkey Bird';

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
  String get tabRecognize => 'Riconosci';

  @override
  String get tabMap => 'Mappa';

  @override
  String get tabCollection => 'Collezione';

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
  String get tabSightings => 'Avvistamenti';

  @override
  String get tabCollections => 'Raccolte';

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
  String get removeFromCollection => 'Togli dalla raccolta';

  @override
  String get noCollectionsYet => 'Non hai ancora raccolte.';

  @override
  String get collectionsEmptyTitle => 'Nessuna raccolta';

  @override
  String get collectionsEmptySubtitle =>
      'Crea raccolte per organizzare i tuoi avvistamenti in gruppi.';

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
  String get retry => 'Riprova';
}
