import 'package:app_wsrb_jsr/app/ui/content_information/widgets/release_controls.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/release_content.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer_container.dart';
import 'package:app_wsrb_jsr/app/utils/release_utils.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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

    final bool releasesIsLoading = ContentScope.releasesIsLoadingOf(context);
    final AppConfigController appConfigController = context.watch<AppConfigController>();
    final ValueNotifierList valueNotifierList = context.watch<ValueNotifierList>();

    final isLoading = ContentScope.isLoadingOf(context);
    //  ContentScope.isLoadingOf(context);

    final releases = content.releases.sorted().reverse(
      appConfigController.config.reverseContents,
    );

    // final bottomMenuController = BottomMenu.menuControllerMaybeOf<List<String>>(context);

    final onLongPressed = ContentScope.maybeOf(context)?.onLongPressed;

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 4),
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children: [
        ReleaseControls(content: content),
        if (releasesIsLoading)
          SizedBox(
            height: 400,
            child: Center(
              child: LoadingAnimationWidget.halfTriangleDot(
                color: themeData.colorScheme.primary,
                size: 120,
              ),
            ),
          )
        else
          ...List.generate(isLoading ? 12 : releases.length, (index) {
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
                  contentPadding: const EdgeInsets.only(left: 16.0, right: 8),
                  leading: ShimmerContainer(
                    width: 110,
                    borderRadius: BorderRadius.circular(8),
                    enable: isLoading,
                    child: const SizedBox.expand(),
                  ),
                  titleTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  minVerticalPadding: 0,
                  minTileHeight: 76,
                  visualDensity: const VisualDensity(vertical: 4, horizontal: -2),
                  title: ShimmerContainer(
                    height: 20,
                    enable: isLoading,
                    child: const SizedBox.expand(),
                  ),
                ),
              );
            }

            final release = releases.elementAt(index);

            // Estado da UI
            final isSelected = valueNotifierList.contains(release.stringID);

            final cacheSize = context.calculateImageCacheSize(
              displayHeight: 70,
              displayWidth: 120,
              optimizeMemory: true,
            );

            return ReleaseContent(
              content: content,
              release: release,
              leading: ReleaseLeading(
                width: 120,
                height: 70,
                memCacheHeight: cacheSize.height.round(),
                memCacheWidth: cacheSize.width.round(),
                content: content,
                release: release,
                // onTap: () => ReleaseUtils.onTap(context, release, content, index),
                onTap: valueNotifierList.isNotEmpty
                    ? () => onLongPressed?.call(release)
                    : () => ReleaseUtils.onTap(context, release, content, index),
              ),
              index: index,
              selected: isSelected,
              onTap: valueNotifierList.isNotEmpty
                  ? (_) => onLongPressed?.call(release)
                  : null,
              onLongPress: (_) => onLongPressed?.call(release),
              onDoubleTap: (release) => ReleaseUtils.onDoubleTap(context, release),
            );
          }),
        // AnimatedSwitcher(
        //   duration: const Duration(milliseconds: 300),
        //   child: releasesIsLoading
        //       ? SizedBox(
        //           height: 400,
        //           child: Center(
        //             child: LoadingAnimationWidget.halfTriangleDot(
        //               color: themeData.colorScheme.primary,
        //               size: 120,
        //             ),
        //           ),
        //         )
        //       : Column(
        //           children: List.generate(isLoading ? 12 : releases.length, (index) {
        //             if (isLoading) {
        //               return Padding(
        //                 padding: const EdgeInsets.symmetric(vertical: 2),
        //                 child: ListTile(
        //                   dense: true,
        //                   isThreeLine: false,
        //                   subtitle: ShimmerContainer(
        //                     height: 20,
        //                     enable: isLoading,
        //                     child: const SizedBox.expand(),
        //                   ),
        //                   horizontalTitleGap: 20,
        //                   contentPadding: const EdgeInsets.only(left: 16.0, right: 8),
        //                   leading: ShimmerContainer(
        //                     width: 110,
        //                     borderRadius: BorderRadius.circular(8),
        //                     enable: isLoading,
        //                     child: const SizedBox.expand(),
        //                   ),
        //                   titleTextStyle: Theme.of(context).textTheme.titleMedium
        //                       ?.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
        //                   minVerticalPadding: 0,
        //                   minTileHeight: 76,
        //                   visualDensity: const VisualDensity(vertical: 4, horizontal: -2),
        //                   title: ShimmerContainer(
        //                     height: 20,
        //                     enable: isLoading,
        //                     child: const SizedBox.expand(),
        //                   ),
        //                 ),
        //               );
        //             }

        //             final release = releases.elementAt(index);

        //             final bottomMenuController =
        //                 BottomMenu.menuControllerMaybeOf<List<String>>(context);

        //             // Estado da UI
        //             final selectedIDs = bottomMenuController?.args ?? const [];
        //             final isSelected = selectedIDs.contains(release.stringID);

        //             final cacheSize = context.calculateImageCacheSize(
        //               displayHeight: 70,
        //               displayWidth: 120,
        //               optimizeMemory: true,
        //             );

        //             return ReleaseContent(
        //               content: content,
        //               release: release,
        //               leading: ReleaseLeading(
        //                 width: 120,
        //                 height: 70,
        //                 memCacheHeight: cacheSize.height.round(),
        //                 memCacheWidth: cacheSize.width.round(),
        //                 content: content,
        //                 release: release,
        //                 onTap: () => ReleaseUtils.onTap(context, release, content, index),
        //               ),
        //               onTap: list.isNotEmpty ? (_) => onLongPressed?.call(release) : null,
        //               index: index,
        //               selected: isSelected,
        //               onLongPress: (release) => onLongPressed?.call(release),
        //               onDoubleTap: (release) =>
        //                   ReleaseUtils.onDoubleTap(context, release),
        //             );
        //           }),
        //         ),
        // ),
      ],
    );
  }
}
