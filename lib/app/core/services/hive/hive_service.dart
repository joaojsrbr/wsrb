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
    Function(T data)? print,
    bool debug = true,
  }) async {
    try {
      final T loaded = _hiveBox.get(key, defaultValue: defaultValue) as T;
      final loadedPrint = print?.call(loaded) ?? loaded;
      // print?.call(_hiveBox.get(key, defaultValue: defaultValue) as T) ??

      if (debug) {
        customLog(
            'Hive type : $key as ${loadedPrint.runtimeType}\nHive loaded : $key as $loadedPrint with ${loadedPrint.runtimeType}');
      }

      return Future.value(loaded);
    } catch (_, __) {
      final defaultV = print?.call(defaultValue) ?? defaultValue;
      if (debug) {
        customLog(
            'Hive type : $key as ${defaultV.runtimeType}\nHive loaded : $key as $defaultV with ${defaultV.runtimeType}');
      }

      return Future.value(defaultValue);
    }
  }

  @override
  Future<void> save<T>(String key, T value, [bool logDebug = true]) async {
    try {
      await _hiveBox.put(key, value);
      if (logDebug) {
        customLog(
            'Hive save_type : $key as ${value.runtimeType}\nHive save : $key as $value with ${value.runtimeType}');
      }
    } on HiveError catch (_, __) {
      if (logDebug) customLog('HiveError : $_\nStackTrace: $__,');
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
