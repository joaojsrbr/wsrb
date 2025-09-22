// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:collection';
import 'dart:isolate';
import 'dart:ui';

import 'package:content_library/content_library.dart';
import 'package:isar/isar.dart';

class ProgressMessage {
  final int current;
  final int total;
  final bool completed;

  const ProgressMessage({
    required this.current,
    required this.total,
    this.completed = false,
  });

  double get percent => total == 0 ? 0 : current / total;

  Map<String, dynamic> get _toMap {
    return <String, dynamic>{'current': current, 'total': total, 'completed': completed};
  }

  factory ProgressMessage._fromMap(dynamic map) {
    return ProgressMessage(
      current: map['current'] as int,
      total: map['total'] as int,
      completed: map['completed'] as bool,
    );
  }
}

class ReleaseUpdateService {
  const ReleaseUpdateService._();

  static const String _progressPortKey = "current_progress_port";

  static final Stream<ProgressMessage> progressStream = _initProgressStream();

  static Stream<ProgressMessage> _initProgressStream() {
    final receivePort = ReceivePort();
    IsolateNameServer.removePortNameMapping(_progressPortKey);
    final ok = IsolateNameServer.registerPortWithName(
      receivePort.sendPort,
      _progressPortKey,
    );
    if (!ok) return const Stream.empty();
    return receivePort
        .where((msg) => msg is Map)
        .map(ProgressMessage._fromMap)
        .cast<ProgressMessage>();
  }

  static void removePortNameMapping() {
    IsolateNameServer.removePortNameMapping(_progressPortKey);
  }

  static Future<void> newReleases() async {
    final notificationService = NotificationService.I;
    final isarServiceImpl = IsarServiceImpl();
    final appConfigController = AppConfigController(isarServiceImpl, false);
    final dioClient = DioClient()..disableDioStatus();
    final libraryController = LibraryController(isarServiceImpl, appConfigController);
    final graphQLApiClient = GraphQLApiClient();
    final animeSkipRepository = AnimeSkipRepository(graphQLApiClient);
    final historicController = HistoricController(isarServiceImpl);
    final contentRepository = ContentRepository(
      appConfigController,
      dioClient,
      animeSkipRepository,
    );

    await isarServiceImpl.startDatabase(inspector: false);

    await Future.wait([
      historicController.start(),
      appConfigController.start(),
      libraryController.start(),
      notificationService.init(permission: false),
      contentRepository.session.init(),
      dotenv.load(fileName: "assets/.env"),
    ]);

    final libraryRepo = libraryController.repo;
    final total = libraryRepo.favorites.length;
    int current = 0;

    final sendPort = IsolateNameServer.lookupPortByName(_progressPortKey);

    await notificationService.showOrUpdateProgress(
      id: 1000,
      title: "Verificando atualizações",
      body: "Checando sua lista de favoritos...",
      progress: 0,
      maxProgress: total,
    );

    for (final repoContent in libraryRepo.favorites) {
      current++;
      sendPort?.send(ProgressMessage(current: current, total: total)._toMap);

      switch (repoContent) {
        case AnimeEntity data:
          final filter = await historicController.filter<EpisodeEntity>();
          final episodes = SplayTreeSet.of(
            await filter.contentStringIDEqualTo(data.stringID).findAll(),
            (a, b) => a.numberEpisode.compareTo(b.numberEpisode),
          );

          final source = contentRepository.source(repoContent.source);
          final result = await source.getData(repoContent.toContent());

          if (result is Success<Content>) {
            final anime = result.data as Anime;
            final releases = anime.releases;
            final nLast = releases.last;
            final dLast = episodes.last;

            if ({0, 1}.contains(nLast.numberInt) ||
                {0, 1}.contains(dLast.numberEpisode)) {
              // await notificationService.showOrUpdateProgress(
              //   id: 1000,
              //   title: "Verificando atualizações",
              //   body: "Checando ${data.title}...",
              //   progress: current,
              //   maxProgress: total,
              // );
              continue;
            }

            if (nLast.numberInt > dLast.numberEpisode) {
              await notificationService.show(
                id: data.stringID.hashCode,
                title: "Novo episódio disponível!",
                body: "${data.title} lançou o episódio ${nLast.numberInt}",
                payload: "contentInfo/${data.stringID}",
              );

              AnimeEntity contentEntity = data.copyWith(
                isFavorite: true,
                newReleases: List.from([nLast.stringID]),
                anilistMedia: anime.anilistMedia,
              );

              final List<HistoricEntity> historyEntities = [];

              final entries = anime.releases.map((release) {
                final entity = historicController.repo.getHistoric<HistoricEntity>(
                  release: release,
                );

                return MapEntry(release, entity ?? release.toEntity(anime: anime));
              });

              for (var entry in entries.nonNulls) {
                final value = entry.value;
                final release = entry.key;

                switch (contentEntity) {
                  case AnimeEntity anime when value is EpisodeEntity:
                    final saveEpisode = EpisodeEntity.save(
                      episode: release,
                      anime: anime.toContent(),
                      entity: value,
                    );
                    anime.episodes.add(saveEpisode);
                    historyEntities.add(saveEpisode);
                }
              }

              // if (contentEntity.animeSkip.value != null) {
              //   await animeSkipController.save(contentEntity.animeSkip.value!);
              // }

              await libraryController.add(contentEntity: contentEntity);
              await historicController.addAll(historyEntities: historyEntities);
            }
          }

          await notificationService.showOrUpdateProgress(
            id: 1000,
            title: "Verificando atualizações",
            body: "Checando ${data.title}...",
            progress: current,
            maxProgress: total,
          );
      }
    }

    await notificationService.show(
      id: 1000,
      title: "Atualização concluída",
      body: "Todos os seus favoritos foram verificados!",
    );
    sendPort?.send(
      ProgressMessage(current: current, total: total, completed: true)._toMap,
    );
  }
}
