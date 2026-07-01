import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../error/failure.dart';

typedef LatLng = ({double lat, double lng});

/// Wrapper su geolocator: gestisce servizi, permessi e lettura della posizione.
class LocationService {
  Future<LatLng> posizioneCorrente() async {
    // Sul web (in particolare Safari/iOS) l'API Permissions per la
    // geolocalizzazione non e' affidabile: check/requestPermission tornano
    // "denied" SENZA mostrare il prompt. Chiamando direttamente
    // getCurrentPosition e' il browser a mostrare il prompt nativo.
    if (kIsWeb) {
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        return (lat: pos.latitude, lng: pos.longitude);
      } catch (e) {
        throw ValidationFailure('Posizione non disponibile: $e');
      }
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const ValidationFailure(
        'Attiva i servizi di localizzazione per registrare un avvistamento.',
      );
    }

    var permesso = await Geolocator.checkPermission();
    if (permesso == LocationPermission.denied) {
      permesso = await Geolocator.requestPermission();
    }
    if (permesso == LocationPermission.denied ||
        permesso == LocationPermission.deniedForever) {
      throw const ValidationFailure('Permesso di localizzazione negato.');
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return (lat: pos.latitude, lng: pos.longitude);
  }
}

final locationServiceProvider =
    Provider<LocationService>((ref) => LocationService());
