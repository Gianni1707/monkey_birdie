import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In it, this message translates to:
  /// **'MonkeyBirdie'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get login;

  /// No description provided for @email.
  ///
  /// In it, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailInvalid.
  ///
  /// In it, this message translates to:
  /// **'Email non valida'**
  String get emailInvalid;

  /// No description provided for @password.
  ///
  /// In it, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordMin.
  ///
  /// In it, this message translates to:
  /// **'Minimo 6 caratteri'**
  String get passwordMin;

  /// No description provided for @noAccountRegister.
  ///
  /// In it, this message translates to:
  /// **'Non hai un account? Registrati'**
  String get noAccountRegister;

  /// No description provided for @noAccountQuestion.
  ///
  /// In it, this message translates to:
  /// **'Non hai un account?'**
  String get noAccountQuestion;

  /// No description provided for @haveAccountQuestion.
  ///
  /// In it, this message translates to:
  /// **'Hai già un account?'**
  String get haveAccountQuestion;

  /// No description provided for @loginSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Il tuo diario di campo alato'**
  String get loginSubtitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Inizia la tua avventura ornitologica'**
  String get registerSubtitle;

  /// No description provided for @emailHint.
  ///
  /// In it, this message translates to:
  /// **'esempio@email.it'**
  String get emailHint;

  /// No description provided for @register.
  ///
  /// In it, this message translates to:
  /// **'Registrati'**
  String get register;

  /// No description provided for @username.
  ///
  /// In it, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameMin.
  ///
  /// In it, this message translates to:
  /// **'Minimo 3 caratteri'**
  String get usernameMin;

  /// No description provided for @usernameTaken.
  ///
  /// In it, this message translates to:
  /// **'Questo username è già in uso.'**
  String get usernameTaken;

  /// No description provided for @createAccount.
  ///
  /// In it, this message translates to:
  /// **'Crea account'**
  String get createAccount;

  /// No description provided for @haveAccount.
  ///
  /// In it, this message translates to:
  /// **'Ho già un account'**
  String get haveAccount;

  /// No description provided for @registrationEmailConfirm.
  ///
  /// In it, this message translates to:
  /// **'Registrazione completata: conferma via email.'**
  String get registrationEmailConfirm;

  /// No description provided for @forgotPassword.
  ///
  /// In it, this message translates to:
  /// **'Password dimenticata?'**
  String get forgotPassword;

  /// No description provided for @recoverPasswordTitle.
  ///
  /// In it, this message translates to:
  /// **'Recupera password'**
  String get recoverPasswordTitle;

  /// No description provided for @recoverPasswordSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Inserisci la tua email: ti invieremo un link per reimpostare la password.'**
  String get recoverPasswordSubtitle;

  /// No description provided for @sendRecoveryLink.
  ///
  /// In it, this message translates to:
  /// **'Invia link di recupero'**
  String get sendRecoveryLink;

  /// No description provided for @recoveryEmailSent.
  ///
  /// In it, this message translates to:
  /// **'Se esiste un account con quell\'indirizzo, ti abbiamo inviato un\'email con il link per reimpostare la password.'**
  String get recoveryEmailSent;

  /// No description provided for @backToLogin.
  ///
  /// In it, this message translates to:
  /// **'Torna all\'accesso'**
  String get backToLogin;

  /// No description provided for @newPasswordTitle.
  ///
  /// In it, this message translates to:
  /// **'Nuova password'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Scegli una nuova password per il tuo account.'**
  String get newPasswordSubtitle;

  /// No description provided for @newPassword.
  ///
  /// In it, this message translates to:
  /// **'Nuova password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In it, this message translates to:
  /// **'Conferma password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In it, this message translates to:
  /// **'Le password non coincidono'**
  String get passwordsDoNotMatch;

  /// No description provided for @updatePassword.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna password'**
  String get updatePassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In it, this message translates to:
  /// **'Password aggiornata. Ora sei connesso.'**
  String get passwordUpdated;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In it, this message translates to:
  /// **'Aggiornamento disponibile'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In it, this message translates to:
  /// **'È disponibile la versione {versione}.'**
  String updateAvailableBody(String versione);

  /// No description provided for @updateLater.
  ///
  /// In it, this message translates to:
  /// **'Più tardi'**
  String get updateLater;

  /// No description provided for @updateDownload.
  ///
  /// In it, this message translates to:
  /// **'Scarica'**
  String get updateDownload;

  /// No description provided for @tabRecognize.
  ///
  /// In it, this message translates to:
  /// **'Riconosci'**
  String get tabRecognize;

  /// No description provided for @tabHome.
  ///
  /// In it, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabMap.
  ///
  /// In it, this message translates to:
  /// **'Mappa'**
  String get tabMap;

  /// No description provided for @tabCollection.
  ///
  /// In it, this message translates to:
  /// **'Collezione'**
  String get tabCollection;

  /// No description provided for @homeWelcome.
  ///
  /// In it, this message translates to:
  /// **'Benvenuto {name}'**
  String homeWelcome(String name);

  /// No description provided for @homeSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Pronto per una nuova scoperta?'**
  String get homeSubtitle;

  /// No description provided for @homeAudioTitle.
  ///
  /// In it, this message translates to:
  /// **'Audio'**
  String get homeAudioTitle;

  /// No description provided for @homeAudioHint.
  ///
  /// In it, this message translates to:
  /// **'Ascolta il canto'**
  String get homeAudioHint;

  /// No description provided for @homePhotoTitle.
  ///
  /// In it, this message translates to:
  /// **'Foto'**
  String get homePhotoTitle;

  /// No description provided for @homePhotoHint.
  ///
  /// In it, this message translates to:
  /// **'Cattura l’istante'**
  String get homePhotoHint;

  /// No description provided for @homeLatestSightings.
  ///
  /// In it, this message translates to:
  /// **'I tuoi ultimi avvistamenti'**
  String get homeLatestSightings;

  /// No description provided for @seeAll.
  ///
  /// In it, this message translates to:
  /// **'Vedi tutti'**
  String get seeAll;

  /// No description provided for @newsAndGuides.
  ///
  /// In it, this message translates to:
  /// **'News e guide'**
  String get newsAndGuides;

  /// No description provided for @tipOfTheDay.
  ///
  /// In it, this message translates to:
  /// **'Consiglio del giorno'**
  String get tipOfTheDay;

  /// No description provided for @inThisPeriod.
  ///
  /// In it, this message translates to:
  /// **'In questo periodo'**
  String get inThisPeriod;

  /// No description provided for @birdOfTheDay.
  ///
  /// In it, this message translates to:
  /// **'Uccello del giorno'**
  String get birdOfTheDay;

  /// No description provided for @guidesTitle.
  ///
  /// In it, this message translates to:
  /// **'Guide e consigli'**
  String get guidesTitle;

  /// No description provided for @logout.
  ///
  /// In it, this message translates to:
  /// **'Esci'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In it, this message translates to:
  /// **'Automatica (sistema)'**
  String get languageSystem;

  /// No description provided for @languageItalian.
  ///
  /// In it, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// No description provided for @languageEnglish.
  ///
  /// In it, this message translates to:
  /// **'Inglese'**
  String get languageEnglish;

  /// No description provided for @tapToRecord.
  ///
  /// In it, this message translates to:
  /// **'Tocca per registrare un canto'**
  String get tapToRecord;

  /// No description provided for @orFromPhoto.
  ///
  /// In it, this message translates to:
  /// **'oppure riconosci da una foto'**
  String get orFromPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In it, this message translates to:
  /// **'Scatta foto'**
  String get takePhoto;

  /// No description provided for @uploadPhoto.
  ///
  /// In it, this message translates to:
  /// **'Carica foto'**
  String get uploadPhoto;

  /// No description provided for @recordingTapToStop.
  ///
  /// In it, this message translates to:
  /// **'Registrazione… tocca per fermare e analizzare'**
  String get recordingTapToStop;

  /// No description provided for @analyzingSong.
  ///
  /// In it, this message translates to:
  /// **'Analisi del canto…'**
  String get analyzingSong;

  /// No description provided for @analyzingPhoto.
  ///
  /// In it, this message translates to:
  /// **'Analisi della foto…'**
  String get analyzingPhoto;

  /// No description provided for @saving.
  ///
  /// In it, this message translates to:
  /// **'Salvataggio…'**
  String get saving;

  /// No description provided for @results.
  ///
  /// In it, this message translates to:
  /// **'Risultati'**
  String get results;

  /// No description provided for @resultsIntro.
  ///
  /// In it, this message translates to:
  /// **'Ecco i risultati più probabili del riconoscimento.'**
  String get resultsIntro;

  /// No description provided for @bestMatch.
  ///
  /// In it, this message translates to:
  /// **'Migliore corrispondenza'**
  String get bestMatch;

  /// No description provided for @otherPossibilities.
  ///
  /// In it, this message translates to:
  /// **'Altre possibilità'**
  String get otherPossibilities;

  /// No description provided for @notSure.
  ///
  /// In it, this message translates to:
  /// **'Non sono sicuro'**
  String get notSure;

  /// No description provided for @confirmAndSave.
  ///
  /// In it, this message translates to:
  /// **'Conferma e salva'**
  String get confirmAndSave;

  /// No description provided for @chooseSpecies.
  ///
  /// In it, this message translates to:
  /// **'Scegli la specie corretta per salvare l’avvistamento:'**
  String get chooseSpecies;

  /// No description provided for @uncertainPhoto.
  ///
  /// In it, this message translates to:
  /// **'Non sono sicuro: la foto potrebbe essere sfocata o lontana. Controlla i candidati o riprova.'**
  String get uncertainPhoto;

  /// No description provided for @locationMissing.
  ///
  /// In it, this message translates to:
  /// **'Posizione non rilevata: verrà salvato senza posizione precisa.'**
  String get locationMissing;

  /// No description provided for @noSpecies.
  ///
  /// In it, this message translates to:
  /// **'Nessuna specie riconosciuta. Riprova.'**
  String get noSpecies;

  /// No description provided for @notInCatalog.
  ///
  /// In it, this message translates to:
  /// **'non in catalogo'**
  String get notInCatalog;

  /// No description provided for @addedToCollection.
  ///
  /// In it, this message translates to:
  /// **'Avvistamento aggiunto alla collezione.'**
  String get addedToCollection;

  /// No description provided for @restart.
  ///
  /// In it, this message translates to:
  /// **'Ricomincia'**
  String get restart;

  /// No description provided for @sightingSaved.
  ///
  /// In it, this message translates to:
  /// **'Avvistamento salvato!'**
  String get sightingSaved;

  /// No description provided for @micPermissionDenied.
  ///
  /// In it, this message translates to:
  /// **'Permesso microfono negato.'**
  String get micPermissionDenied;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In it, this message translates to:
  /// **'Permesso fotocamera negato.'**
  String get cameraPermissionDenied;

  /// No description provided for @galleryPermissionDenied.
  ///
  /// In it, this message translates to:
  /// **'Permesso galleria negato.'**
  String get galleryPermissionDenied;

  /// No description provided for @speciesNotInCatalog.
  ///
  /// In it, this message translates to:
  /// **'Specie non presente in catalogo: impossibile salvare.'**
  String get speciesNotInCatalog;

  /// No description provided for @emptyCollectionTitle.
  ///
  /// In it, this message translates to:
  /// **'Collezione vuota'**
  String get emptyCollectionTitle;

  /// No description provided for @emptyCollectionSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Registra il canto di un uccello per iniziare.'**
  String get emptyCollectionSubtitle;

  /// No description provided for @speciesCard.
  ///
  /// In it, this message translates to:
  /// **'Scheda specie'**
  String get speciesCard;

  /// No description provided for @rarityLabel.
  ///
  /// In it, this message translates to:
  /// **'Rarità: {value}'**
  String rarityLabel(String value);

  /// No description provided for @dangerLabel.
  ///
  /// In it, this message translates to:
  /// **'Pericolo: {value}'**
  String dangerLabel(String value);

  /// No description provided for @description.
  ///
  /// In it, this message translates to:
  /// **'Descrizione'**
  String get description;

  /// No description provided for @habitat.
  ///
  /// In it, this message translates to:
  /// **'Habitat'**
  String get habitat;

  /// No description provided for @habitatComingSoon.
  ///
  /// In it, this message translates to:
  /// **'Mappa dell’habitat in arrivo nella Fase 2.'**
  String get habitatComingSoon;

  /// No description provided for @whereItLives.
  ///
  /// In it, this message translates to:
  /// **'Dove vive'**
  String get whereItLives;

  /// No description provided for @morphology.
  ///
  /// In it, this message translates to:
  /// **'Morfologia'**
  String get morphology;

  /// No description provided for @lengthLabel.
  ///
  /// In it, this message translates to:
  /// **'Lunghezza'**
  String get lengthLabel;

  /// No description provided for @weightLabel.
  ///
  /// In it, this message translates to:
  /// **'Peso'**
  String get weightLabel;

  /// No description provided for @eggsLabel.
  ///
  /// In it, this message translates to:
  /// **'Uova'**
  String get eggsLabel;

  /// No description provided for @nestLabel.
  ///
  /// In it, this message translates to:
  /// **'Nido'**
  String get nestLabel;

  /// No description provided for @notAvailable.
  ///
  /// In it, this message translates to:
  /// **'n/d'**
  String get notAvailable;

  /// No description provided for @morphologySource.
  ///
  /// In it, this message translates to:
  /// **'Dati morfologici: BIRDBASE'**
  String get morphologySource;

  /// No description provided for @descriptionSource.
  ///
  /// In it, this message translates to:
  /// **'Fonte: {fonte}'**
  String descriptionSource(String fonte);

  /// No description provided for @share.
  ///
  /// In it, this message translates to:
  /// **'Condividi'**
  String get share;

  /// No description provided for @habitatDistribution.
  ///
  /// In it, this message translates to:
  /// **'Habitat e distribuzione'**
  String get habitatDistribution;

  /// No description provided for @distributionSource.
  ///
  /// In it, this message translates to:
  /// **'Dati di distribuzione: GBIF'**
  String get distributionSource;

  /// No description provided for @distributionUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Dati di distribuzione non disponibili.'**
  String get distributionUnavailable;

  /// No description provided for @tapToExpand.
  ///
  /// In it, this message translates to:
  /// **'Tocca per ingrandire'**
  String get tapToExpand;

  /// No description provided for @rarityCommon.
  ///
  /// In it, this message translates to:
  /// **'comune'**
  String get rarityCommon;

  /// No description provided for @rarityUncommon.
  ///
  /// In it, this message translates to:
  /// **'poco comune'**
  String get rarityUncommon;

  /// No description provided for @rarityRare.
  ///
  /// In it, this message translates to:
  /// **'rara'**
  String get rarityRare;

  /// No description provided for @rarityVeryRare.
  ///
  /// In it, this message translates to:
  /// **'molto rara'**
  String get rarityVeryRare;

  /// No description provided for @dangerNone.
  ///
  /// In it, this message translates to:
  /// **'nessuno'**
  String get dangerNone;

  /// No description provided for @dangerLow.
  ///
  /// In it, this message translates to:
  /// **'basso'**
  String get dangerLow;

  /// No description provided for @dangerMedium.
  ///
  /// In it, this message translates to:
  /// **'medio'**
  String get dangerMedium;

  /// No description provided for @dangerHigh.
  ///
  /// In it, this message translates to:
  /// **'alto'**
  String get dangerHigh;

  /// No description provided for @tabProfile.
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get tabProfile;

  /// No description provided for @editProfile.
  ///
  /// In it, this message translates to:
  /// **'Modifica profilo'**
  String get editProfile;

  /// No description provided for @bio.
  ///
  /// In it, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @profileBioEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna bio. Tocca «Modifica profilo» per aggiungerne una.'**
  String get profileBioEmpty;

  /// No description provided for @nameField.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get nameField;

  /// No description provided for @locationField.
  ///
  /// In it, this message translates to:
  /// **'Località'**
  String get locationField;

  /// No description provided for @experienceField.
  ///
  /// In it, this message translates to:
  /// **'Livello di esperienza'**
  String get experienceField;

  /// No description provided for @experienceUnset.
  ///
  /// In it, this message translates to:
  /// **'Non impostato'**
  String get experienceUnset;

  /// No description provided for @experienceBeginner.
  ///
  /// In it, this message translates to:
  /// **'Principiante'**
  String get experienceBeginner;

  /// No description provided for @experienceIntermediate.
  ///
  /// In it, this message translates to:
  /// **'Intermedio'**
  String get experienceIntermediate;

  /// No description provided for @experienceExpert.
  ///
  /// In it, this message translates to:
  /// **'Esperto'**
  String get experienceExpert;

  /// No description provided for @experiencePreferNotToSay.
  ///
  /// In it, this message translates to:
  /// **'Preferisco non dirlo'**
  String get experiencePreferNotToSay;

  /// No description provided for @levelBeginner.
  ///
  /// In it, this message translates to:
  /// **'Principiante'**
  String get levelBeginner;

  /// No description provided for @levelEnthusiast.
  ///
  /// In it, this message translates to:
  /// **'Appassionato'**
  String get levelEnthusiast;

  /// No description provided for @levelExpert.
  ///
  /// In it, this message translates to:
  /// **'Esperto'**
  String get levelExpert;

  /// No description provided for @levelMaster.
  ///
  /// In it, this message translates to:
  /// **'Maestro'**
  String get levelMaster;

  /// No description provided for @levelMax.
  ///
  /// In it, this message translates to:
  /// **'livello massimo raggiunto'**
  String get levelMax;

  /// No description provided for @levelProgress.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{ancora 1 specie al prossimo livello} other{ancora {count} specie al prossimo livello}}'**
  String levelProgress(int count);

  /// No description provided for @removePhoto.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi foto'**
  String get removePhoto;

  /// No description provided for @favorites.
  ///
  /// In it, this message translates to:
  /// **'Uccelli preferiti'**
  String get favorites;

  /// No description provided for @addFavorite.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi preferito'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In it, this message translates to:
  /// **'Togli dai preferiti'**
  String get removeFavorite;

  /// No description provided for @noFavorites.
  ///
  /// In it, this message translates to:
  /// **'Nessun preferito. Aggiungi le specie che ami dal catalogo.'**
  String get noFavorites;

  /// No description provided for @searchSpeciesHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca una specie…'**
  String get searchSpeciesHint;

  /// No description provided for @searchSpeciesTypeHint.
  ///
  /// In it, this message translates to:
  /// **'Scrivi almeno 2 lettere per cercare una specie.'**
  String get searchSpeciesTypeHint;

  /// No description provided for @searchSpeciesNoResults.
  ///
  /// In it, this message translates to:
  /// **'Nessuna specie trovata.'**
  String get searchSpeciesNoResults;

  /// No description provided for @confirmLocationTitle.
  ///
  /// In it, this message translates to:
  /// **'Conferma la posizione'**
  String get confirmLocationTitle;

  /// No description provided for @confirmLocationAuto.
  ///
  /// In it, this message translates to:
  /// **'Trascina il segnaposto per correggere il punto.'**
  String get confirmLocationAuto;

  /// No description provided for @confirmLocationManual.
  ///
  /// In it, this message translates to:
  /// **'Tocca la mappa per posizionare l’avvistamento.'**
  String get confirmLocationManual;

  /// No description provided for @confirm.
  ///
  /// In it, this message translates to:
  /// **'Conferma'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancel;

  /// No description provided for @mapEmptyTitle.
  ///
  /// In it, this message translates to:
  /// **'Nessun avvistamento sulla mappa'**
  String get mapEmptyTitle;

  /// No description provided for @mapEmptySubtitle.
  ///
  /// In it, this message translates to:
  /// **'Salva un avvistamento con la posizione per vederlo qui.'**
  String get mapEmptySubtitle;

  /// No description provided for @mapUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Mappa non disponibile (sei offline?).'**
  String get mapUnavailable;

  /// No description provided for @speciesCardButton.
  ///
  /// In it, this message translates to:
  /// **'Scheda specie'**
  String get speciesCardButton;

  /// No description provided for @searchPlaceHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca un luogo…'**
  String get searchPlaceHint;

  /// No description provided for @searchNoResults.
  ///
  /// In it, this message translates to:
  /// **'Nessun luogo trovato.'**
  String get searchNoResults;

  /// No description provided for @myLocation.
  ///
  /// In it, this message translates to:
  /// **'La mia posizione'**
  String get myLocation;

  /// No description provided for @tabSightings.
  ///
  /// In it, this message translates to:
  /// **'Avvistati'**
  String get tabSightings;

  /// No description provided for @tabCollections.
  ///
  /// In it, this message translates to:
  /// **'Raccolte'**
  String get tabCollections;

  /// No description provided for @deleteSighting.
  ///
  /// In it, this message translates to:
  /// **'Elimina avvistamento'**
  String get deleteSighting;

  /// No description provided for @deleteSightingTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare l’avvistamento?'**
  String get deleteSightingTitle;

  /// No description provided for @deleteSightingBody.
  ///
  /// In it, this message translates to:
  /// **'L’azione è irreversibile.'**
  String get deleteSightingBody;

  /// No description provided for @deleteAction.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get deleteAction;

  /// No description provided for @sightingDeleted.
  ///
  /// In it, this message translates to:
  /// **'Avvistamento eliminato.'**
  String get sightingDeleted;

  /// No description provided for @tabWishlist.
  ///
  /// In it, this message translates to:
  /// **'Desideri'**
  String get tabWishlist;

  /// No description provided for @addToWishlist.
  ///
  /// In it, this message translates to:
  /// **'Voglio avvistarlo'**
  String get addToWishlist;

  /// No description provided for @removeFromWishlist.
  ///
  /// In it, this message translates to:
  /// **'Togli dai desideri'**
  String get removeFromWishlist;

  /// No description provided for @emptyWishlistTitle.
  ///
  /// In it, this message translates to:
  /// **'Nessun desiderio'**
  String get emptyWishlistTitle;

  /// No description provided for @emptyWishlistSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi le specie che vuoi ancora avvistare.'**
  String get emptyWishlistSubtitle;

  /// No description provided for @alreadySpotted.
  ///
  /// In it, this message translates to:
  /// **'Già avvistata 🎉'**
  String get alreadySpotted;

  /// No description provided for @wishlistNote.
  ///
  /// In it, this message translates to:
  /// **'Nota'**
  String get wishlistNote;

  /// No description provided for @wishlistNoteHint.
  ///
  /// In it, this message translates to:
  /// **'Nota (opzionale)'**
  String get wishlistNoteHint;

  /// No description provided for @dangerNotReported.
  ///
  /// In it, this message translates to:
  /// **'non segnalato'**
  String get dangerNotReported;

  /// No description provided for @difficultyEstimateLabel.
  ///
  /// In it, this message translates to:
  /// **'Difficoltà (stima): {value}'**
  String difficultyEstimateLabel(String value);

  /// No description provided for @difficultyCommon.
  ///
  /// In it, this message translates to:
  /// **'comune'**
  String get difficultyCommon;

  /// No description provided for @difficultyUncommon.
  ///
  /// In it, this message translates to:
  /// **'poco comune'**
  String get difficultyUncommon;

  /// No description provided for @difficultyHard.
  ///
  /// In it, this message translates to:
  /// **'difficile'**
  String get difficultyHard;

  /// No description provided for @difficultyVeryRare.
  ///
  /// In it, this message translates to:
  /// **'molto raro'**
  String get difficultyVeryRare;

  /// No description provided for @difficultyNA.
  ///
  /// In it, this message translates to:
  /// **'n/d'**
  String get difficultyNA;

  /// No description provided for @collections.
  ///
  /// In it, this message translates to:
  /// **'Raccolte'**
  String get collections;

  /// No description provided for @newCollection.
  ///
  /// In it, this message translates to:
  /// **'Nuova raccolta'**
  String get newCollection;

  /// No description provided for @create.
  ///
  /// In it, this message translates to:
  /// **'Crea'**
  String get create;

  /// No description provided for @save.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get save;

  /// No description provided for @done.
  ///
  /// In it, this message translates to:
  /// **'Fatto'**
  String get done;

  /// No description provided for @delete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get delete;

  /// No description provided for @renameCollection.
  ///
  /// In it, this message translates to:
  /// **'Rinomina'**
  String get renameCollection;

  /// No description provided for @deleteCollection.
  ///
  /// In it, this message translates to:
  /// **'Elimina raccolta'**
  String get deleteCollection;

  /// No description provided for @collectionName.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get collectionName;

  /// No description provided for @collectionDescriptionOptional.
  ///
  /// In it, this message translates to:
  /// **'Descrizione (facoltativa)'**
  String get collectionDescriptionOptional;

  /// No description provided for @collectionNameEmpty.
  ///
  /// In it, this message translates to:
  /// **'Il nome non può essere vuoto.'**
  String get collectionNameEmpty;

  /// No description provided for @collectionNameDuplicate.
  ///
  /// In it, this message translates to:
  /// **'Esiste già una raccolta con questo nome.'**
  String get collectionNameDuplicate;

  /// No description provided for @deleteCollectionConfirm.
  ///
  /// In it, this message translates to:
  /// **'Eliminare la raccolta «{nome}»? Gli avvistamenti non verranno cancellati.'**
  String deleteCollectionConfirm(String nome);

  /// No description provided for @addToCollection.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi a una raccolta'**
  String get addToCollection;

  /// No description provided for @showOnMap.
  ///
  /// In it, this message translates to:
  /// **'Mostra sulla mappa'**
  String get showOnMap;

  /// No description provided for @addSightings.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi avvistamenti'**
  String get addSightings;

  /// No description provided for @addSelectedCount.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi ({count})'**
  String addSelectedCount(int count);

  /// No description provided for @allSightingsInCollection.
  ///
  /// In it, this message translates to:
  /// **'Tutti i tuoi avvistamenti sono già in questa raccolta.'**
  String get allSightingsInCollection;

  /// No description provided for @removeFromCollection.
  ///
  /// In it, this message translates to:
  /// **'Togli dalla raccolta'**
  String get removeFromCollection;

  /// No description provided for @removeFromCollectionConfirm.
  ///
  /// In it, this message translates to:
  /// **'Togliere questo avvistamento dalla raccolta? Resta comunque nella tua collezione.'**
  String get removeFromCollectionConfirm;

  /// No description provided for @noCollectionsYet.
  ///
  /// In it, this message translates to:
  /// **'Non hai ancora raccolte.'**
  String get noCollectionsYet;

  /// No description provided for @collectionsEmptyTitle.
  ///
  /// In it, this message translates to:
  /// **'Nessuna raccolta'**
  String get collectionsEmptyTitle;

  /// No description provided for @collectionsEmptySubtitle.
  ///
  /// In it, this message translates to:
  /// **'Crea raccolte per organizzare i tuoi avvistamenti in gruppi.'**
  String get collectionsEmptySubtitle;

  /// No description provided for @identified.
  ///
  /// In it, this message translates to:
  /// **'Identificati'**
  String get identified;

  /// No description provided for @identifiedSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Specie avvistate e documentate nei tuoi viaggi.'**
  String get identifiedSubtitle;

  /// No description provided for @settings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settings;

  /// No description provided for @settingsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Gestisci le preferenze del tuo diario di campo.'**
  String get settingsSubtitle;

  /// No description provided for @accountTitle.
  ///
  /// In it, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Gestisci profilo e condivisione'**
  String get accountSubtitle;

  /// No description provided for @aboutTitle.
  ///
  /// In it, this message translates to:
  /// **'Informazioni'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Versione dell\'app'**
  String get aboutSubtitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Seleziona la lingua dell\'interfaccia'**
  String get languageSubtitle;

  /// No description provided for @languageAutoShort.
  ///
  /// In it, this message translates to:
  /// **'Auto'**
  String get languageAutoShort;

  /// No description provided for @versionLabel.
  ///
  /// In it, this message translates to:
  /// **'Versione'**
  String get versionLabel;

  /// No description provided for @nonCommercialNote.
  ///
  /// In it, this message translates to:
  /// **'MonkeyBirdie è un progetto non commerciale, a costo zero.'**
  String get nonCommercialNote;

  /// No description provided for @profileSaved.
  ///
  /// In it, this message translates to:
  /// **'Profilo aggiornato.'**
  String get profileSaved;

  /// No description provided for @statSharedSightings.
  ///
  /// In it, this message translates to:
  /// **'Avvistamenti condivisi'**
  String get statSharedSightings;

  /// No description provided for @statSpecies.
  ///
  /// In it, this message translates to:
  /// **'Specie'**
  String get statSpecies;

  /// No description provided for @favoriteBirds.
  ///
  /// In it, this message translates to:
  /// **'Uccelli preferiti'**
  String get favoriteBirds;

  /// No description provided for @recentSightings.
  ///
  /// In it, this message translates to:
  /// **'Avvistamenti recenti'**
  String get recentSightings;

  /// No description provided for @collectionsHeading.
  ///
  /// In it, this message translates to:
  /// **'Le mie Raccolte'**
  String get collectionsHeading;

  /// No description provided for @collectionsHeadingSub.
  ///
  /// In it, this message translates to:
  /// **'Il tuo archivio di osservazioni.'**
  String get collectionsHeadingSub;

  /// No description provided for @startNewCollection.
  ///
  /// In it, this message translates to:
  /// **'Inizia una nuova raccolta'**
  String get startNewCollection;

  /// No description provided for @startNewCollectionSub.
  ///
  /// In it, this message translates to:
  /// **'Raggruppa le tue osservazioni per viaggio, stagione o habitat.'**
  String get startNewCollectionSub;

  /// No description provided for @wishlistHeading.
  ///
  /// In it, this message translates to:
  /// **'Lista dei desideri'**
  String get wishlistHeading;

  /// No description provided for @wishlistHeadingSub.
  ///
  /// In it, this message translates to:
  /// **'Specie che vorresti avvistare o che hai già incontrato.'**
  String get wishlistHeadingSub;

  /// No description provided for @addSpecies.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi specie'**
  String get addSpecies;

  /// No description provided for @statusToSpot.
  ///
  /// In it, this message translates to:
  /// **'Da avvistare'**
  String get statusToSpot;

  /// No description provided for @statusSpotted.
  ///
  /// In it, this message translates to:
  /// **'Già avvistata'**
  String get statusSpotted;

  /// No description provided for @collectionDetailEmptyTitle.
  ///
  /// In it, this message translates to:
  /// **'Raccolta vuota'**
  String get collectionDetailEmptyTitle;

  /// No description provided for @collectionDetailEmptySubtitle.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi avvistamenti dalla Collezione (segnalibro) o dalla mappa.'**
  String get collectionDetailEmptySubtitle;

  /// No description provided for @speciesCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =0{Nessuna specie} =1{1 specie} other{{count} specie}}'**
  String speciesCount(int count);

  /// No description provided for @sightingsCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =0{Nessun avvistamento} =1{1 avvistamento} other{{count} avvistamenti}}'**
  String sightingsCount(int count);

  /// No description provided for @locationUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Posizione non disponibile.'**
  String get locationUnavailable;

  /// No description provided for @shareAllTitle.
  ///
  /// In it, this message translates to:
  /// **'Condividi i miei avvistamenti'**
  String get shareAllTitle;

  /// No description provided for @shareAllSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Gli amici vedranno tutti i tuoi avvistamenti sulla mappa e nel tuo profilo.'**
  String get shareAllSubtitle;

  /// No description provided for @shareWithFriends.
  ///
  /// In it, this message translates to:
  /// **'Condividi con gli amici'**
  String get shareWithFriends;

  /// No description provided for @sharedWithFriends.
  ///
  /// In it, this message translates to:
  /// **'Condiviso con gli amici'**
  String get sharedWithFriends;

  /// No description provided for @spottedBy.
  ///
  /// In it, this message translates to:
  /// **'Avvistato da @{username}'**
  String spottedBy(String username);

  /// No description provided for @sharedSightings.
  ///
  /// In it, this message translates to:
  /// **'Avvistamenti condivisi'**
  String get sharedSightings;

  /// No description provided for @noSharedSightings.
  ///
  /// In it, this message translates to:
  /// **'Nessun avvistamento condiviso.'**
  String get noSharedSightings;

  /// No description provided for @friends.
  ///
  /// In it, this message translates to:
  /// **'Amici'**
  String get friends;

  /// No description provided for @searchUsers.
  ///
  /// In it, this message translates to:
  /// **'Cerca utenti'**
  String get searchUsers;

  /// No description provided for @searchUsersHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca per username…'**
  String get searchUsersHint;

  /// No description provided for @searchUsersTypeHint.
  ///
  /// In it, this message translates to:
  /// **'Scrivi almeno 2 lettere.'**
  String get searchUsersTypeHint;

  /// No description provided for @searchUsersNoResults.
  ///
  /// In it, this message translates to:
  /// **'Nessun utente trovato.'**
  String get searchUsersNoResults;

  /// No description provided for @requests.
  ///
  /// In it, this message translates to:
  /// **'Richieste'**
  String get requests;

  /// No description provided for @requestsIncoming.
  ///
  /// In it, this message translates to:
  /// **'In arrivo'**
  String get requestsIncoming;

  /// No description provided for @requestsOutgoing.
  ///
  /// In it, this message translates to:
  /// **'In uscita'**
  String get requestsOutgoing;

  /// No description provided for @noFriendsTitle.
  ///
  /// In it, this message translates to:
  /// **'Nessun amico'**
  String get noFriendsTitle;

  /// No description provided for @noFriendsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Cerca utenti per username e invia una richiesta.'**
  String get noFriendsSubtitle;

  /// No description provided for @noRequestsTitle.
  ///
  /// In it, this message translates to:
  /// **'Nessuna richiesta'**
  String get noRequestsTitle;

  /// No description provided for @noRequestsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Le richieste in arrivo e in uscita compaiono qui.'**
  String get noRequestsSubtitle;

  /// No description provided for @addFriend.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get addFriend;

  /// No description provided for @cancelRequest.
  ///
  /// In it, this message translates to:
  /// **'Annulla richiesta'**
  String get cancelRequest;

  /// No description provided for @accept.
  ///
  /// In it, this message translates to:
  /// **'Accetta'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In it, this message translates to:
  /// **'Rifiuta'**
  String get reject;

  /// No description provided for @friendLabel.
  ///
  /// In it, this message translates to:
  /// **'Amico'**
  String get friendLabel;

  /// No description provided for @removeFriend.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi amico'**
  String get removeFriend;

  /// No description provided for @removeFriendConfirm.
  ///
  /// In it, this message translates to:
  /// **'Rimuovere @{username} dagli amici?'**
  String removeFriendConfirm(String username);

  /// No description provided for @retry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get retry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
