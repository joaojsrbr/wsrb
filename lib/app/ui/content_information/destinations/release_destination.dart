import 'dart:io';

import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/reading/arguments/reading_args.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer_container.dart';
import 'package:border_progress_indicator/border_progress_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
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
    final content = ContentScope.contentOf(context);
    final themeData = Theme.of(context);
    final DownloadService downloadService = context.watch<DownloadService>();
    final bool releasesIsLoading = ContentScope.releasesIsLoadingOf(context);
    final AppConfigController appConfigController =
        context.watch<AppConfigController>();

    final isLoading = ContentScope.isLoadingOf(context);

    final releases = content.releases
        .sorted()
        .reverse(appConfigController.config.reverseContents);

    return releasesIsLoading
        ? Center(
            child: LoadingAnimationWidget.halfTriangleDot(
              color: themeData.colorScheme.primary,
              size: 120,
            ),
          )
        : ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 4),
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _ReleasePagination(content: content),
              ListView.builder(
                padding: EdgeInsets.zero,
                // separatorBuilder: (context, index) => Divider(
                //   indent: 12,
                //   endIndent: 12,
                // ),
                itemCount: isLoading ? 6 : releases.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  if (isLoading) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: ListTile(
                        dense: true,
                        isThreeLine: false,
                        subtitle: ShimmerContainer(
                          height: 20,
                          enable: isLoading,
                          child: const SizedBox.expand(),
                        ),
                        horizontalTitleGap: 20,
                        contentPadding: const EdgeInsets.only(
                          left: 16.0,
                          right: 8,
                        ),
                        leading: ShimmerContainer(
                          width: 110,
                          borderRadius: BorderRadius.circular(8),
                          enable: isLoading,
                          child: const SizedBox.expand(),
                        ),
                        titleTextStyle:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                        minVerticalPadding: 0,
                        minTileHeight: 76,
                        visualDensity:
                            const VisualDensity(vertical: 4, horizontal: -2),
                        title: ShimmerContainer(
                          height: 20,
                          enable: isLoading,
                          child: const SizedBox.expand(),
                        ),
                      ),
                    );
                  }

                  final release = releases.elementAt(index);

                  return ReleaseContent(
                    content: content,
                    release: release,
                    downloadService: downloadService,
                    index: index,
                  );
                },
              ),
              // ...List.generate(
              //   isLoading ? 6 : releases.length,
              //   (index) {
              //     if (isLoading) {
              //       return Padding(
              //         padding: const EdgeInsets.symmetric(vertical: 2),
              //         child: ListTile(
              //           dense: true,
              //           isThreeLine: false,
              //           subtitle: ShimmerContainer(
              //             height: 20,
              //             enable: isLoading,
              //             child: const SizedBox.expand(),
              //           ),
              //           horizontalTitleGap: 20,
              //           contentPadding: const EdgeInsets.only(
              //             left: 16.0,
              //             right: 8,
              //           ),
              //           leading: ShimmerContainer(
              //             width: 110,
              //             borderRadius: BorderRadius.circular(8),
              //             enable: isLoading,
              //             child: const SizedBox.expand(),
              //           ),
              //           titleTextStyle:
              //               Theme.of(context).textTheme.titleMedium?.copyWith(
              //                     fontSize: 13,
              //                     fontWeight: FontWeight.bold,
              //                   ),
              //           minVerticalPadding: 0,
              //           minTileHeight: 76,
              //           visualDensity:
              //               const VisualDensity(vertical: 4, horizontal: -2),
              //           title: ShimmerContainer(
              //             height: 20,
              //             enable: isLoading,
              //             child: const SizedBox.expand(),
              //           ),
              //         ),
              //       );
              //     }

              //     final release = releases.elementAt(index);

              //     return ReleaseContent(
              //       content: content,
              //       release: release,
              //       downloadService: downloadService,
              //       index: index,
              //     );
              //   },
              // )
            ],
          );
  }
}

class _ReleaseSubtitle extends StatelessWidget {
  const _ReleaseSubtitle({required this.release});

  final Release release;

  @override
  Widget build(BuildContext context) {
    // final HistoricController historicController =
    //     context.watch<HistoricController>();

    // final historicRepo = historicController.repo;

    // final HistoryEntity? historic = historicRepo.getHistoric(
    //   release: release,
    // );

    // final percent = historic?.getPercent();

    // final themeData = Theme.of(context);

    // final episodeDuration = (historic?.epdToDuration ?? Duration.zero);
    // final episodeCurrentDuration = (historic?.cdToDuration ?? Duration.zero);

    // final DownloadInfo? downloadInfo = context.watch();

    // if (downloadInfo?.isDownloading == true &&
    //     (downloadInfo?.speed ?? 0.0) > 0.0) {
    //   return Text.rich(
    //     TextSpan(
    //       children: [
    //         if (downloadInfo?.videoDuration != null &&
    //             (downloadInfo?.time ?? 0) > 0.0)
    //           TextSpan(
    //             text: downloadInfo!.getStringDownloadPercent(),
    //             style: Theme.of(context).textTheme.labelSmall,
    //           ),
    //         TextSpan(text: downloadInfo!.getSpeedString()),
    //       ],
    //     ),
    //   );
    // } else if (episodeDuration != Duration.zero &&
    //     episodeCurrentDuration != Duration.zero &&
    //     (percent != null && percent > 0.0)) {
    //   final label = episodeCurrentDuration.label(
    //     reference: historic?.epdToDuration ?? Duration.zero,
    //   );
    //   return Column(
    //     mainAxisSize: MainAxisSize.min,
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       if (release case Episode data when data.registrationData != null) ...[
    //         Row(
    //           mainAxisSize: MainAxisSize.min,
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Icon(MdiIcons.clock, size: 16),
    //             const SizedBox(width: 4),
    //             Text(timeago.format(data.registrationData!)),
    //           ],
    //         ),
    //       ],
    //       Text.rich(
    //         TextSpan(
    //           children: [
    //             // if (release case Episode data
    //             //     when data.registrationData != null) ...[
    //             //   WidgetSpan(child: Icon(MdiIcons.clock, size: 16)),
    //             //   WidgetSpan(child: const SizedBox(width: 4)),
    //             //   TextSpan(text: timeago.format(data.registrationData!)),
    //             //   TextSpan(text: " - "),
    //             // ],
    //             TextSpan(
    //               text: label,
    //               style: TextStyle(
    //                 color: historic?.completeColor(
    //                   themeData.colorScheme,
    //                 ),
    //               ),
    //             ),
    //             const TextSpan(text: " / "),
    //             TextSpan(text: episodeDuration.label()),
    //           ],
    //         ),
    //       ),
    //     ],
    //   );
    // }

    if (release case Episode data when data.registrationData != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(MdiIcons.clock, size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                data.formatRegistrationData(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _ReleaseTrailing extends StatelessWidget {
  const _ReleaseTrailing({required this.release, required this.content});

  final Release release;

  final Content content;

  @override
  Widget build(BuildContext context) {
    final releaseFile = AppStorage.getReleaseFile(content, release);

    final downloaded = releaseFile?.existsSync() ?? false;
    final downloadInfo = context.watch<DownloadInfo?>();
    final downloadService = context.watch<DownloadService>();

    final downloadRelease = ContentScope.of(context).downloadRelease;

    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: downloadInfo?.isDownloading == true
          ? () async {
              final result = await showAdaptiveDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      'Cancelar download do episódio ${release.number} ?',
                    ),
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
                          'Deseja deletar o episódio ${release.number} ?',
                        ),
                        actionsAlignment: MainAxisAlignment.spaceBetween,
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(
                              'NÃO',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
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
          ? Icon(
              MdiIcons.close,
              size: 28,
              color: Colors.red,
            )
          // ? downloadInfo?.videoDuration != null &&
          //         (downloadInfo?.time ?? 0) > 0.0
          //     ? SizedBox(
          //         width: 32,
          //         height: 32,
          //         child: TweenAnimationBuilder(
          //           curve: Curves.easeInOut,
          //           duration: Duration.zero,
          //           tween: Tween<double>(
          //             begin: 0.0,
          //             end: (((downloadInfo!.time * 100) /
          //                     downloadInfo.videoDuration!.inMilliseconds) /
          //                 100),
          //           ),
          //           builder: (context, value, child) {
          //             return Stack(
          //               children: [
          //                 // CircularProgressIndicator.adaptive(
          //                 //   value: value,
          //                 //   strokeAlign: -2,
          //                 //   strokeWidth: 3,
          //                 // ),
          //                 Center(
          //                   child: Text(
          //                     "${(value * 100).ceil().toString()}%",
          //                     style: Theme.of(context).textTheme.labelSmall,
          //                   ),
          //                 ),
          //               ],
          //             );
          //           },
          //         ),
          //       )
          //     : const SizedBox(
          //         width: 32,
          //         height: 32,
          //         child: CircularProgressIndicator.adaptive(
          //           strokeAlign: -2,
          //           strokeWidth: 3,
          //         ),
          //       )
          : Icon(
              MdiIcons.download,
              size: 28,
              color: downloaded ? Colors.blueAccent : null,
            ),
    );
  }
}

class _ReleaseLeading extends StatelessWidget {
  const _ReleaseLeading({
    required this.release,
    required this.content,
  });

  final Release release;
  final Content content;

  @override
  Widget build(BuildContext context) {
    final HistoricController historicController =
        context.watch<HistoricController>();

    final historicRepo = historicController.repo;

    final colorScheme = Theme.of(context).colorScheme;

    final historic = historicRepo.getHistoric(release: release);

    final percent = historic?.getPercent();

    final AppConfigController appConfigController =
        context.watch<AppConfigController>();

    final color = historic?.isComplete == true
        ? colorScheme.primary
        : colorScheme.secondary;

    final episodeDuration = (historic?.epdToDuration ?? Duration.zero);
    final episodeCurrentDuration = (historic?.cdToDuration ?? Duration.zero);

    return SizedBox(
      width: 110,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          release is Episode && (release as Episode).thumbnail != null
              ? Builder(
                  builder: (context) {
                    Widget container = ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        cacheManager: App.APP_IMAGE_CACHE,
                        httpHeaders: {
                          ...App.HEADERS,
                          'Referer':
                              '${appConfigController.config.source.baseURL}/',
                        },
                        imageUrl: (release as Episode).thumbnail!,
                        placeholder: (context, url) => Card.filled(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          return Card.filled(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        },
                        fit: BoxFit.cover,
                        memCacheWidth: 200,
                        memCacheHeight: 150,
                      ),
                    );

                    // video == null
                    //     ? Colors.grey
                    //     : video is VideoData
                    //         ? colorScheme.primary
                    //         : colorScheme.secondaryContainer;

                    final DownloadInfo? downloadInfo = context.watch();

                    if (downloadInfo?.isDownloading == true &&
                        downloadInfo?.videoDuration != null &&
                        (downloadInfo?.time ?? 0) > 0.0) {
                      final percent = ((downloadInfo!.time * 100) /
                          downloadInfo.videoDuration!.inMilliseconds);

                      customLog(percent);
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          container,
                          AnimatedBorderProgressIndicator(
                            value: percent / 100,
                            color: color,
                            strokeWidth: 2,
                            borderRadius: 6,
                          ),
                        ],
                      );
                    }
                    // TextSpan(
                    //   text:
                    //       '${(((downloadInfo!.time * 100) / downloadInfo.videoDuration!.inMilliseconds)).ceil().toString()}%',
                    //   style: Theme.of(context).textTheme.labelSmall,
                    // ),

                    if (percent != null && percent > 0.0) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          container,
                          AnimatedBorderProgressIndicator(
                            value: percent,
                            color: color,
                            strokeWidth: 2,
                            borderRadius: 6,
                          ),
                        ],
                      );
                    }

                    return container;
                  },
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    const Card.filled(),
                    if (percent != null && percent > 0.0)
                      AnimatedBorderProgressIndicator(
                        value: percent,
                        color: color,
                        strokeWidth: 6,
                        borderRadius: 6,
                      ),
                  ],
                ),
          if (episodeDuration != Duration.zero &&
              episodeCurrentDuration != Duration.zero &&
              (percent != null && percent > 0.0))
            Positioned(
              top: 4,
              right: 6,
              child: Builder(
                builder: (context) {
                  final label = episodeCurrentDuration.label(
                    reference: historic?.epdToDuration ?? Duration.zero,
                  );
                  return Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: label,
                          style: TextStyle(
                            color: historic?.completeColor(colorScheme),
                          ),
                        ),
                        // const TextSpan(text: " / "),
                        // TextSpan(text: episodeDuration.label()),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class ReleaseContent extends StatelessWidget {
  const ReleaseContent({
    super.key,
    required this.release,
    required this.content,
    required this.downloadService,
    required this.index,
  });
  final DownloadService downloadService;
  final int index;
  final Release release;
  final Content content;

  @override
  Widget build(BuildContext context) {
    final DownloadInfo? downloadInfo =
        downloadService.downloadList.firstWhereOrNull(
      (info) => info.releaseId.contains(release.stringID),
    );
    // final isLoading = ContentScope.isLoadingOf(context);
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => _listTitleOntap(context),
      onDoubleTap: () => onDoubleTap(context),
      splashFactory: InkRipple.splashFactory,
      overlayColor: _OverlayColor(colorScheme),
      child: ChangeNotifierProvider.value(
        value: downloadInfo,
        builder: (context, child) {
          return ListTile(
            isThreeLine: false,
            dense: true,
            // onLongPress: () =>
            //     ContentScope.of(context).onLongPressed(release),
            // isThreeLine: false,
            subtitle: _ReleaseSubtitle(release: release),
            horizontalTitleGap: 20,
            contentPadding: const EdgeInsets.only(
              left: 16.0,
              right: 8,
            ),
            trailing: _ReleaseTrailing(
              content: content,
              release: release,
            ),
            leading: _ReleaseLeading(
              content: content,
              release: release,
            ),
            subtitleTextStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFFB0B0B0), // cinza claro para contraste no dark
              height: 1.3,
            ),
            titleTextStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
              overflow: TextOverflow.ellipsis,
            ),
            // onTap: () => _listTitleOntap(context),
            onTap: null,
            minVerticalPadding: 0,
            minTileHeight: 76,
            visualDensity: const VisualDensity(vertical: 3, horizontal: -2),
            title: Text(
              '${release.number}. ${release.title}',
              maxLines: 2,
            ),
          );
        },
      ),
    );
  }

  void onDoubleTap(BuildContext context) {
    if (!(release is Episode &&
        (release as Episode).sinopse?.isNotEmpty == true)) {
      return;
    }
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
                (release as Episode).sinopse!.trim(),
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

  void _listTitleOntap(BuildContext context) async {
    final releaseFile = AppStorage.getReleaseFile(content, release);

    customLog(
      'tapped name: ${release.title} - id: ${release.stringID}',
    );

    final GoRouter goRouter = GoRouter.of(context);

    switch ((content, release)) {
      case (Book content, Chapter data):
        await goRouter.push(
          RouteName.READ,
          extra: ReadingViewArgs(
            capturedThemes: InheritedTheme.capture(
              from: context,
              to: Navigator.of(context).context,
            ),
            chapter: data,
            currentIndex: index,
            book: content,
          ),
        );
        break;
      case (Anime content, Episode data):
        final result = await _fileOrURL(release, releaseFile, context);
        if (result != null) {
          await goRouter.push(
            RouteName.PLAYER,
            extra: PlayerArgs(
              data: result,
              anime: content,
              episode: data,
            ),
          );
        }
        break;
    }
  }

  Future<Data?> _fileOrURL(
    Release release,
    File? file,
    BuildContext context,
  ) async {
    final repository = context.read<ContentRepository>();

    final colorScheme = Theme.of(context).colorScheme;

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
                      final color = video == null
                          ? Colors.grey
                          : video is VideoData
                              ? colorScheme.primary
                              : colorScheme.primaryContainer;
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
                                color: color,
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
  const _ReleasePagination({required this.content});

  final Content? content;

  @override
  State<_ReleasePagination> createState() => _ReleasePaginationState();
}

class _ReleasePaginationState extends State<_ReleasePagination> {
  List<int> _totalPage = [];
  BoolList _selectChips = BoolList.empty();

  @override
  void initState() {
    _initSelectChips();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _ReleasePagination oldWidget) {
    if (oldWidget.content != widget.content) {
      _initSelectChips();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _initSelectChips() {
    if (widget.content case Anime data
        when data.totalOfEpisodes != null && data.totalOfPages != null) {
      _totalPage = List.generate(data.totalOfPages!, (index) => index + 1);
    } else {
      // _totalPage = List.generate(
      //   widget.content!.releases.partition(20).length,
      //   (index) => index + 1,
      // );
      _totalPage = List.generate(
        1,
        (index) => index + 1,
      );
    }

    if (_totalPage.length != _selectChips.length) {
      _selectChips = BoolList.generate(
        _totalPage.length,
        (index) => false,
      );
    }
  }

  @override
  void didChangeDependencies() {
    _setSelectChips();
    super.didChangeDependencies();
  }

  void _setSelectChips() {
    final index = ContentScope.indexOf(context);
    if (_selectChips.isEmpty) return;
    if (!_selectChips[index]) {
      final indexOf = _selectChips.indexWhere((select) => select);
      _selectChips[index] = true;
      if (indexOf != -1) _selectChips[indexOf] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.content == null || _selectChips.isEmpty || _totalPage.isEmpty) {
      return const SizedBox(height: 0, width: 0);
    }
    final isLoading = ContentScope.isLoadingOf(context);
    final AppConfigController appConfigController =
        context.watch<AppConfigController>();
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
        width: 100,
        height: 36,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          scrollDirection: Axis.horizontal,
          itemCount: _selectChips.length + 2,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ShimmerContainer(
                  borderRadius: BorderRadius.circular(8),
                  height: 21,
                  width: 40,
                  enable: isLoading,
                  child: IconButton.filled(
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    iconSize: 21,
                    onPressed: () => appConfigController.setReverseContents(
                        !appConfigController.config.reverseContents),
                    icon: FadeThroughTransitionSwitcher(
                      enableSecondChild:
                          !appConfigController.config.reverseContents,
                      duration: const Duration(milliseconds: 350),
                      secondChild: Icon(MdiIcons.sortNumericAscending),
                      child: Icon(MdiIcons.sortNumericDescending),
                    ),
                  ),
                );

              case 1:
                return const VerticalDivider();
            }

            int page = _totalPage[index - 2];

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ShimmerContainer(
                height: 36,
                borderRadius: BorderRadius.circular(8),
                width: 80,
                enable: isLoading,
                child: ChoiceChip(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  selected: _selectChips[index - 2],
                  onSelected: (value) => setListIndex.call(index - 2),
                  label: Text('$page'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OverlayColor extends WidgetStateProperty<Color?> {
  _OverlayColor(ColorScheme colorScheme) {
    _color = colorScheme.primary;
  }

  Color? _color;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) {
      return _color?.withAlpha(36);
    } else if (states.contains(WidgetState.hovered)) {
      return _color?.withAlpha(20);
    } else if (states.contains(WidgetState.focused)) {
      return Colors.transparent;
    }
    return Colors.transparent;
  }
}
