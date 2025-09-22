import '../ui/shared/widgets/global_overlay.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DownloadReleaseHelper {
  DownloadReleaseHelper._();

  static Future<void> download(
    BuildContext context,
    Release release,
    Content content,
  ) async {
    final libraryController = context.read<LibraryController>();
    final historicController = context.read<HistoricController>();
    final downloadService = context.read<DownloadService>();
    final contentRepository = context.read<ContentRepository>();
    final historicRepo = historicController.repo;
    final anchorContext = contentRepository.anchor.currentContext;
    final libraryRepo = libraryController.repo;

    switch ((release, content)) {
      case (Episode episode, Anime anime):
        await downloadService.downloadReleaseVideoByHLS(
          episode,
          anime,
          contentRepository,
          statisticsCallback: (statistics) async {},
          onResult: (result) async {
            if (result is Success) {
              final animeEntity = libraryRepo.getContentEntityByStringID(
                anime.stringID,
                orElse: () => anime.toEntity(createdAt: DateTime.now()),
              );

              final episodeEntity = historicRepo.getHistoric<EpisodeEntity>(
                release: episode,
                content: anime,
                orElse: () => episode.toEntity(anime: anime),
              );

              if (animeEntity == null || episodeEntity == null) return;

              animeEntity.episodes.add(episodeEntity);
              await libraryController.add(contentEntity: animeEntity);
              await historicController.add(historic: episodeEntity);
            }

            switch (result) {
              case Failure error when anchorContext != null && anchorContext.mounted:
                anchorContext.showErrorNotification(error.toString());
              case Success _ when anchorContext != null && anchorContext.mounted:
                anchorContext.showTopNotification(
                  Text('Baixado com sucesso: ${episode.getEpisodeTitle()}'),
                );

              case _:
            }
          },
        );
    }
  }
}
