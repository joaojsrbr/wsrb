import 'dart:io';

import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';

import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/reading/arguments/reading_args.dart';
import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class BuildContents extends StatelessWidget {
  const BuildContents({super.key});

  @override
  Widget build(BuildContext context) {
    final bool releasesIsLoading =
        BookInformationScope.releasesIsLoadingOf(context);
    final bool isLoadingOf = BookInformationScope.isLoadingOf(context);
    // final int index = BookInformationScope.indexOf(context);
    // final ThemeData themeData = Theme.of(context);
    final HiveController hiveController = context.watch<HiveController>();
    final Content content = BookInformationScope.contentOf(context);

    Widget container = const SliverToBoxAdapter();

    if (isLoadingOf || releasesIsLoading) {
      container = SliverFillRemaining(
        // child: Center(child: CircularProgressIndicator()),
        child: releasesIsLoading && !isLoadingOf
            ? const Center(child: CircularProgressIndicator())
            : ShimmerLoading(
                isLoading: isLoadingOf,
                child: const Material(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(),
                    margin: EdgeInsets.zero,
                    child: SizedBox.expand(),
                  ),
                ),
              ),
      );
    } else if (content.releases.isNotEmpty && !releasesIsLoading) {
      final List<Release> releases = content.releases
          // .slices(20)
          // .elementAt(index)
          .reverse(hiveController.reverseContents)
          .toList();

      final DownloadService downloadService = context.watch<DownloadService>();

      container = SliverPadding(
        padding: const EdgeInsets.only(bottom: 12),
        sliver: SliverList.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemCount: releases.length,
          itemBuilder: (context, index) {
            final Release release = releases[index];

            final DownloadInfo? downloadInfo =
                downloadService.downloadList.firstWhereOrNull(
              (info) => info.releaseId.contains(release.stringID),
            );

            if (downloadInfo != null) {
              return AnimatedBuilder(
                animation: downloadInfo,
                builder: (context, child) {
                  return _ContentWidget(
                    content,
                    release,
                    index,
                    downloadInfo,
                  );
                },
              );
            }
            return _ContentWidget(content, release, index, null);
          },
        ),
      );
    }

    return SliverAnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: container,
    );
  }
}

class _ContentWidget extends StatelessWidget {
  const _ContentWidget(
    this.content,
    this.release,
    this.index,
    this.downloadInfo,
  );

  final Release release;
  final DownloadInfo? downloadInfo;
  final Content content;
  final int index;

  Future<Data?> _fileOrURL(File file, BuildContext context) async {
    final repository = context.read<ContentRepository>();

    final data = (await repository.getContent(release))
        .fold(onSuccess: (success) => success)
        ?.nonNulls
        .toList();

    if (!context.mounted || data == null) return null;

    data.insert(0, FileVideoData(file: file));

    return await showModalBottomSheet<Data?>(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return StatefulBuilder(builder: (context, s) {
          return Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                ),
                child: Text(
                  'Selecione uma fonte',
                  style: textTheme.titleLarge,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(data.length, (index) {
                        final video = data[index];
                        return Container(
                          height: 70,
                          width: 120,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: video is VideoData
                                      ? Colors.blue
                                      : Colors.green,
                                ),
                              ),
                              Center(
                                child: Text(
                                  video is VideoData ? 'Online' : 'Local',
                                  style: textTheme.labelMedium,
                                ),
                              ),
                              Material(
                                type: MaterialType.transparency,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => Navigator.of(context).pop(video),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DownloadService downloadService = context.watch<DownloadService>();
    String? thumbnail;
    String? sinopse;

    final donwload = BookInformationScope.of(context).downloadRelease;

    if (release is Episode) {
      sinopse = (release as Episode).sinopse ?? '';
      thumbnail = (release as Episode).thumbnail;
    }

    final downloaded = downloadService.existsRelease(content, release);
    return GestureDetector(
      onDoubleTap: sinopse?.isNotEmpty == true
          ? () {
              showModalBottomSheet(
                isScrollControlled: false,
                isDismissible: true,
                showDragHandle: true,
                useRootNavigator: true,
                context: context,
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                        ),
                        child: Text(
                          'Sinopse',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Text(
                          sinopse!.trim(),
                          textAlign: TextAlign.justify,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  );
                },
              );
            }
          : null,
      child: ListTile(
        dense: true,
        isThreeLine: false,
        subtitle: downloadInfo?.isDownloading == true &&
                (downloadInfo?.speed ?? 0) > 0.0
            ? Text('speed: ${downloadInfo?.speed.toStringAsFixed(2)}')
            : const Text(''),
        horizontalTitleGap: 20,
        contentPadding: const EdgeInsets.only(left: 16.0, right: 8),
        trailing: IconButton(
          padding: EdgeInsets.zero,
          onPressed: downloadInfo?.isDownloading == true && !downloaded
              ? () async {
                  final result = await showAdaptiveDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                            'Cancelar download do episódio ${release.number} ?'),
                        actionsAlignment: MainAxisAlignment.spaceBetween,
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('NÃO'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'SIM',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  if (result == true && downloadInfo?.id != null) {
                    downloadService.cancelReleaseDownload(
                      content: content,
                      release: release,
                      sessionId: downloadInfo!.id,
                    );
                  }
                }
              : downloaded
                  ? () async {
                      final result = await showAdaptiveDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                                'Deseja deletar o arquivo ${release.number} ?'),
                            actionsAlignment: MainAxisAlignment.spaceBetween,
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text(
                                  'NÃO',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('SIM'),
                              ),
                            ],
                          );
                        },
                      );

                      if (result == true) {
                        downloadService.deleteReleaseFile(
                          content: content,
                          release: release,
                        );
                      }
                    }
                  : () {
                      donwload.call(release);
                    },
          icon: downloadInfo?.isDownloading == true
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator.adaptive(
                    strokeAlign: -2,
                    strokeWidth: 3,
                  ),
                )
              : Icon(
                  MdiIcons.downloadCircle,
                  color: downloaded ? Colors.green : null,
                ),
        ),
        leading: SizedBox(
          width: 110,
          height: double.infinity,
          child: thumbnail != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: thumbnail,
                    placeholder: (context, url) => const Card.filled(),
                    fit: BoxFit.cover,
                    maxWidthDiskCache: 300,
                    maxHeightDiskCache: 200,
                  ),
                )
              : const Card.filled(),
        ),
        titleTextStyle: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
        onTap: () async {
          customLog(
            'tapped name: ${release.title} - id: ${release.stringID}',
          );

          final GoRouter goRouter = GoRouter.of(context);

          if (release is Chapter && content is Book) {
            await goRouter.push(
              RouteName.READ,
              extra: ReadingViewArgs(
                capturedThemes: InheritedTheme.capture(
                  from: context,
                  to: Navigator.of(context).context,
                ),
                chapter: release as Chapter,
                currentIndex: index,
                book: content as Book,
              ),
            );
          } else if (release is Episode && content is Anime) {
            File? videoFile;

            if (downloadService.existsRelease(content, release)) {
              videoFile = downloadService.getReleasFile(content, release);
            }

            if (videoFile != null) {
              final result = await _fileOrURL(videoFile, context);
              if (result != null) {
                await goRouter.push(
                  RouteName.PLAYER,
                  extra: PlayerArgs(
                    data: result,
                    anime: content as Anime,
                    episode: release as Episode,
                  ),
                );
              }
              return;
            }

            await goRouter.push(
              RouteName.PLAYER,
              extra: PlayerArgs(
                anime: content as Anime,
                episode: release as Episode,
              ),
            );
          }
        },
        // onLongPress: () {},
        minVerticalPadding: 0,
        minTileHeight: 68,
        visualDensity: const VisualDensity(vertical: 4, horizontal: -2),
        title: Text(
          '${release.number}. ${release.title}',
          maxLines: 2,
        ),
      ),
    );
  }
}
