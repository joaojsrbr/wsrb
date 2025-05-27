import 'dart:async';

import 'package:content_library/content_library.dart';
import 'package:content_library/src/entities/app_config_entity.dart';
import 'package:content_library/src/services/isar_service.dart';
import 'package:isar/isar.dart';

class IsarServiceImpl implements IsarService {
  final Completer<Isar> _isar = Completer();

  @override
  Future<IsarCollection<T>> collection<T>() async =>
      (await _isar.future).collection<T>();

  @override
  Future<Result<(bool, int?)>> add({required Entity entity}) async {
    final isar = await _isar.future;

    bool isSucess = false;
    int? currentID;

    await isar.writeTxn(() async {
      switch (entity) {
        case AppConfigEntity data:
          currentID = await isar.appConfigEntitys.put(data);
          isSucess = true;
        case ChapterEntity data:
          await isar.bookEntitys
              .getByStringID(data.bookStringID)
              .then((book) async {
            if (book != null) {
              book.addChapter(data);
              // bookEntity.updatedAt = DateTime.now();
              currentID = await isar.chapterEntitys.putByStringID(data);
              await book.saveChapter();
              await isar.bookEntitys.put(
                book.copyWith(updatedAt: DateTime.now()),
              );
              isSucess = true;
            }
          });

        case EpisodeEntity episode:
          await isar.animeEntitys
              .getByStringID(episode.animeStringID)
              .then((anime) async {
            if (anime != null) {
              anime.addEpisode(episode);
              currentID = await isar.episodeEntitys.putByStringID(episode);
              await anime.saveEpisode();
              currentID = await isar.animeEntitys.putByStringID(
                anime.copyWith(updatedAt: DateTime.now()),
              );

              isSucess = true;
            }
          });

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

        case AnimeEntity anime:
          AnimeEntity? animeEntity = await isar.animeEntitys.getByStringID(
            anime.stringID,
          );

          currentID = await isar.animeEntitys.putByStringID(
            anime.copyWith(
              createdAt: animeEntity?.createdAt,
              updatedAt: DateTime.now(),
            ),
          );

          await anime.saveAnimeSkip();

          isSucess = true;
          break;
        case BookEntity book:
          final bookEntity = await isar.bookEntitys.getByStringID(
            book.stringID,
          );

          currentID = await isar.bookEntitys.putByStringID(
            book.copyWith(
              updatedAt: DateTime.now(),
              createdAt: bookEntity?.createdAt,
            ),
          );
          isSucess = true;
          break;
        case ContentEntity():
        //! abstract class
        case HistoryEntity():
        //! abstract class
        case OtherEntity():
        //! abstract class
      }
    });

    if (isSucess) {
      customLog('Isar[add]: ${entity.id} as ${entity.runtimeType}');
    }

    return Result.success((isSucess, currentID));
  }

  @override
  Future<Result<(bool, int?)>> remove({required Entity entity}) async {
    final isar = await _isar.future;

    bool isSucess = false;

    await isar.writeTxn(() async {
      switch (entity) {
        case AnimeEntity data:
          await isar.episodeEntitys
              .filter()
              .animeStringIDEqualTo(data.stringID)
              .deleteAll();
          isSucess = await isar.animeEntitys.deleteByStringID(data.stringID);
          break;
        case BookEntity data:
          await isar.chapterEntitys
              .filter()
              .bookStringIDEqualTo(data.stringID)
              .deleteAll();
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
        case ContentEntity():
        //! abstract class
        case HistoryEntity():
        //! abstract class
        case OtherEntity():
        //! abstract class
      }
    }).whenComplete(() {
      customLog('Isar[remove]: ${entity.id} as ${entity.runtimeType}');
    });
    return Result.success((isSucess, entity.id));
  }

  @override
  Future<Result<(bool, List<int>?)>> addAll({
    required List<Entity> entities,
  }) async {
    List<int> ids = [];
    final isar = await _isar.future;

    bool isSucess = false;

    if (entities.isNotEmpty) {
      final animeEntitys = entities.whereType<AnimeEntity>().toList();
      final animeSkipEntitys = entities.whereType<AnimeSkipEntity>().toList();
      final bookEntitys = entities.whereType<BookEntity>().toList();
      final categoryEntitys = entities.whereType<CategoryEntity>().toList();
      final chapterEntitys = entities.whereType<ChapterEntity>().toList();
      final episodeEntitys = entities.whereType<EpisodeEntity>().toList();

      if (animeSkipEntitys.isNotEmpty) {
        await isar.writeTxn(() async {
          final addIds =
              await isar.animeSkipEntitys.putAllByAnimeSkipId(animeSkipEntitys);

          ids.addAll(addIds);
        });

        isSucess = true;
      }

      if (animeEntitys.isNotEmpty) {
        await isar.writeTxn(
          () async {
            final futures = animeEntitys.map((anime) async {
              AnimeEntity? animeEntity = await isar.animeEntitys.getByStringID(
                anime.stringID,
              );

              return anime.copyWith(
                updatedAt: DateTime.now(),
                createdAt: animeEntity?.createdAt,
                isFavorite: animeEntity?.isFavorite,
              );
            });

            final animes = await Future.wait(futures);
            final addIds = await isar.animeEntitys.putAllByStringID(animes);
            await Future.wait(animes.map((anime) => anime.animeSkip.save()));
            ids.addAll(addIds);
          },
        );

        isSucess = true;
      }

      if (bookEntitys.isNotEmpty) {
        await isar.writeTxn(
          () async {
            final futures = bookEntitys.map((book) async {
              final bookEntitys = await isar.bookEntitys.getByStringID(
                book.stringID,
              );

              return book.copyWith(
                updatedAt: DateTime.now(),
                createdAt: bookEntitys?.createdAt,
              );
            });
            final books = await Future.wait(futures);
            final addIds = await isar.bookEntitys.putAllByStringID(books);
            ids.addAll(addIds);
          },
        );

        isSucess = true;
      }

      if (categoryEntitys.isNotEmpty) {
        await isar.writeTxn(() async {
          final addIds =
              await isar.categoryEntitys.putAllByStringID(categoryEntitys);

          ids.addAll(addIds);
        });
        isSucess = true;
      }

      if (chapterEntitys.isNotEmpty) {
        await isar.writeTxn(() async {
          final addIds =
              await isar.chapterEntitys.putAllByStringID(chapterEntitys);

          ids.addAll(addIds);
        });
        isSucess = true;
      }

      if (episodeEntitys.isNotEmpty) {
        await isar.writeTxn(() async {
          final anime = await isar.animeEntitys
              .getByStringID(episodeEntitys.first.animeStringID)
              .then((anime) => anime?.copyWith(updatedAt: DateTime.now()));

          if (anime != null) {
            anime.episodes.addAll(episodeEntitys);

            final epIds =
                await isar.episodeEntitys.putAllByStringID(episodeEntitys);

            // epIds.forEachIndexed((index, id) {
            //   episodeEntitys[index] = episodeEntitys[index]..id = id;
            // });

            ids.addAll(epIds);
            await isar.animeEntitys.putByStringID(anime);

            await anime.episodes.save();
            isSucess = true;
          }

          // for (final episode in episodeEntitys) {
          //   final anime =
          //       await isar.animeEntitys.getByStringID(episode.animeStringID);
          //   if (anime != null) {
          //     anime.addEpisode(episode);

          //     await isar.episodeEntitys.putByStringID(episode).then(ids.add);

          //     await anime.saveEpisode();

          //     await isar.animeEntitys.putByStringID(
          //       anime.copyWith(updatedAt: DateTime.now()),
          //     );

          //     isSucess = true;
          //   }
          // }
        });
      }

      // final futures = await Future.wait(entities.map((e) => add(entity: e)));
      // futures
      //     .map((e) => e.fold(onSuccess: (data) => data.$2))
      //     .nonNulls
      //     .forEach(ids.add);
    }
    isSucess = true;

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
        AppConfigEntitySchema,
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
