import 'package:hive/hive.dart';

abstract interface class HiveService {
  Future<void> init();

  Future<T> load<T>(
    String key,
    T defaultValue, {
    bool debug = true,
  });

  Future<void> save<T>(
    String key,
    T value, {
    bool debug = true,
  });

  Future<void> delete<T>(String key);

  Stream<BoxEvent> watchBy(String key);
}
