import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> manageExternalStorage() async {
    var status = await Permission.manageExternalStorage.status;

    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }
    if (status.isPermanentlyDenied) await openAppSettings();
    return status.isGranted;
  }
}
