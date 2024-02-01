import 'package:app_wsrb_jsr/app/core/interfaces/hive_service.dart';
import 'package:app_wsrb_jsr/app/core/services/hive/hive_service.dart';
import 'package:app_wsrb_jsr/app/models/book.dart';
import 'package:workmanager/workmanager.dart';

class BookCache {
  final HiveService _hiveService;

  BookCache(this._hiveService);

  Future<Book?> getBook(String id) async {
    return await _hiveService.load(id, null, debug: false);
  }

  Future<void> saveBook(Book book) async {
    await Future.wait([
      Workmanager().cancelByUniqueName(book.id),
      _hiveService.save(book.id, book, false),
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

  static Future<void> task(String removeID) async {
    final HiveService hiveServiceImpl = HiveServiceImpl(
      'wsrb_hive',
      start: (HiveService service) async {},
    );
    await hiveServiceImpl.init();

    await hiveServiceImpl.delete(removeID);
  }
}
