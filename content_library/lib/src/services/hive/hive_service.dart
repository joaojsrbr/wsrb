import 'package:content_library/src/services/anroll_login.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path;

import '../../constants/app.dart';
import '../../constants/order.dart';
import '../../constants/source.dart';
import '../../interfaces/hive_service.dart';
import '../../utils/custom_log.dart';

part 'hive_adapters.dart';

class HiveCacheServiceImpl implements HiveService {
  final String _boxName = App.APP_CACHE_BOX_NAME;

  late Box<dynamic> _hiveBox;

  final bool registerAdapters;

  HiveCacheServiceImpl({
    this.registerAdapters = false,
  });

  @override
  Future<void> init() async {
    if (registerAdapters) _hiveAdapters();
    final docsDir = await path.getTemporaryDirectory();

    Hive.init(docsDir.path);
    _hiveBox = await Hive.openBox<dynamic>(_boxName, path: docsDir.path);
  }

  @override
  Stream<BoxEvent> watchBy(String key) {
    throw UnimplementedError();
  }

  @override
  Future<T> load<T>(
    String key,
    T defaultValue, {
    bool debug = true,
  }) async {
    try {
      final T loaded = _hiveBox.get(key, defaultValue: defaultValue) as T;

      if (debug) {
        final message = 'Hive type: $key as ${loaded.runtimeType}'
            '\nHive loaded: $key as $loaded with ${loaded.runtimeType}';
        customLog(message);
      }
      return Future.value(loaded);
    } catch (_, __) {
      if (debug) customLog('HiveError : $_\nStackTrace: $__,');
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
    } on HiveError catch (_, __) {
      if (debug) customLog('HiveError : $_\nStackTrace: $__,');
    }
  }

  @override
  Future<void> delete<T>(
    String key, {
    bool debug = true,
  }) async {
    try {
      await _hiveBox.delete(key);

      if (debug) {
        final message = 'Hive delete: $key';
        customLog(message);
      }
    } on HiveError catch (_, __) {
      if (debug) customLog('HiveError : $_\nStackTrace: $__,');
    }
  }
}

class HiveServiceImpl implements HiveService {
  final String _boxName = App.APP_MAIN_BOX_NAME;
  final Future<void> Function(HiveService service)? start;

  late final Box<dynamic> _hiveBox;

  HiveServiceImpl({this.start});

  @override
  Future<void> init() async {
    _hiveAdapters();

    final docsDir = await path.getApplicationDocumentsDirectory();

    Hive.init(docsDir.path);

    await Hive.openBox<dynamic>(_boxName);

    _hiveBox = Hive.box<dynamic>(_boxName);

    await start?.call(this);
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

      final StringBuffer stringBuffer = StringBuffer()
        ..write('Hive type: $key as ${loaded.runtimeType}')
        ..write(
          '\nHive loaded: $key as $loaded with ${loaded.runtimeType}',
        );
      customLog(stringBuffer.toString());

      return Future.value(loaded);
    } catch (_, __) {
      if (debug) {
        final StringBuffer stringBuffer = StringBuffer()
          ..write('Hive type: $key as ${defaultValue.runtimeType}')
          ..write(
            '\nHive loaded: $key as $defaultValue with ${defaultValue.runtimeType}',
          );
        customLog(stringBuffer.toString());
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

      final StringBuffer stringBuffer = StringBuffer()
        ..write('Hive save_type: $key as ${value.runtimeType}')
        ..write(
          '\nHive save: $key as $value with ${value.runtimeType}',
        );
      customLog(stringBuffer.toString());
    } on HiveError catch (_, __) {
      if (debug) customLog('HiveError : $_\nStackTrace: $__,');
    }
  }

  @override
  Future<void> delete<T>(String key, {bool debug = true}) async {
    try {
      await _hiveBox.delete(key);
      if (debug) {
        final StringBuffer stringBuffer = StringBuffer()
          ..write('Hive delete: $key');
        customLog(stringBuffer.toString());
      }
    } on HiveError catch (_, __) {
      customLog('HiveError : $_\nStackTrace: $__,');
    }
  }
}

class HiveDefaultValue<K, V> {
  final K key;

  final V defaultValue;

  const HiveDefaultValue(this.key, this.defaultValue);
}
