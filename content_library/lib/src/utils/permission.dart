import 'package:content_library/src/utils/elapsed.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> manageExternalStorage() async {
    final Elapsed elapsed = Elapsed()..start();
    var status = await Permission.manageExternalStorage.status;

    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }
    if (status.isPermanentlyDenied) await openAppSettings();
    elapsed.printAndStop('manageExternalStorage');
    return status.isGranted;
  }
}
