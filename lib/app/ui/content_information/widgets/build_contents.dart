import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';

import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/reading/arguments/reading_args.dart';
import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      container = SliverPadding(
        padding: const EdgeInsets.only(bottom: 12),
        sliver: SliverList.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemCount: releases.length,
          itemBuilder: (context, index) {
            final Release release = releases[index];
            String? thumbnail;
            String? sinopse;

            if (release is Episode) {
              sinopse = release.sinopse ?? '';
              thumbnail = release.thumbnail;
            }

            return ListTile(
              leading: SizedBox(
                width: 112,
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
                      chapter: release,
                      releases: releases,
                      currentIndex: index,
                      book: content,
                    ),
                  );
                } else if (release is Episode && content is Anime) {
                  await goRouter.push(
                    RouteName.PLAYER,
                    extra: PlayerArgs(anime: content, episode: release),
                  );
                }
              },
              onLongPress: sinopse?.isNotEmpty == true
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
              visualDensity: const VisualDensity(vertical: 2, horizontal: -2),
              title: Text('${release.number}. ${release.title}'),
            );
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
