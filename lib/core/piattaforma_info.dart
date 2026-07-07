// Stringa descrittiva della piattaforma corrente (per i feedback/bug), scelta a
// compile-time: nativo → OS + versione (dart:io); web → "Web".
export 'piattaforma_info_stub.dart'
    if (dart.library.io) 'piattaforma_info_io.dart'
    if (dart.library.js_interop) 'piattaforma_info_web.dart';
