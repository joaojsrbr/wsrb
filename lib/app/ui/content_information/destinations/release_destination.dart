import 'dart:io';

import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/reading/arguments/reading_args.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ReleaseDestination extends StatefulWidget {
  const ReleaseDestination({super.key});

  @override
  State<ReleaseDestination> createState() => _ReleaseDestinationState();
}

class _ReleaseDestinationState extends State<ReleaseDestination>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final downloadRelease = ContentScope.of(context).downloadRelease;
    final Content content = ContentScope.contentOf(context);
    final DownloadService downloadService = context.watch<DownloadService>();
    final bool releasesIsLoading = ContentScope.releasesIsLoadingOf(context);
    final HiveController hiveController = context.watch<HiveController>();
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 4),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const _ReleasePagination(),
        if (releasesIsLoading)
          const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator.adaptive()),
          )
        else
          ...List.generate(
            content.releases.length,
            (index) {
              final release = content.releases
                  .reverse(hiveController.reverseContents)
                  .elementAt(index);

              final releaseFile = AppStorage.getReleaseFile(content, release);

              final DownloadInfo? downloadInfo =
                  downloadService.downloadList.firstWhereOrNull(
                (info) => info.releaseId.contains(release.stringID),
              );

              final downloaded = releaseFile?.existsSync() ?? false;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ChangeNotifierProvider.value(
                  value: downloadInfo,
                  builder: (context, child) {
                    final downloadInfo = context.watch<DownloadInfo?>();

                    return GestureDetector(
                      onDoubleTap: release is Episode &&
                              release.sinopse?.isNotEmpty == true
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          release.sinopse!.trim(),
                                          textAlign: TextAlign.justify,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
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
                            ? Text(
                                'speed: ${downloadInfo?.speed.toStringAsFixed(2)}')
                            : const Text(''),
                        horizontalTitleGap: 20,
                        contentPadding: const EdgeInsets.only(
                          left: 16.0,
                          right: 8,
                        ),
                        trailing: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: downloadInfo?.isDownloading == true &&
                                  !downloaded
                              ? () async {
                                  final result = await showAdaptiveDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                            'Cancelar download do episódio ${release.number} ?'),
                                        actionsAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('NÃO'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text(
                                              'SIM',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (result == true &&
                                      downloadInfo?.id != null) {
                                    await downloadService.cancelReleaseDownload(
                                      content: content,
                                      release: release,
                                      sessionId: downloadInfo!.id,
                                    );

                                    await downloadService.deleteReleaseFile(
                                      content: content,
                                      release: release,
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
                                            actionsAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                                child: const Text(
                                                  'NÃO',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
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
                                      downloadRelease(release);
                                    },
                          icon: downloadInfo?.isDownloading == true
                              ? downloadInfo?.videoDuration != null &&
                                      (downloadInfo?.time ?? 0) > 0.0
                                  ? SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: TweenAnimationBuilder(
                                        curve: Curves.easeInOut,
                                        duration: Duration.zero,
                                        tween: Tween<double>(
                                          begin: 0.0,
                                          end: (((downloadInfo!.time * 100) /
                                                  downloadInfo.videoDuration!
                                                      .inMilliseconds) /
                                              100),
                                        ),
                                        builder: (
                                          context,
                                          value,
                                          child,
                                        ) {
                                          return Stack(
                                            children: [
                                              CircularProgressIndicator
                                                  .adaptive(
                                                value: value,
                                                strokeAlign: -2,
                                                strokeWidth: 3,
                                              ),
                                              Center(
                                                child: Text(
                                                  (value * 100)
                                                      .ceil()
                                                      .toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    )
                                  : const SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator.adaptive(
                                        strokeAlign: -2,
                                        strokeWidth: 3,
                                      ),
                                    )
                              : Icon(
                                  MdiIcons.downloadCircle,
                                  size: 32,
                                  color: downloaded ? Colors.green : null,
                                ),
                        ),
                        leading: SizedBox(
                          width: 110,
                          height: double.infinity,
                          child: release is Episode && release.thumbnail != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    httpHeaders: {
                                      ...App.HEADERS,
                                      'Referer':
                                          '${hiveController.source.baseURL}/',
                                    },
                                    imageUrl: release.thumbnail!,
                                    placeholder: (context, url) =>
                                        const Card.filled(),
                                    errorWidget: (context, url, error) {
                                      return const Card.filled();
                                    },
                                    fit: BoxFit.cover,
                                    maxWidthDiskCache: 200,
                                    maxHeightDiskCache: 150,
                                  ),
                                )
                              : const Card.filled(),
                        ),
                        titleTextStyle: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontSize: 13, fontWeight: FontWeight.bold),
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
                                chapter: release,
                                currentIndex: index,
                                book: content,
                              ),
                            );
                          } else if (release is Episode && content is Anime) {
                            final result =
                                await _fileOrURL(release, releaseFile, context);
                            if (result != null) {
                              await goRouter.push(
                                RouteName.PLAYER,
                                extra: PlayerArgs(
                                  data: result,
                                  anime: content,
                                  episode: release,
                                ),
                              );
                            }
                          }
                        },
                        minVerticalPadding: 0,
                        minTileHeight: 68,
                        visualDensity:
                            const VisualDensity(vertical: 4, horizontal: -2),
                        title: Text(
                          '${release.number}. ${release.title}',
                          maxLines: 2,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          )
      ],
    );
  }

  Future<Data?> _fileOrURL(
    Release release,
    File? file,
    BuildContext context,
  ) async {
    final repository = context.read<ContentRepository>();

    final data = (await repository.getContent(release))
        .fold(onSuccess: (success) => success)
        ?.nonNulls
        .cast<Data?>()
        .toList();

    if (!context.mounted || data == null) return null;

    data.insert(0, null);

    if (file != null) data[0] = FileVideoData(file: file);

    return await showModalBottomSheet<Data?>(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return Column(
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
                                color: video == null
                                    ? Colors.grey
                                    : video is VideoData
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
                                onTap: video == null
                                    ? null
                                    : () => Navigator.of(context).pop(video),
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
      },
    );
  }
}

class _ReleasePagination extends StatefulWidget {
  const _ReleasePagination();

  @override
  State<_ReleasePagination> createState() => _ReleasePaginationState();
}

class _ReleasePaginationState extends State<_ReleasePagination>
    with AutomaticKeepAliveClientMixin {
  late Content _content;

  List<int> _totalPage = [];
  BoolList _selectChips = BoolList.empty();

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    _content = ContentScope.contentOf(context);
    final index = ContentScope.indexOf(context);

    if (_content case Anime data
        when data.totalOfEpisodes != null && data.totalOfPages != null) {
      _totalPage = List.generate(data.totalOfPages!, (index) => index + 1);
    } else {
      _totalPage = List.generate(
        _content.releases.partition(20).length,
        (index) => index + 1,
      );
    }

    if (_totalPage.length != _selectChips.length) {
      _selectChips = BoolList.generate(
        _totalPage.length,
        (index) => false,
      );
    }

    if (!_selectChips[index]) {
      final indexOf = _selectChips.indexWhere((select) => select);
      _selectChips[index] = true;
      if (indexOf != -1) _selectChips[indexOf] = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final hiveController = context.watch<HiveController>();
    final setListIndex = ContentScope.of(context).setListIndex;

    // final chipsWidgets = List.generate(_selectChips.length, (index) {
    //   int page = _totalPage[index];

    //   return Padding(
    //     padding: const EdgeInsets.only(right: 8),
    //     child: ChoiceChip(
    //       padding: const EdgeInsets.symmetric(horizontal: 8),
    //       selected: _selectChips[index],
    //       onSelected: (value) => setListIndex.call(index),
    //       label: Text('$page'),
    //     ),
    //   );
    // });

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: SizedBox(
        width: double.infinity,
        height: 36,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          scrollDirection: Axis.horizontal,
          itemCount: _selectChips.length + 2,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return IconButton.filled(
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  iconSize: 21,
                  onPressed: () => hiveController
                      .setReverseContents(!hiveController.reverseContents),
                  icon: FadeThroughTransitionSwitcher(
                    enableSecondChild: !hiveController.reverseContents,
                    duration: const Duration(milliseconds: 350),
                    secondChild: Icon(MdiIcons.sortNumericAscending),
                    child: Icon(MdiIcons.sortNumericDescending),
                  ),
                );

              case 1:
                return const VerticalDivider();
            }

            int page = _totalPage[index - 2];

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                selected: _selectChips[index - 2],
                onSelected: (value) => setListIndex.call(index - 2),
                label: Text('$page'),
              ),
            );
          },
        ),
      ),
    );
  }
}
