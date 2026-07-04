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
  String get usernameTaken => 'This username is already taken.';

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
  String get tabProfile => 'Profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get bio => 'Bio';

  @override
  String get profileBioEmpty => 'No bio yet. Tap “Edit profile” to add one.';

  @override
  String get nameField => 'Name';

  @override
  String get locationField => 'Location';

  @override
  String get experienceField => 'Experience level';

  @override
  String get experienceUnset => 'Not set';

  @override
  String get experienceBeginner => 'Beginner';

  @override
  String get experienceIntermediate => 'Intermediate';

  @override
  String get experienceExpert => 'Expert';

  @override
  String get experiencePreferNotToSay => 'Prefer not to say';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelEnthusiast => 'Enthusiast';

  @override
  String get levelExpert => 'Expert';

  @override
  String get levelMaster => 'Master';

  @override
  String get levelMax => 'top level reached';

  @override
  String levelProgress(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more species to the next level',
      one: '1 more species to the next level',
    );
    return '$_temp0';
  }

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get favorites => 'Favorite birds';

  @override
  String get addFavorite => 'Add favorite';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get noFavorites =>
      'No favorites yet. Add the species you love from the catalog.';

  @override
  String get searchSpeciesHint => 'Search a species…';

  @override
  String get searchSpeciesTypeHint =>
      'Type at least 2 letters to search a species.';

  @override
  String get searchSpeciesNoResults => 'No species found.';

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
  String get tabSightings => 'Sightings';

  @override
  String get tabCollections => 'Collections';

  @override
  String get collections => 'Collections';

  @override
  String get newCollection => 'New collection';

  @override
  String get create => 'Create';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get delete => 'Delete';

  @override
  String get renameCollection => 'Rename';

  @override
  String get deleteCollection => 'Delete collection';

  @override
  String get collectionName => 'Name';

  @override
  String get collectionDescriptionOptional => 'Description (optional)';

  @override
  String get collectionNameEmpty => 'The name can\'t be empty.';

  @override
  String get collectionNameDuplicate =>
      'A collection with this name already exists.';

  @override
  String deleteCollectionConfirm(String nome) {
    return 'Delete the collection “$nome”? The sightings won\'t be deleted.';
  }

  @override
  String get addToCollection => 'Add to a collection';

  @override
  String get removeFromCollection => 'Remove from collection';

  @override
  String get noCollectionsYet => 'You don\'t have any collections yet.';

  @override
  String get collectionsEmptyTitle => 'No collections';

  @override
  String get collectionsEmptySubtitle =>
      'Create collections to organize your sightings into groups.';

  @override
  String get collectionDetailEmptyTitle => 'Empty collection';

  @override
  String get collectionDetailEmptySubtitle =>
      'Add sightings from the Collection (bookmark) or from the map.';

  @override
  String speciesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count species',
      one: '1 species',
      zero: 'No species',
    );
    return '$_temp0';
  }

  @override
  String sightingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sightings',
      one: '1 sighting',
      zero: 'No sightings',
    );
    return '$_temp0';
  }

  @override
  String get locationUnavailable => 'Location unavailable.';

  @override
  String get retry => 'Try again';
}
