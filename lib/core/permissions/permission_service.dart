import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Richiesta dei permessi runtime usati dalla Fase 1.
class PermissionService {
  Future<bool> richiediMicrofono() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> microfonoConcesso() async {
    return Permission.microphone.isGranted;
  }
}

final permissionServiceProvider =
    Provider<PermissionService>((ref) => PermissionService());
