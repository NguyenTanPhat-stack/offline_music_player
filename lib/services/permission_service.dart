import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestMusicPermissions() async {
    // Android 13+: READ_MEDIA_AUDIO (permission_handler map: Permission.audio)
    // Older: storage
    final audioStatus = await Permission.audio.status;
    if (audioStatus.isGranted) return true;

    final storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) return true;

    // Try request audio first
    final audioReq = await Permission.audio.request();
    if (audioReq.isGranted) return true;

    // Fallback request storage
    final storageReq = await Permission.storage.request();
    if (storageReq.isGranted) return true;

    if (audioReq.isPermanentlyDenied || storageReq.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }
}
