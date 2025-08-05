// import 'package:android_intent_plus/android_intent.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContentUtils {
  const ContentUtils._();

  static Future<bool> selectTypePlayer(
    BuildContext context,
    Episode episode,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        final titleStyle = Theme.of(context).textTheme.titleMedium;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  BackButton(),
                  Center(child: Text("Player", style: titleStyle)),
                ],
              ),
              Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 20),
                  Container(
                    height: 80,
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Center(child: Text("Outro")),
                        Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => Navigator.pop(context, false),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 80,
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Center(child: Text("Local")),
                        Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => Navigator.pop(context, true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ],
          ),
        );
      },
    );

    customLog(result);
    if (result != null && !result && context.mounted) {
      await _launcherEpisodeAnotherPlayer(context, episode, context.read());
      return false;
    }

    return true;
  }

  static Future<void> _launcherEpisodeAnotherPlayer(
    BuildContext context,
    Episode episode,
    ContentRepository repository,
  ) async {
    final result = await repository.getContent(episode);

    result.fold(
      onSuccess: (data) async {
        customLog(data);

        // if (data.first case VideoData data) {
        //   final intent = AndroidIntent(
        //     action: 'action_view',
        //     data: Uri.encodeFull(data.videoContent),
        //     type: 'application/x-mpegURL',
        //     arguments: {
        //       "title": episode.title,
        //       "headers": data.httpHeaders,
        //     },
        //   );

        //   await intent.launch();

        // final Uri uri = Uri.parse("video:${data.videoContent}");

        // if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        //   throw 'Não foi possível abrir o vídeo: $data.videoContent';
        // }
        // }
      },
      onError: (_) => Navigator.pop(context),
    );
  }

  static Future<void> saveOrUpdate(
    BuildContext context,
    Content content,
  ) async {
    final libraryController = context.read<LibraryController>();
    final historicController = context.read<HistoricController>();
    final animeSkipController = context.read<AnimeSkipController>();

    // Obtém ou cria a ContentEntity
    ContentEntity? contentEntity = libraryController.repo
        .getContentEntityByStringIDAll(
          content.stringID,
          orElse: () => content.toEntity(createdAt: DateTime.now()),
        )
        ?.copyWith(isFavorite: true);

    // final bool shouldSave = _libraryController.repo.contains(content: content);

    if (contentEntity == null) return;

    // Garante que os dados do Anilist estejam presentes
    if (contentEntity.anilistMedia == null) {
      contentEntity = contentEntity.copyWith(
        isFavorite: true,
        anilistMedia: content.anilistMedia,
      );
    }

    final List<HistoricEntity> historyEntities = [];

    final entries = content.releases.map((release) {
      final entity = historicController.repo.getHistoric<HistoricEntity>(
        release: release,
        orElse: () {
          return switch ((release, content)) {
            (Episode episode, Anime anime) => episode.toEntity(anime: anime),
            (Chapter chapter, Book _) => chapter.toEntity(0.0, null, null),
            _ => null,
          };
        },
      );
      if (entity == null) return null;
      return MapEntry(release, entity);
    });

    for (var entry in entries.nonNulls) {
      final value = entry.value;
      final release = entry.key;

      switch (contentEntity) {
        case AnimeEntity anime when value is EpisodeEntity:
          final saveEpisode = EpisodeEntity.save(
            episode: release as Episode,
            anime: content as Anime,
            entity: value,
          );
          anime.episodes.add(saveEpisode);
          historyEntities.add(saveEpisode);

        case BookEntity book when value is ChapterEntity:
          book.chapters.add(value);
          historyEntities.add(value);
      }
    }

    // Salva configurações de pulo de anime se existirem
    if (contentEntity case AnimeEntity anime
        when anime.animeSkip.value != null) {
      await animeSkipController.save(anime.animeSkip.value!);
    }

    // Salva os dados principais e históricos
    await libraryController.add(contentEntity: contentEntity);
    await historicController.addAll(historyEntities: historyEntities);
  }
}
