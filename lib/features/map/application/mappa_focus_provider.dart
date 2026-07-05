import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// Richiesta di centrare la mappa su un punto specifico (es. dal menu "Mostra
/// sulla mappa" di un avvistamento nella collezione). `MappaScreen` la consuma
/// (sposta la camera) e la riazzera a null.
final mappaFocusProvider = StateProvider<LatLng?>((ref) => null);
