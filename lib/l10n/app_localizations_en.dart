// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Monkey Bird';

  @override
  String get login => 'Sign in';

  @override
  String get email => 'Email';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get password => 'Password';

  @override
  String get passwordMin => 'At least 6 characters';

  @override
  String get noAccountRegister => 'No account? Sign up';

  @override
  String get register => 'Sign up';

  @override
  String get username => 'Username';

  @override
  String get usernameMin => 'At least 3 characters';

  @override
  String get createAccount => 'Create account';

  @override
  String get haveAccount => 'I already have an account';

  @override
  String get registrationEmailConfirm =>
      'Registration complete: confirm via email.';

  @override
  String get tabRecognize => 'Recognize';

  @override
  String get tabMap => 'Map';

  @override
  String get tabCollection => 'Collection';

  @override
  String get logout => 'Log out';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Automatic (system)';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languageEnglish => 'English';

  @override
  String get tapToRecord => 'Tap to record a song';

  @override
  String get orFromPhoto => 'or recognize from a photo';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get uploadPhoto => 'Upload photo';

  @override
  String get recordingTapToStop => 'Recording… tap to stop and analyze';

  @override
  String get analyzingSong => 'Analyzing the song…';

  @override
  String get analyzingPhoto => 'Analyzing the photo…';

  @override
  String get saving => 'Saving…';

  @override
  String get results => 'Results';

  @override
  String get chooseSpecies =>
      'Choose the correct species to save the sighting:';

  @override
  String get uncertainPhoto =>
      'I\'m not sure: the photo may be blurry or distant. Check the candidates or try again.';

  @override
  String get locationMissing =>
      'Location not detected: it will be saved without a precise position.';

  @override
  String get noSpecies => 'No species recognized. Try again.';

  @override
  String get notInCatalog => 'not in catalog';

  @override
  String get addedToCollection => 'Sighting added to your collection.';

  @override
  String get restart => 'Start over';

  @override
  String get sightingSaved => 'Sighting saved!';

  @override
  String get micPermissionDenied => 'Microphone permission denied.';

  @override
  String get cameraPermissionDenied => 'Camera permission denied.';

  @override
  String get galleryPermissionDenied => 'Gallery permission denied.';

  @override
  String get speciesNotInCatalog => 'Species not in catalog: cannot save.';

  @override
  String get emptyCollectionTitle => 'Empty collection';

  @override
  String get emptyCollectionSubtitle => 'Record a bird\'s song to get started.';

  @override
  String get speciesCard => 'Species card';

  @override
  String rarityLabel(String value) {
    return 'Rarity: $value';
  }

  @override
  String dangerLabel(String value) {
    return 'Danger: $value';
  }

  @override
  String get description => 'Description';

  @override
  String get habitat => 'Habitat';

  @override
  String get habitatComingSoon => 'Habitat map coming in Phase 2.';

  @override
  String get rarityCommon => 'common';

  @override
  String get rarityUncommon => 'uncommon';

  @override
  String get rarityRare => 'rare';

  @override
  String get rarityVeryRare => 'very rare';

  @override
  String get dangerNone => 'none';

  @override
  String get dangerLow => 'low';

  @override
  String get dangerMedium => 'medium';

  @override
  String get dangerHigh => 'high';

  @override
  String get confirmLocationTitle => 'Confirm the location';

  @override
  String get confirmLocationAuto => 'Drag the pin to fine-tune the spot.';

  @override
  String get confirmLocationManual => 'Tap the map to place the sighting.';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get mapEmptyTitle => 'No sightings on the map';

  @override
  String get mapEmptySubtitle =>
      'Save a sighting with a location to see it here.';

  @override
  String get mapUnavailable => 'Map unavailable (are you offline?).';

  @override
  String get speciesCardButton => 'Species card';

  @override
  String get searchPlaceHint => 'Search a place…';

  @override
  String get searchNoResults => 'No place found.';

  @override
  String get myLocation => 'My location';

  @override
  String get locationUnavailable => 'Location unavailable.';

  @override
  String get retry => 'Try again';
}
