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
  String get locationUnavailable => 'Posizione non disponibile.';

  @override
  String get retry => 'Riprova';
}
