import 'dart:async';

import 'package:content_library/content_library.dart';
import 'package:content_library/src/services/isar_service.dart';
import 'package:content_library/src/utils/elapsed.dart';
import 'package:isar/isar.dart';

class IsarServiceImpl implements IsarService {
  final Completer<Isar> _isar = Completer();

  @override
  Future<IsarCollection<T>> collection<T>() async =>
      (await _isar.future).collection<T>();

  @override
  Future<Result<(bool, int?)>> add({Entity? entity}) async {
    final isar = await _isar.future;

    bool isSucess = false;
    int? currentID;

    await isar.writeTxn(() async {
      switch (entity) {
        case ChapterEntity data:
          final bookEntity = await isar.bookEntitys.getByStringID(
            data.bookStringID,
          );

          if (bookEntity != null) {
            bookEntity.updatedAt = DateTime.now();
            bookEntity.chapters.add(data);
            currentID = await isar.chapterEntitys.putByStringID(data);
            await bookEntity.chapters.save();
            isSucess = true;
          }

        case EpisodeEntity data:
          final animeEntity = await isar.animeEntitys.getByStringID(
            data.animeStringID,
          );

          if (animeEntity != null) {
            animeEntity.updatedAt = DateTime.now();
            animeEntity.episodes.add(data);
            currentID = await isar.episodeEntitys.putByStringID(data);
            await animeEntity.episodes.save();
            isSucess = true;
          }
          // currentID = await isar.episodeEntitys.putByStringID(data);

          // isSucess = true;

          break;
        case CategoryEntity data:
          currentID = await isar.categoryEntitys.put(data);

          isSucess = true;
          break;
        case AnimeSkipEntity data:
          currentID = await isar.animeSkipEntitys.putByAnimeSkipId(data);

          isSucess = true;
          break;

        case AnimeEntity data:
          final animeEntity = await isar.animeEntitys.getByStringID(
            data.stringID,
          );

          if (animeEntity != null) {
            animeEntity.isFavorite = data.isFavorite;
            data.createdAt = animeEntity.createdAt;
          }

          data.updatedAt = DateTime.now();

          currentID = await isar.animeEntitys.putByStringID(data);
          // await data.animeSkip.value!.times.save();
          if (data.animeSkip.value != null) {
            // await isar.animeSkipEntitys.putByAnimeSkipId(data.animeSkip.value!);
            await data.animeSkip.save();
            // await isar.animeTimeStampEntitys.putAll(
            //   data.animeSkip.value!.times.toList(),
            // );
          }

          // if (!data.episodes.isLoaded) {
          //   await data.episodes.save();
          // } else {
          //   await data.episodes.load();
          // }

          isSucess = true;
          break;
        case BookEntity data:
          final bookEntity = await isar.bookEntitys.getByStringID(
            data.stringID,
          );

          if (bookEntity != null) {
            data.createdAt = bookEntity.createdAt;
          }

          data.updatedAt = DateTime.now();
          currentID = await isar.bookEntitys.putByStringID(data);
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
    final isar = await _isar.future;

    bool isSucess = false;

    await isar.writeTxn(() async {
      switch (entity) {
        case AnimeEntity data:
          isSucess = await isar.animeEntitys.deleteByStringID(data.stringID);
          break;
        case BookEntity data:
          isSucess = await isar.bookEntitys.deleteByStringID(data.stringID);
          break;
        case EpisodeEntity data:
          isSucess = await isar.episodeEntitys.deleteByStringID(data.stringID);
          break;
        case ChapterEntity data:
          isSucess = await isar.chapterEntitys.deleteByStringID(data.stringID);
          break;
        case CategoryEntity data:
          isSucess = await isar.categoryEntitys.deleteByStringID(data.stringID);
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

    if (entities != null && entities.isNotEmpty) {
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
    // final isar = await _isar.future;
    List<int> ids = [];
    bool isSucess = false;

    if (entities != null) {
      final futures = await Future.wait(entities.map((e) => remove(entity: e)));
      futures
          .map((e) => e.fold(onSuccess: (data) => data.$2))
          .nonNulls
          .forEach(ids.add);
    }

    return Result.success((isSucess, ids));
  }

  @override
  Future<void> startDatabase({
    Future<void> Function()? onStart,
    List<CollectionSchema<dynamic>>? schemas,
    bool inspector = true,
  }) async {
    final Elapsed elapsed = Elapsed()..start();
    String isarPath = (await getApplicationDocumentsDirectory()).path;

    // if (kDebugMode) {
    //   isarPath = "${App.APP_DIRECTORY}/biblioteca/debug";
    //   final isarDir = Directory(isarPath);
    //   if (!await isarDir.exists()) await isarDir.create(recursive: true);
    // }

    // final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [
        ...?schemas,
        BookEntitySchema,
        AnimeEntitySchema,
        EpisodeEntitySchema,
        ChapterEntitySchema,
        CategoryEntitySchema,
        AnimeSkipEntitySchema,
      ],
      maxSizeMiB: 2048,
      directory: isarPath,
      inspector: inspector,
    );
    elapsed.printAndStop(runtimeType.toString());

    _isar.complete(isar);

    await onStart?.call();
  }
}
