import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Sorgente tile RASTER: OpenStreetMap standard. Immagini gia' pronte -> pan e
/// zoom fluidi (nessuna rasterizzazione a runtime), colorate (boschi/parchi in
/// verde, acqua in blu) cosi' si leggono le zone naturali.
const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// User-Agent identificativo: richiesto dalla usage policy delle tile OSM.
const String tileUserAgent =
    'MonkeyBird/1.0 (birdwatching; non-commercial)';

/// Store persistente su disco per la cache delle tile = il "mini offline":
/// una tile gia' vista NON si riscarica e resta anche tra le sessioni. Su web
/// Hive usa IndexedDB (directory null), su nativo una cartella dell'app.
final tileCacheStoreProvider = FutureProvider<HiveCacheStore>((ref) async {
  if (kIsWeb) return HiveCacheStore(null, hiveBoxName: 'monkeybird_tiles');
  final dir = await getApplicationSupportDirectory();
  return HiveCacheStore('${dir.path}/tiles', hiveBoxName: 'monkeybird_tiles');
});
