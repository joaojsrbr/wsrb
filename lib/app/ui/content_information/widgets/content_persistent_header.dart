import 'package:app_wsrb_jsr/app/utils/copy_to_clipboard.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'scope.dart';

class ContentHeader extends StatelessWidget {
  const ContentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final content = ContentScope.contentOf(context);

    final themeData = Theme.of(context);

    return Material(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // if (content.anilistMedia?.bannerImage?.extraLarge != null)
          //   Card(
          //     color: themeData.colorScheme.surface,
          //   ),
          // ImageFiltered(
          //   imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 8),
          //   child: CachedNetworkImage(
          //     scale: 20,
          //     filterQuality: FilterQuality.medium,
          //     fit: BoxFit.cover,
          //     placeholder: (context, url) {
          //       return Card.filled(
          //         color: themeData.colorScheme.primary.withAlpha(10),
          //       );
          //     },
          //     imageUrl: content.anilistMedia!.bannerImage!.extraLarge ?? "",
          //     httpHeaders: App.HEADERS,
          //   ),
          // ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 12),
                  height: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          height: 200,
                          width: 140,
                          filterQuality: FilterQuality.medium,
                          placeholder: (context, url) {
                            return Card.filled(
                              color:
                                  themeData.colorScheme.primary.withAlpha(10),
                            );
                          },
                          fit: BoxFit.cover,
                          memCacheHeight: 300,
                          memCacheWidth: 200,
                          imageUrl: content.imageUrl,
                          httpHeaders: App.HEADERS,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 8,
                            top: 8,
                            right: 8,
                            left: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onLongPress: () async {
                                  copyToClipboard(
                                    context,
                                    messageCopy: content.title,
                                    messageSnackBar:
                                        'Copiado para a área de transferência!',
                                  );
                                  await Feedback.forLongPress(context);
                                },
                                child: Text(
                                  content.title,
                                  maxLines: 3,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      themeData.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (content.anilistMedia?.averageScore != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Row(
                                    spacing: 4,
                                    children: [
                                      if (content.anilistMedia?.favourites !=
                                          null) ...[
                                        Icon(
                                          MdiIcons.heart,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                        Text(
                                          content.anilistMedia?.favourites
                                                  .toString() ??
                                              "",
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          style: themeData.textTheme.titleSmall
                                              ?.copyWith(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                      ],
                                      Icon(
                                        MdiIcons.star,
                                        color: Colors.yellow,
                                        size: 18,
                                      ),
                                      Text(
                                        (content.anilistMedia!.averageScore! /
                                                10)
                                            .toString(),
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: themeData.textTheme.titleSmall
                                            ?.copyWith(
                                          color: content.anilistMedia!
                                              .getScoreColor(
                                                  themeData.colorScheme),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class ContentPersistentHeader extends SliverPersistentHeaderDelegate {
//   @override
//   final double maxExtent;

//   @override
//   final double minExtent;

//   final Content content;

//   final bool isLoading;

//   const ContentPersistentHeader({
//     required this.maxExtent,
//     required this.minExtent,
//     required this.content,
//     required this.isLoading,
//   });

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     final content = ContentScope.contentOf(context);

//     final bottomTabController = ContentScope.of(context).bottomTabController;
//     final themeData = Theme.of(context);

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Container(
//           padding: const EdgeInsets.only(left: 12),
//           height: 200,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Hero(
//                 tag: content.getHeroTag(),
//                 child: Material(
//                   borderRadius: BorderRadius.circular(8),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: CachedNetworkImage(
//                       height: 200,
//                       fit: BoxFit.cover,
//                       width: 140,
//                       maxHeightDiskCache: 500,
//                       maxWidthDiskCache: 400,
//                       imageUrl: content.imageUrl,
//                       httpHeaders: App.HEADERS,
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.only(
//                     bottom: 8,
//                     top: 8,
//                     left: 12,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       GestureDetector(
//                         onLongPress: () async {
//                           copyToClipboard(
//                             context,
//                             messageCopy: content.title,
//                             messageSnackBar:
//                                 'Copiado para a área de transferência!',
//                           );
//                           await Feedback.forLongPress(context);
//                         },
//                         child: Text(
//                           content.title,
//                           maxLines: 3,
//                           textAlign: TextAlign.start,
//                           overflow: TextOverflow.ellipsis,
//                           style: themeData.textTheme.titleLarge?.copyWith(
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         TabBar(
//           indicatorSize: TabBarIndicatorSize.tab,
//           tabAlignment: TabAlignment.fill,
//           controller: bottomTabController,
//           tabs: ContentTabBar.values
//               .map(
//                 (e) => Tab(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Icon(e.getIconData(content)),
//                       const SizedBox(width: 8),
//                       Center(child: Text(e.getTitle(content))),
//                     ],
//                   ),
//                 ),
//               )
//               .toList(),
//         ),
//       ],
//     );
//   }

//   @override
//   bool shouldRebuild(covariant ContentPersistentHeader oldDelegate) {
//     return maxExtent != oldDelegate.maxExtent ||
//         minExtent != oldDelegate.minExtent ||
//         content != oldDelegate.content;
//   }
// }
