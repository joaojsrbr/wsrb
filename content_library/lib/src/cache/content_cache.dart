import 'package:content_library/content_library.dart';
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
      App.APP_CACHE_TASK_DELETE_BY_ID,
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
      ),
      initialDelay: const Duration(minutes: 2),
      inputData: {"remove_id": id},
    );
  }

  static Future<bool> cacheTask(
    String task,
    Map<String, dynamic> inputData,
  ) async {
    if (task.contains(App.APP_CACHE_TASK_DELETE_ALL)) {
      // await ContentCache.clearAllCache();
      return Future.value(true);
    } else if (task.contains(App.APP_CACHE_TASK_DELETE_BY_ID)) {
      final removeID = inputData['remove_id'] as String;
      final HiveService hiveServiceImpl = HiveServiceImpl();
      await hiveServiceImpl.init();

      await hiveServiceImpl.delete(removeID);
      return Future.value(true);
    }
    return Future.value(false);
  }
}
