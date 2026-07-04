import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../error/failure.dart';
import '../locale/locale_controller.dart';

typedef LatLng = ({double lat, double lng});

/// Wrapper su geolocator: gestisce servizi, permessi e lettura della posizione.
/// Memorizza anche l'ULTIMA posizione rilevata (SharedPreferences) per usarla
/// come centro di partenza quando il GPS non e' disponibile (modalita' manuale).
class LocationService {
  LocationService(this._prefs);
  final SharedPreferences _prefs;

  static const _kLat = 'ultima_pos_lat';
  static const _kLng = 'ultima_pos_lng';

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
        return _ricorda(pos.latitude, pos.longitude);
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
    return _ricorda(pos.latitude, pos.longitude);
  }

  /// Ultima posizione rilevata (persistita), da usare come centro-mappa quando
  /// il GPS non e' disponibile. Sul nativo prova anche la cache dell'OS.
  /// null se non se n'e' mai avuta una.
  Future<LatLng?> ultimaPosizioneNota() async {
    final lat = _prefs.getDouble(_kLat);
    final lng = _prefs.getDouble(_kLng);
    if (lat != null && lng != null) return (lat: lat, lng: lng);

    if (!kIsWeb) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return (lat: last.latitude, lng: last.longitude);
      } catch (_) {
        // best-effort
      }
    }
    return null;
  }

  LatLng _ricorda(double lat, double lng) {
    // Fire-and-forget: non blocca il flusso di riconoscimento.
    _prefs.setDouble(_kLat, lat);
    _prefs.setDouble(_kLng, lng);
    return (lat: lat, lng: lng);
  }
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(ref.read(sharedPreferencesProvider)),
);
