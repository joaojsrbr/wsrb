import 'package:app_wsrb_jsr/app/models/anime.dart';
import 'package:app_wsrb_jsr/app/models/book.dart';
import 'package:app_wsrb_jsr/app/models/chapter.dart';
import 'package:app_wsrb_jsr/app/models/content.dart';
import 'package:app_wsrb_jsr/app/models/release.dart';
import 'package:app_wsrb_jsr/app/models/episode.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/reading/arguments/reading_args.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/list_dismissible.dart';
import 'package:app_wsrb_jsr/app/utils/custom_log.dart';
import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BuildContents extends StatelessWidget {
  const BuildContents({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = BookInformationScope.isLoadingOf(context);

    if (isLoading) {
      return SliverFillRemaining(
        child: ShimmerLoading(
          isLoading: isLoading,
          child: const Material(child: SizedBox.expand()),
        ),
      );
    }

    final index = BookInformationScope.indexOf(context);
    // final hiveController = context.watch<HiveController>();
    final releases =
        BookInformationScope.releasesOf(context).reversed.elementAt(index);
    final content = BookInformationScope.contentOf(context);

    return ListDismissible(
      isSliver: true,
      titleTextStyle: Theme.of(context).textTheme.labelLarge,
      releases: Releases.fromList(releases),
      onTap: (Release data) async {
        customLog(
          'tapped name: ${data.title} - id: ${data.id}',
        );

        if (data is Chapter && content is Book) {
          await context.push(
            RouteName.READ,
            extra: ReadingViewArgs(
              bookThemeData: Theme.of(context),
              chapter: data,
              releases: releases,
              currentIndex: index,
              book: content,
            ),
          );
        } else if (data is Episode && content is Anime) {
          await context.push(
            RouteName.PLAYER,
            extra: PlayerArgs(anime: content, episode: data),
          );
        }
      },
    );

    // return SliverList.builder(
    //   itemBuilder: (context, index) {
    //     final dataContent = dataContents[index];

    //     return CustomDismissible(
    //       onUpdate: (details) {},
    //       dismissThresholds: const {
    //         DismissDirection.endToStart: 0.5,
    //         DismissDirection.startToEnd: 0.5
    //       },
    //       resizeDuration: const Duration(milliseconds: 600),
    //       background: Container(
    //         alignment: Alignment.centerLeft,
    //         decoration: const BoxDecoration(color: Colors.blueAccent),
    //         padding: const EdgeInsets.only(left: 20.0),
    //         child: const Icon(Icons.check, color: Colors.white),
    //       ),
    //       radius: 20,
    //       secondaryBackground: Container(
    //         decoration: const BoxDecoration(color: Colors.redAccent),
    //         alignment: Alignment.centerRight,
    //         padding: const EdgeInsets.only(right: 20.0),
    //         child: const Icon(Icons.delete, color: Colors.white),
    //       ),
    //       key: ValueKey(dataContent.id),
    //       onTap: () async {
    //         customLog(
    //           'tapped name: ${dataContent.title} - id: ${dataContent.id}',
    //         );

    //         if (dataContent is Chapter && content is Book) {
    //           await context.push(
    //             RouteName.READ,
    //             extra: ReadingViewArgs(
    //               bookThemeData: Theme.of(context),
    //               chapter: dataContent,
    //               allDataContent: dataContents,
    //               currentIndex: index,
    //               book: content,
    //             ),
    //           );
    //         } else if (dataContent is Episode && content is Anime) {
    //           await context.push(
    //             RouteName.PLAYER,
    //             extra: PlayerArgs(anime: content, episode: dataContent),
    //           );
    //         }
    //       },
    //       child: ListTile(
    //         titleTextStyle: Theme.of(context).textTheme.labelLarge,
    //         title: Text(dataContent.title),
    //       ),
    //     );
    //   },
    //   itemCount: dataContents.length,
    // );
  }
}
