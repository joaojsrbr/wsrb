import 'package:app_wsrb_jsr/app/core/interfaces/hive_service.dart';
import 'package:app_wsrb_jsr/app/core/services/hive/hive_service.dart';
import 'package:app_wsrb_jsr/app/models/content.dart';
import 'package:workmanager/workmanager.dart';

class ContentCache {
  final HiveService _hiveService;

  ContentCache(this._hiveService);

  Future<Content?> getContent(String id) async {
    return await _hiveService.load(id, null, debug: false);
  }

  Future<void> saveContent(Content content) async {
    await Future.wait([
      Workmanager().cancelByUniqueName(content.id),
      _hiveService.save(content.id, content, debug: false),
    ]);
  }

  Future<void> registerTask(String id) async {
    await Workmanager().registerOneOffTask(
      id,
      "task_clear_cache",
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
      ),
      initialDelay: const Duration(minutes: 5),
      inputData: {"remove_id": id},
    );
  }

  static Future<bool?> cacheTask(
    String task,
    Map<String, dynamic>? inputData,
  ) async {
    if (task.contains('task_clear_allCache')) {
      // await ContentCache.clearAllCache();
      return Future.value(true);
    } else if (task.contains('task_clear_cache') && inputData != null) {
      final removeID = inputData['remove_id'] as String;
      final HiveService hiveServiceImpl = HiveServiceImpl(
        'wsrb_hive',
        start: (HiveService service) async {},
      );
      await hiveServiceImpl.init();

      await hiveServiceImpl.delete(removeID);
      return Future.value(true);
    }
    return Future.value(null);
  }
}
