import 'package:app_wsrb_jsr/app/core/constants/order.dart';
import 'package:app_wsrb_jsr/app/core/constants/source.dart';
import 'package:app_wsrb_jsr/app/core/interfaces/hive_service.dart';
import 'package:app_wsrb_jsr/app/models/anime.dart';
import 'package:app_wsrb_jsr/app/models/book.dart';
import 'package:app_wsrb_jsr/app/models/content.dart';
import 'package:app_wsrb_jsr/app/utils/custom_log.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

part 'hive_adapters.dart';

class HiveServiceImpl implements HiveService {
  final String _boxName;
  final Future<void> Function(HiveService service) start;

  late final Box<dynamic> _hiveBox;

  final bool registerAdapters;

  HiveServiceImpl(
    this._boxName, {
    required this.start,
    this.registerAdapters = true,
  });

  @override
  Future<void> init() async {
    if (registerAdapters) _hiveAdapters();

    final docsDir = await getApplicationDocumentsDirectory();

    Hive.init(docsDir.path);

    await Hive.openBox<dynamic>(_boxName);

    _hiveBox = Hive.box<dynamic>(_boxName);

    await start.call(this);
  }

  @override
  Stream<BoxEvent> watchBy(String key) {
    return _hiveBox.watch(key: key);
  }

  @override
  Future<T> load<T>(
    String key,
    T defaultValue, {
    bool debug = true,
  }) async {
    try {
      final T loaded = _hiveBox.get(key, defaultValue: defaultValue) as T;

      // print?.call(_hiveBox.get(key, defaultValue: defaultValue) as T) ??

      if (debug) {
        customLog(
            'Hive type : $key as ${loaded.runtimeType}\nHive loaded : $key as $loaded with ${loaded.runtimeType}');
      }

      return Future.value(loaded);
    } catch (_, __) {
      if (debug) {
        customLog(
            'Hive type : $key as ${defaultValue.runtimeType}\nHive loaded : $key as $defaultValue with ${defaultValue.runtimeType}');
      }

      return Future.value(defaultValue);
    }
  }

  @override
  Future<void> save<T>(
    String key,
    T value, {
    bool debug = true,
  }) async {
    try {
      await _hiveBox.put(key, value);
      if (debug) {
        customLog(
            'Hive save_type : $key as ${value.runtimeType}\nHive save : $key as $value with ${value.runtimeType}');
      }
    } on HiveError catch (_, __) {
      if (debug) customLog('HiveError : $_\nStackTrace: $__,');
    }
  }

  @override
  Future<void> delete<T>(String key) async {
    try {
      await _hiveBox.delete(key);
      customLog('$key deleted');
    } on HiveError catch (_, __) {
      customLog('HiveError : $_\nStackTrace: $__,');
    }
  }
}
