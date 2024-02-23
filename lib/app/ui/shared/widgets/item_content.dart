import 'package:app_wsrb_jsr/app/core/constants/app.dart';
import 'package:app_wsrb_jsr/app/models/anime.dart';
import 'package:app_wsrb_jsr/app/models/content.dart';
import 'package:app_wsrb_jsr/app/models/episode.dart';
import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class ItemContent extends StatelessWidget {
  const ItemContent({
    super.key,
    required this.content,
  });

  final Content content;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    // .copyWith(
    //   colorScheme: item.bookColorScheme
    //       ?.copyWith(brightness: Theme.of(context).brightness),
    // );
    final textTheme = themeData.textTheme;
    final title = content.title;
    final borderRadius = BorderRadius.circular(12);

    return Theme(
      data: themeData,
      child: Container(
        padding: const EdgeInsetsDirectional.all(4),
        height: 160,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 4,
          margin: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: borderRadius.copyWith(
                      topRight: Radius.zero,
                      bottomRight: Radius.zero,
                    ),
                    child: SizedBox(
                      width: 155,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _ImageWidget(content),
                          if (content is Anime)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: borderRadius.copyWith(
                                    topRight: Radius.zero,
                                    bottomRight: Radius.zero,
                                    topLeft: Radius.zero,
                                  ),
                                ),
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Text(
                                    (content as Anime).isDublado
                                        ? 'DUB'
                                        : 'LEG',
                                    style: textTheme.labelMedium?.copyWith(
                                      fontSize: 10,
                                      color: (content as Anime).isDublado
                                          ? Colors.blue
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(
                            left: 14,
                            top: 12,
                            right: 12,
                          ),
                          child: Text(
                            title,
                            maxLines: 2,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium?.copyWith(),
                          ),
                        ),
                        if (content is Anime)
                          Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(
                              left: 14,
                              top: 8,
                              right: 12,
                              bottom: 8,
                            ),
                            child: Text(
                              content.releases.first.title,
                              maxLines: 2,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelMedium?.copyWith(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: borderRadius,
                  splashFactory: InkRipple.splashFactory,
                  onDoubleTap: content is Anime && content.releases.length == 1
                      ? () async {
                          await context.push(
                            RouteName.CONTENTINFO,
                            extra: ContentInformationArgs(content: content),
                          );
                        }
                      : null,
                  onTap: () async {
                    if (content is Anime && content.releases.length == 1) {
                      final anime = content as Anime;
                      await context.push(
                        RouteName.PLAYER,
                        extra: PlayerArgs(
                          anime: anime,
                          episode: anime.releases.first,
                        ),
                      );
                    } else {
                      await context.push(
                        RouteName.CONTENTINFO,
                        extra: ContentInformationArgs(content: content),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class BookItem extends StatelessWidget {
//   const BookItem({required this.item, super.key});

//   final Book item;

//   @override
//   Widget build(BuildContext context) {
//     final themeData = Theme.of(context);
//     final textTheme = themeData.textTheme;

//     final state = context.findAncestorStateOfType<HomeUtils>();

//     return OpenContainerWidgetWrapper(
//       closedElevation: 0,
//       openElevation: 0,
//       clipBehavior: Clip.hardEdge,
//       borderRadius: BorderRadius.circular(8),
//       openColor: themeData.cardColor,
//       closedColor: themeData.cardColor,
//       transitionDuration: const Duration(milliseconds: 500),
//       onClosed: (data) async {
//         await Future.delayed(const Duration(milliseconds: 500));
//         state?.disableScroll(false);
//       },
//       arguments: BookInformationArgs(book: item),
//       widgetBuilder: (context) => Stack(
//         fit: StackFit.expand,
//         children: [
//           _ImageWidget(item),
//           Container(
//             alignment: Alignment.bottomCenter,
//             padding: const EdgeInsets.all(8),
//             child: Text(
//               item.title,
//               maxLines: 2,
//               textAlign: TextAlign.center,
//               overflow: TextOverflow.ellipsis,
//               style: textTheme.titleLarge?.copyWith(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Material(
//             color: Colors.transparent,
//             child: InkWell(
//               splashFactory: InkRipple.splashFactory,
//               onTap: () async {
//                 final result = await OpenContainerWidgetWrapper.action(context);
//                 state?.disableScroll(true);

//                 if (result is Failure && context.mounted) {
//                   result.snackBar(context);
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _ImageWidget extends StatelessWidget {
  const _ImageWidget(this.content);

  final Content content;

  @override
  Widget build(BuildContext context) {
    final title = content.title;
    String imageUrl = content.imageUrl;

    if (content is Anime) {
      imageUrl = (content.releases.first as Episode).thumbnail ?? '';
    }

    const double width = 145;
    int memCacheHeight = 300;
    int memCacheWidth = 250;
    // int memCacheWidth = 250;

    if (content is Anime) {
      memCacheHeight = 300;
      memCacheWidth = 450;
    }

    if (imageUrl.isEmpty) {
      return const SizedBox(
        width: width,
        height: double.infinity,
        child: Card(margin: EdgeInsets.zero),
      );
    }

    // final themeData = Theme.of(context);

    final Widget imageWidget = SizedBox(
      width: width,
      height: double.infinity,
      child: CachedNetworkImage(
        errorWidget: (context, url, obj) {
          return Image(
            image: ResizeImage.resizeIfNeeded(
              memCacheWidth,
              memCacheHeight,
              App.DEFAULT_IMAGE_PLACEHOLDER,
            ),
            alignment: Alignment.center,
            fit: BoxFit.cover,
          );
        },
        alignment: FractionalOffset.center,
        imageUrl: imageUrl,
        cacheKey: title,
        fadeOutDuration: const Duration(milliseconds: 600),
        fadeInDuration: const Duration(milliseconds: 300),
        memCacheHeight: memCacheHeight,
        memCacheWidth: memCacheWidth,
        fit: BoxFit.cover,
      ),
    );

    return imageWidget;
  }
}
