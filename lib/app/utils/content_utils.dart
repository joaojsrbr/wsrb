// import 'package:android_intent_plus/android_intent.dart';
import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/global_overlay.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ContentUtils {
  const ContentUtils._();

  static Future<bool> selectTypePlayer(
    BuildContext context,
    Episode episode,
    Content content,
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
      await _launcherEpisodeAnotherPlayer(context, episode, context.read(), content);
      return false;
    }

    return true;
  }

  static Future<void> _launcherEpisodeAnotherPlayer(
    BuildContext context,
    Episode episode,
    ContentRepository repository,
    Content content,
  ) async {
    final result = await repository.getContent(episode, content);

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

  static Future<void> saveOrUpdate(BuildContext context, Content content) async {
    final libraryController = context.read<LibraryController>();
    final historicController = context.read<HistoricController>();

    // Obtém ou cria a ContentEntity
    ContentEntity? contentEntity = libraryController.repo
        .getContentEntityByStringIDAll(
          content.stringID,
          orElse: () => content.toEntity(createdAt: DateTime.now()),
        )
        .copyWith
        .$merge(content.toEntity(isFavorite: true));

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
      )!;
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
          anime.addEpisode(saveEpisode);
          historyEntities.add(saveEpisode);

        case BookEntity book when value is ChapterEntity:
          book.addChapter(value);
          historyEntities.add(value);
      }
    }

    // if (contentEntity case AnimeEntity anime when anime.animeSkip.value != null) {
    //   await animeSkipController.save(anime.animeSkip.value!);
    // }

    await libraryController.add(contentEntity: contentEntity.copyWith(newReleases: []));
    await historicController.addAll(historyEntities: historyEntities);
  }

  static void notificationResponse(NotificationResponse response) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final navigatorContext = rootNavigatorKey.currentContext;

      if (navigatorContext != null &&
          navigatorContext.mounted &&
          response.payload != null) {
        final libraryController = navigatorContext.read<LibraryController>();
        final parts = response.payload!.split('/');
        final name = parts[0];

        switch (name) {
          case "contentInfo":
            final entityFilter = libraryController.repo.getContentEntityByStringID(
              parts[1],
            );
            if (entityFilter == null) return;
            await pushToContentInfo(navigatorContext, entityFilter.toContent(), true);
        }
      }
    });
  }

  static Future<void> pushToContentInfo(
    BuildContext context,
    Content content,
    bool isLibrary,
  ) async {
    final go = GoRouter.of(context);
    final path = go.state.path;
    dynamic result;
    final extra = ContentInformationArgs(content: content, isLibrary: isLibrary);
    if (path != null && path.contains(RouteName.CONTENTINFO.subRouter)) {
      result = await context.pushReplacementEnum(RouteName.CONTENTINFO, extra: extra);
    } else {
      // context.goEnum(
      //   RouteName.CONTENTINFO,
      //   extra: ContentInformationArgs(content: content, isLibrary: isLibrary),
      // );
      result = await context.pushEnum(RouteName.CONTENTINFO, extra: extra);

      // final result = await go.push(
      //   RouteName.CONTENTINFO.route,
      //   extra: ContentInformationArgs(content: content, isLibrary: isLibrary),
      // );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _error(result);
    });
  }

  static void _error(Object? result) {
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted && result != null) {
      context.showErrorNotification(result.toString());
    }
  }
}
