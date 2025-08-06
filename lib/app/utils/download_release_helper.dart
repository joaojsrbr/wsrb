import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
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
    final navigatorContext = Navigator.of(context).context;
    final libraryController = context.read<LibraryController>();
    final historicController = context.read<HistoricController>();
    final downloadService = context.read<DownloadService>();
    final contentRepository = context.read<ContentRepository>();
    final historicRepo = historicController.repo;
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
              case Failure error when navigatorContext.mounted:
                navigatorContext.showErrorSnackBar(error);
              case Success _ when navigatorContext.mounted:
                navigatorContext.showAppSnackBar(
                  Text('Baixado com sucesso: ${episode.title}'),
                );
              case _:
            }
          },
        );
    }
  }
}
