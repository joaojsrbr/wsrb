import 'package:content_library/content_library.dart';
import 'package:isar/isar.dart';

abstract interface class IsarService {
  Future<Result<(bool, int?)>> remove({required Entity entity});

  Future<Result<(bool, List<int>?)>> removeAll({required List<Entity> entities});

  Future<Result<(bool, int?)>> add({required Entity entity});

  Future<Result<(bool, List<int>?)>> addAll({required List<Entity> entities});

  Future<IsarCollection<T>> collection<T>();

  Future<void> startDatabase({
    Future<void> Function()? onStart,
    List<CollectionSchema<dynamic>>? schemas,
    bool inspector = true,
  });
}
