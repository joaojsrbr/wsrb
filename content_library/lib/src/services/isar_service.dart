import 'package:content_library/content_library.dart';
import 'package:isar/isar.dart';

abstract interface class IsarService {
  Future<Result<(bool, int?)>> remove({Entity? entity});

  Future<Result<(bool, List<int>?)>> removeAll({List<Entity>? entities});

  Future<Result<(bool, int?)>> add({Entity? entity});

  Future<Result<(bool, List<int>?)>> addAll({List<Entity>? entities});

  Future<IsarCollection<T>> collection<T>();

  Future<void> startDatabase({
    Future<void> Function()? onStart,
    List<CollectionSchema<dynamic>>? schemas,
    bool inspector = true,
  });
}
