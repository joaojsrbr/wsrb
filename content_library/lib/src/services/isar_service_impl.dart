import 'package:content_library/content_library.dart';
import 'package:content_library/src/services/isar_service.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarServiceImpl implements IsarService {
  late final Isar isar;

  @override
  IsarCollection<T> collection<T>() => isar.collection<T>();

  @override
  Future<Result<(bool, int?)>> add({Entity? entity}) async {
    bool isSucess = false;
    int? currentID;

    await isar.writeTxn(() async {
      if ([ChapterEntity, EpisodeEntity, CategoryEntity]
          .contains(entity.runtimeType)) {
        switch (entity) {
          case ChapterEntity _:
            final gEntity =
                await isar.bookEntitys.getByStringID(entity.stringID);
            if (gEntity != null) {
              // if (await isar.chapterEntitys.getByStringID(entity.stringID) ==
              //     null) {
              //   entity.createdAt = DateTime.now();
              // } else {
              //   entity.updatedAt = DateTime.now();
              // }
              currentID = await isar.chapterEntitys.putByStringID(entity);
              gEntity.chapters.add(entity);
              gEntity.updatedAt = DateTime.now();
              await gEntity.chapters.save();
              await isar.bookEntitys.putByStringID(gEntity);
            }
            isSucess = true;
            break;
          case EpisodeEntity _:
            final gEntity =
                await isar.animeEntitys.getByStringID(entity.stringID);
            if (gEntity != null) {
              // if (await isar.episodeEntitys.getByStringID(entity.stringID) ==
              //     null) {
              //   entity.createdAt = DateTime.now();
              // } else {
              //   entity.updatedAt = DateTime.now();
              // }
              currentID = await isar.episodeEntitys.putByStringID(entity);
              gEntity.episodes.add(entity);
              gEntity.updatedAt = DateTime.now();
              await gEntity.episodes.save();
              await isar.animeEntitys.putByStringID(gEntity);
            }
            isSucess = true;
            break;
          case CategoryEntity _:
            // final gEntity = await isar.categoryEntitys.getByIds(entity.ids);
            // if (gEntity == null) {
            //   entity.createdAt = DateTime.now();
            // } else {
            //   entity.updatedAt = DateTime.now();
            // }
            currentID = await isar.categoryEntitys.put(entity);
            isSucess = true;
            break;
          // switch (entity) {
          //   case AnimeEntity _:
          //     final gEntity = await isar.categoryEntitys.getByIds(entity.ids);
          //     if (gEntity == null) {
          //       entity.createdAt = DateTime.now();
          //     } else {
          //       entity.updatedAt = DateTime.now();
          //     }
          //     currentID = await isar.categoryEntitys.put(entity);
          //     break;
          //   case BookEntity _:
          //     final gEntity = await isar.categoryEntitys.getByIds(entity.ids);
          //     if (gEntity == null) {
          //       entity.createdAt = DateTime.now();
          //     } else {
          //       entity.updatedAt = DateTime.now();
          //     }
          //     currentID = await isar.categoryEntitys.put(entity);
          //     break;
          // }
        }
      } else if ([AnimeEntity, BookEntity].contains(entity.runtimeType)) {
        switch (entity) {
          case AnimeEntity _:
            // final gEntity =
            //     await isar.animeEntitys.getByStringID(entity.stringID);
            // if (gEntity == null) {
            //   entity.createdAt = DateTime.now();
            // } else {
            //   entity.updatedAt = DateTime.now();
            // }
            currentID = await isar.animeEntitys.putByStringID(entity);
            break;
          case BookEntity _:
            // final gEntity =
            //     await isar.bookEntitys.getByStringID(entity.stringID);
            // if (gEntity == null) {
            //   entity.createdAt = DateTime.now();
            // } else {
            //   entity.updatedAt = DateTime.now();
            // }
            currentID = await isar.bookEntitys.putByStringID(entity);
            break;
        }
        isSucess = true;
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

    await isar.writeTxn(() async {
      switch (entity) {
        case AnimeEntity _:
          isSucess = await isar.animeEntitys.delete(entity.id);
          break;
        case BookEntity _:
          isSucess = await isar.bookEntitys.delete(entity.id);
          break;
        case EpisodeEntity _:
          isSucess = await isar.episodeEntitys.delete(entity.id);
          break;
        case ChapterEntity _:
          isSucess = await isar.chapterEntitys.delete(entity.id);
          break;
        case CategoryEntity _:
          isSucess = await isar.categoryEntitys.delete(entity.id);
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
    bool isDefault = false;
    switch (entities) {
      case List<AnimeEntity> _:
        await isar.writeTxn(() async {
          final putIDS = await isar.animeEntitys.putAllByStringID(entities);
          ids.addAll(putIDS);
        });
        break;
      case List<BookEntity> _:
        await isar.writeTxn(() async {
          final putIDS = await isar.bookEntitys.putAllByStringID(entities);
          ids.addAll(putIDS);
        });
        break;
      case List<EpisodeEntity> _:
        await isar.writeTxn(() async {
          final putIDS = await isar.episodeEntitys.putAllByStringID(entities);
          ids.addAll(putIDS);
        });
        break;
      case List<CategoryEntity> _:
        await isar.writeTxn(() async {
          final putIDS = await isar.categoryEntitys.putAllByStringID(entities);
          ids.addAll(putIDS);
        });
        break;
      default:
        isDefault = true;
        if (entities != null) {
          final futures =
              await Future.wait(entities.map((e) => add(entity: e)));
          futures
              .map((e) => e.when(onSucess: (data) => data.$2))
              .nonNulls
              .forEach(ids.add);
        }
        isSucess = true;
        break;
    }

    if (isSucess && !isDefault) {
      customLog(
          'Isar[addAll]: list length ${entities?.length} as ${entities.runtimeType}');
    }

    return Result.success((isSucess, ids));
  }

  @override
  Future<Result<(bool, List<int>?)>> removeAll({List<Entity>? entities}) async {
    List<int> ids = [];
    bool isSucess = false;
    bool isDefault = false;
    switch (entities) {
      case List<AnimeEntity> _:
        await isar.writeTxn(() async {
          await isar.animeEntitys.deleteAll(entities.map((e) => e.id).toList());
          ids.addAll(entities.map((e) => e.id).toList());
          isSucess = true;
        });
        break;
      case List<BookEntity> _:
        await isar.writeTxn(() async {
          await isar.bookEntitys.deleteAll(entities.map((e) => e.id).toList());
          ids.addAll(entities.map((e) => e.id).toList());
          isSucess = true;
        });
        break;
      case List<EpisodeEntity> _:
        await isar.writeTxn(() async {
          await isar.episodeEntitys
              .deleteAll(entities.map((e) => e.id).toList());
          ids.addAll(entities.map((e) => e.id).toList());
          isSucess = true;
        });
        break;
      case List<CategoryEntity> _:
        await isar.writeTxn(() async {
          await isar.categoryEntitys
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
              .map((e) => e.when(onSucess: (data) => data.$2))
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

  Future<void> startDatabase({
    Future<void> Function()? onStart,
    List<CollectionSchema<dynamic>>? schemas,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [
        ...?schemas,
        BookEntitySchema,
        AnimeEntitySchema,
        EpisodeEntitySchema,
        ChapterEntitySchema,
        CategoryEntitySchema,
      ],
      directory: dir.path,
    );
    await onStart?.call();
  }
}
