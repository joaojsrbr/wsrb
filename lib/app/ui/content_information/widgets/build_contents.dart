import 'package:content_library/content_library.dart';

import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/reading/arguments/reading_args.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/list_dismissible.dart';
import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class BuildContents extends StatelessWidget {
  const BuildContents({super.key});

  @override
  Widget build(BuildContext context) {
    final HiveController hiveController = context.watch<HiveController>();
    final bool isLoading = BookInformationScope.isLoadingOf(context);
    final ThemeData themeData = Theme.of(context);
    final releases = BookInformationScope.releasesOf(context);
    Widget container = const SliverToBoxAdapter();

    if (isLoading) {
      container = SliverFillRemaining(
        child: ShimmerLoading(
          isLoading: isLoading,
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
    } else if (releases.isNotEmpty) {
      final index = BookInformationScope.indexOf(context);
      final releasesIndex = BookInformationScope.releasesOf(context)
          .elementAt(index)
          .reverse(hiveController.reverseContents);
      final content = BookInformationScope.contentOf(context);

      container = SliverAnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: ListDismissible(
          // key: ValueKey(hiveController.contentOrders),
          isSliver: true,
          titleTextStyle: themeData.textTheme.labelLarge,
          releases: Releases.fromList(releasesIndex),
          onTap: (Release data) async {
            customLog(
              'tapped name: ${data.title} - id: ${data.id}',
            );

            final GoRouter goRouter = GoRouter.of(context);

            if (data is Chapter && content is Book) {
              await goRouter.push(
                RouteName.READ,
                extra: ReadingViewArgs(
                  capturedThemes: InheritedTheme.capture(
                    from: context,
                    to: Navigator.of(context).context,
                  ),
                  chapter: data,
                  releases: releasesIndex,
                  currentIndex: index,
                  book: content,
                ),
              );
            } else if (data is Episode && content is Anime) {
              await goRouter.push(
                RouteName.PLAYER,
                extra: PlayerArgs(
                  anime: content,
                  capturedThemes: InheritedTheme.capture(
                    from: context,
                    to: Navigator.of(context).context,
                  ),
                  episode: data,
                ),
              );
            }
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
