// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MonkeyBirdie';

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
  String get noAccountQuestion => 'Don\'t have an account?';

  @override
  String get haveAccountQuestion => 'Already have an account?';

  @override
  String get loginSubtitle => 'Your winged field journal';

  @override
  String get registerSubtitle => 'Start your birding adventure';

  @override
  String get emailHint => 'example@email.com';

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
  String get tabHome => 'Home';

  @override
  String get tabMap => 'Map';

  @override
  String get tabCollection => 'Collection';

  @override
  String homeWelcome(String name) {
    return 'Welcome $name';
  }

  @override
  String get homeSubtitle => 'Ready for a new discovery?';

  @override
  String get homeAudioTitle => 'Audio';

  @override
  String get homeAudioHint => 'Listen to the song';

  @override
  String get homePhotoTitle => 'Photo';

  @override
  String get homePhotoHint => 'Capture the moment';

  @override
  String get homeLatestSightings => 'Your latest sightings';

  @override
  String get seeAll => 'See all';

  @override
  String get newsAndGuides => 'News & guides';

  @override
  String get tipOfTheDay => 'Tip of the day';

  @override
  String get inThisPeriod => 'This time of year';

  @override
  String get birdOfTheDay => 'Bird of the day';

  @override
  String get guidesTitle => 'Guides & tips';

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
  String get resultsIntro => 'Here are the most likely recognition results.';

  @override
  String get bestMatch => 'Best match';

  @override
  String get otherPossibilities => 'Other possibilities';

  @override
  String get notSure => 'I\'m not sure';

  @override
  String get confirmAndSave => 'Confirm and save';

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
  String get whereItLives => 'Where it lives';

  @override
  String get morphology => 'Morphology';

  @override
  String get lengthLabel => 'Length';

  @override
  String get weightLabel => 'Weight';

  @override
  String get eggsLabel => 'Eggs';

  @override
  String get nestLabel => 'Nest';

  @override
  String get notAvailable => 'N/A';

  @override
  String get morphologySource => 'Morphology data: BIRDBASE';

  @override
  String descriptionSource(String fonte) {
    return 'Source: $fonte';
  }

  @override
  String get share => 'Share';

  @override
  String get habitatDistribution => 'Habitat & distribution';

  @override
  String get distributionSource => 'Distribution data: GBIF';

  @override
  String get distributionUnavailable => 'Distribution data not available.';

  @override
  String get tapToExpand => 'Tap to expand';

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
  String get deleteSighting => 'Delete sighting';

  @override
  String get deleteSightingTitle => 'Delete this sighting?';

  @override
  String get deleteSightingBody => 'This action is irreversible.';

  @override
  String get deleteAction => 'Delete';

  @override
  String get sightingDeleted => 'Sighting deleted.';

  @override
  String get tabWishlist => 'Wishlist';

  @override
  String get addToWishlist => 'I want to spot it';

  @override
  String get removeFromWishlist => 'Remove from wishlist';

  @override
  String get emptyWishlistTitle => 'Your wishlist is empty';

  @override
  String get emptyWishlistSubtitle => 'Add the species you still want to spot.';

  @override
  String get alreadySpotted => 'Already spotted 🎉';

  @override
  String get wishlistNote => 'Note';

  @override
  String get wishlistNoteHint => 'Note (optional)';

  @override
  String get dangerNotReported => 'not reported';

  @override
  String difficultyEstimateLabel(String value) {
    return 'Difficulty (estimate): $value';
  }

  @override
  String get difficultyCommon => 'common';

  @override
  String get difficultyUncommon => 'uncommon';

  @override
  String get difficultyHard => 'hard';

  @override
  String get difficultyVeryRare => 'very rare';

  @override
  String get difficultyNA => 'n/a';

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
  String get showOnMap => 'Show on map';

  @override
  String get addSightings => 'Add sightings';

  @override
  String addSelectedCount(int count) {
    return 'Add ($count)';
  }

  @override
  String get allSightingsInCollection =>
      'All your sightings are already in this collection.';

  @override
  String get removeFromCollection => 'Remove from collection';

  @override
  String get removeFromCollectionConfirm =>
      'Remove this sighting from the collection? It stays in your collection.';

  @override
  String get noCollectionsYet => 'You don\'t have any collections yet.';

  @override
  String get collectionsEmptyTitle => 'No collections';

  @override
  String get collectionsEmptySubtitle =>
      'Create collections to organize your sightings into groups.';

  @override
  String get identified => 'Identified';

  @override
  String get identifiedSubtitle =>
      'Species spotted and documented on your trips.';

  @override
  String get settings => 'Settings';

  @override
  String get settingsSubtitle => 'Manage your field journal preferences.';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountSubtitle => 'Manage profile and sharing';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutSubtitle => 'App version';

  @override
  String get languageSubtitle => 'Choose the interface language';

  @override
  String get languageAutoShort => 'Auto';

  @override
  String get versionLabel => 'Version';

  @override
  String get nonCommercialNote =>
      'MonkeyBirdie is a non-commercial, zero-cost project.';

  @override
  String get profileSaved => 'Profile updated.';

  @override
  String get statSharedSightings => 'Shared sightings';

  @override
  String get statSpecies => 'Species';

  @override
  String get favoriteBirds => 'Favourite birds';

  @override
  String get recentSightings => 'Recent sightings';

  @override
  String get collectionsHeading => 'My collections';

  @override
  String get collectionsHeadingSub => 'Your observation archive.';

  @override
  String get startNewCollection => 'Start a new collection';

  @override
  String get startNewCollectionSub =>
      'Group your observations by trip, season or habitat.';

  @override
  String get wishlistHeading => 'Wishlist';

  @override
  String get wishlistHeadingSub =>
      'Species you\'d like to spot or have already met.';

  @override
  String get addSpecies => 'Add species';

  @override
  String get statusToSpot => 'To spot';

  @override
  String get statusSpotted => 'Spotted';

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
  String get shareAllTitle => 'Share my sightings';

  @override
  String get shareAllSubtitle =>
      'Friends will see all your sightings on the map and your profile.';

  @override
  String get shareWithFriends => 'Share with friends';

  @override
  String get sharedWithFriends => 'Shared with friends';

  @override
  String spottedBy(String username) {
    return 'Spotted by @$username';
  }

  @override
  String get sharedSightings => 'Shared sightings';

  @override
  String get noSharedSightings => 'No shared sightings.';

  @override
  String get friends => 'Friends';

  @override
  String get searchUsers => 'Search users';

  @override
  String get searchUsersHint => 'Search by username…';

  @override
  String get searchUsersTypeHint => 'Type at least 2 letters.';

  @override
  String get searchUsersNoResults => 'No user found.';

  @override
  String get requests => 'Requests';

  @override
  String get requestsIncoming => 'Incoming';

  @override
  String get requestsOutgoing => 'Outgoing';

  @override
  String get noFriendsTitle => 'No friends';

  @override
  String get noFriendsSubtitle =>
      'Search users by username and send a request.';

  @override
  String get noRequestsTitle => 'No requests';

  @override
  String get noRequestsSubtitle =>
      'Incoming and outgoing requests show up here.';

  @override
  String get addFriend => 'Add';

  @override
  String get cancelRequest => 'Cancel request';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Decline';

  @override
  String get friendLabel => 'Friend';

  @override
  String get removeFriend => 'Remove friend';

  @override
  String removeFriendConfirm(String username) {
    return 'Remove @$username from friends?';
  }

  @override
  String get retry => 'Try again';
}
