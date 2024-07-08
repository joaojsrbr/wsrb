import 'package:content_library/content_library.dart';
import 'package:content_library/src/services/isar_service.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarServiceImpl implements IsarService {
  late final Isar _isar;

  @override
  IsarCollection<T> collection<T>() => _isar.collection<T>();

  @override
  Future<Result<(bool, int?)>> add({Entity? entity}) async {
    bool isSucess = false;
    int? currentID;

    await _isar.writeTxn(() async {
      switch (entity) {
        case ChapterEntity data:
          final bookEntity = await _isar.bookEntitys.getByStringID(
            data.animeStringID,
          );

          if (bookEntity != null) {
            bookEntity.updatedAt = DateTime.now();
            bookEntity.chapters.add(data);
            currentID = await _isar.chapterEntitys.putByStringID(data);
            await bookEntity.chapters.save();
            isSucess = true;
          }

        case EpisodeEntity data:
          final animeEntity = await _isar.animeEntitys.getByStringID(
            data.animeStringID,
          );

          if (animeEntity != null) {
            animeEntity.updatedAt = DateTime.now();
            animeEntity.episodes.add(data);
            currentID = await _isar.episodeEntitys.putByStringID(data);
            await animeEntity.episodes.save();
            isSucess = true;
          }

          break;
        case CategoryEntity data:
          currentID = await _isar.categoryEntitys.put(data);

          isSucess = true;
          break;
        case AnimeEntity data:
          final animeEntity = await _isar.animeEntitys.getByStringID(
            data.stringID,
          );

          if (animeEntity != null) {
            animeEntity.isFavorite = data.isFavorite;
            data.createdAt = animeEntity.createdAt;
          }

          data.updatedAt = DateTime.now();
          currentID = await _isar.animeEntitys.putByStringID(data);

          isSucess = true;
          break;
        case BookEntity data:
          final bookEntity = await _isar.bookEntitys.getByStringID(
            data.stringID,
          );

          if (bookEntity != null) {
            data.createdAt = bookEntity.createdAt;
          }

          data.updatedAt = DateTime.now();
          currentID = await _isar.bookEntitys.putByStringID(data);
          isSucess = true;
          break;
      }
    });

    if (isSucess) {
      customLog('Isar[add]: ${entity?.id} as ${entity.runtimeType}');
    }

    return Result.success((isSucess, currentID));
  }

  @override
  Future<Result<(bool, int?)>> remove({Entity? entity}) async {
    bool isSucess = false;

    await _isar.writeTxn(() async {
      switch (entity) {
        case AnimeEntity data:
          isSucess = await _isar.animeEntitys.deleteByStringID(data.stringID);
          break;
        case BookEntity data:
          isSucess = await _isar.bookEntitys.deleteByStringID(data.stringID);
          break;
        case EpisodeEntity data:
          isSucess = await _isar.episodeEntitys.deleteByStringID(data.stringID);
          break;
        case ChapterEntity data:
          isSucess = await _isar.chapterEntitys.deleteByStringID(data.stringID);
          break;
        case CategoryEntity data:
          isSucess =
              await _isar.categoryEntitys.deleteByStringID(data.stringID);
          break;
      }
    }).whenComplete(() {
      customLog('Isar[remove]: ${entity?.id} as ${entity.runtimeType}');
    });
    return Result.success((isSucess, entity?.id));
  }

  @override
  Future<Result<(bool, List<int>?)>> addAll({List<Entity>? entities}) async {
    List<int> ids = [];
    bool isSucess = false;

    if (entities != null) {
      final futures = await Future.wait(entities.map((e) => add(entity: e)));
      futures
          .map((e) => e.fold(onSuccess: (data) => data.$2))
          .nonNulls
          .forEach(ids.add);
    }
    isSucess = true;

    // switch (entities) {
    //   case List data when data.single.runtimeType is AnimeEntity:
    //   //   await _isar.writeTxn(() async {
    //   //     final putIDS = await _isar.animeEntitys.putAllByStringID(data.cast());
    //   //     ids.addAll(putIDS);
    //   //   });
    //   //   break;
    //   // case List<AnimeEntity> data:
    //   //   await _isar.writeTxn(() async {
    //   //     final putIDS = await _isar.animeEntitys.putAllByStringID(data);
    //   //     ids.addAll(putIDS);
    //   //   });
    //   //   break;
    //   // case List<BookEntity> data:
    //   //   await _isar.writeTxn(() async {
    //   //     final putIDS = await _isar.bookEntitys.putAllByStringID(data);
    //   //     ids.addAll(putIDS);
    //   //   });
    //   //   break;
    //   // case List<EpisodeEntity> data:
    //   //   await _isar.writeTxn(() async {
    //   //     final putIDS = await _isar.episodeEntitys.putAllByStringID(data);
    //   //     ids.addAll(putIDS);
    //   //   });
    //   //   break;
    //   // case List<CategoryEntity> data:
    //   //   await _isar.writeTxn(() async {
    //   //     final putIDS = await _isar.categoryEntitys.putAllByStringID(data);
    //   //     ids.addAll(putIDS);
    //   //   });
    //   //   break;
    //   default:
    //     isDefault = true;
    //     if (entities != null) {
    //       final futures =
    //           await Future.wait(entities.map((e) => add(entity: e)));
    //       futures
    //           .map((e) => e.fold(onSuccess: (data) => data.$2))
    //           .nonNulls
    //           .forEach(ids.add);
    //     }
    //     isSucess = true;
    //     break;
    // }

    return Result.success((isSucess, ids));
  }

  @override
  Future<Result<(bool, List<int>?)>> removeAll({List<Entity>? entities}) async {
    List<int> ids = [];
    bool isSucess = false;
    bool isDefault = false;
    switch (entities) {
      case List<AnimeEntity> _:
        await _isar.writeTxn(() async {
          await _isar.animeEntitys
              .deleteAll(entities.map((e) => e.id).toList());
          ids.addAll(entities.map((e) => e.id).toList());
          isSucess = true;
        });
        break;
      case List<BookEntity> _:
        await _isar.writeTxn(() async {
          await _isar.bookEntitys.deleteAll(entities.map((e) => e.id).toList());
          ids.addAll(entities.map((e) => e.id).toList());
          isSucess = true;
        });
        break;
      case List<EpisodeEntity> _:
        await _isar.writeTxn(() async {
          await _isar.episodeEntitys
              .deleteAll(entities.map((e) => e.id).toList());
          ids.addAll(entities.map((e) => e.id).toList());
          isSucess = true;
        });
        break;
      case List<CategoryEntity> _:
        await _isar.writeTxn(() async {
          await _isar.categoryEntitys
              .deleteAll(entities.map((e) => e.id).toList());
          ids.addAll(entities.map((e) => e.id).toList());
          isSucess = true;
        });
        break;
      default:
        isDefault = true;
        if (entities != null) {
          final futures =
              await Future.wait(entities.map((e) => remove(entity: e)));
          futures
              .map((e) => e.fold(onSuccess: (data) => data.$2))
              .nonNulls
              .forEach(ids.add);
          isSucess = true;
        }
        break;
    }

    if (isSucess && !isDefault) {
      customLog(
          'Isar[removeAll]: list length ${entities?.length} as ${entities.runtimeType}');
    }

    return Result.success((isSucess, ids));
  }

  @override
  Future<void> startDatabase({
    Future<void> Function()? onStart,
    List<CollectionSchema<dynamic>>? schemas,
    bool inspector = true,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        ...?schemas,
        BookEntitySchema,
        AnimeEntitySchema,
        EpisodeEntitySchema,
        ChapterEntitySchema,
        CategoryEntitySchema,
      ],
      directory: dir.path,
      inspector: inspector,
    );
    await onStart?.call();
  }
}
