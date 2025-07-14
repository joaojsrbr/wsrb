import 'dart:io';

import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/list_tile/leading.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/list_tile/trailing.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/release_chips.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/reading/arguments/reading_args.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/bottom_menu.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer_container.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 4),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ReleaseChips(content: content),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: releasesIsLoading
              ? SizedBox(
                  height: 400,
                  child: Center(
                    child: LoadingAnimationWidget.halfTriangleDot(
                      color: themeData.colorScheme.primary,
                      size: 120,
                    ),
                  ),
                )
              : Column(
                  // padding: EdgeInsets.zero,
                  // // separatorBuilder: (context, index) => Divider(
                  // //   indent: 12,
                  // //   endIndent: 12,
                  // // ),
                  // itemCount: isLoading ? 6 : releases.length,
                  // physics: NeverScrollableScrollPhysics(),
                  // shrinkWrap: true,
                  children:
                      List.generate(isLoading ? 6 : releases.length, (index) {
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
                  }),
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
        ),
      ],
    );
  }
}

class _ReleaseSubtitle extends StatelessWidget {
  const _ReleaseSubtitle({required this.release});

  final Release release;

  @override
  Widget build(BuildContext context) {
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

    final onLongPressed = ContentScope.of(context).onLongPressed;

    final bottomMenuController =
        BottomMenu.menuControllerOf<List<String>>(context);

    final list = bottomMenuController.args ?? const [];

    return InkWell(
      onTap: () =>
          list.isNotEmpty ? onLongPressed(release) : _listTitleOntap(context),
      onDoubleTap: () => onDoubleTap(context),
      splashFactory: InkRipple.splashFactory,
      onLongPress: () => onLongPressed(release),
      overlayColor: _OverlayColor(colorScheme),
      child: ChangeNotifierProvider.value(
        value: downloadInfo,
        builder: (context, child) {
          return ListTile(
            isThreeLine: false,
            dense: true,
            // isThreeLine: false,
            subtitle: _ReleaseSubtitle(release: release),
            horizontalTitleGap: 20,
            contentPadding: const EdgeInsets.only(
              left: 16.0,
              right: 8,
            ),
            trailing: ReleaseTrailing(
              content: content,
              release: release,
            ),
            leading: ReleaseLeading(
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
