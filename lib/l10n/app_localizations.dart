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
  /// **'Monkey Bird'**
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

  /// No description provided for @tabRecognize.
  ///
  /// In it, this message translates to:
  /// **'Riconosci'**
  String get tabRecognize;

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

  /// No description provided for @locationUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Posizione non disponibile.'**
  String get locationUnavailable;

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
