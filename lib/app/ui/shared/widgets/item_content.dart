import 'package:app_wsrb_jsr/app/utils/value_notifier_list.dart';
import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
import 'package:content_library/content_library.dart';

import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ItemContent extends StatelessWidget {
  const ItemContent({
    super.key,
    this.isLibrary = false,
    required this.content,
  });

  final bool isLibrary;

  final Content content;

  static final _borderRadius = BorderRadius.circular(12);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    final textTheme = themeData.textTheme;

    final title = content.title;

    final ValueNotifierList valueNotifierList =
        context.watch<ValueNotifierList>();

    bool selected = valueNotifierList.contains(content.id);

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        // padding: const EdgeInsetsDirectional.all(4),
        height: !isLibrary ? 160 : null,

        decoration: BoxDecoration(
          borderRadius: _borderRadius,
          border: selected ? Border.all(color: Colors.white) : null,
        ),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
          elevation: 1,
          margin: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (!isLibrary)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ClipRRect(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      borderRadius: _borderRadius.copyWith(
                        topRight: Radius.zero,
                        bottomRight: Radius.zero,
                      ),
                      child: SizedBox(
                        width: 156,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _ImageWidget(content),
                            if (content is Anime)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  borderOnForeground: false,
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: _borderRadius.copyWith(
                                      bottomLeft: const Radius.circular(6),
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
                          if (content is Anime && content.releases.isNotEmpty)
                            Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(
                                left: 14,
                                top: 8,
                                right: 12,
                              ),
                              child: Text(
                                content.releases.firstOrNull?.title ?? '',
                                maxLines: 2,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelSmall?.copyWith(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                ClipRRect(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  borderRadius: _borderRadius,
                  child: Stack(
                    // clipBehavior: Clip.antiAliasWithSaveLayer,
                    fit: StackFit.expand,
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.srcOver,
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black38.withOpacity(0.75),
                            ],
                            stops: const [0.0, .9],
                          ).createShader(bounds);
                        },
                        child: _ImageWidget(content),
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.only(
                          left: 12,
                          bottom: 8,
                          right: 12,
                        ),
                        child: Text(
                          title,
                          maxLines: 2,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: isLibrary ? 14 : null,
                          ),
                        ),
                      ),
                      if (content is Anime)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Card(
                            borderOnForeground: false,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: _borderRadius.copyWith(
                                bottomLeft: const Radius.circular(6),
                                topRight: Radius.zero,
                                bottomRight: Radius.zero,
                                topLeft: Radius.zero,
                              ),
                            ),
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                (content as Anime).isDublado ? 'DUB' : 'LEG',
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
              Material(
                color: Colors.transparent,
                borderRadius: _borderRadius,
                child: InkWell(
                  borderRadius: _borderRadius,
                  overlayColor: _OverlayColor(content),
                  onLongPress: () {
                    if (valueNotifierList.isEmpty) {
                      valueNotifierList.toggle(content.id);
                    }
                  },
                  onTap: () async {
                    if (valueNotifierList.isNotEmpty) {
                      valueNotifierList.toggle(content.id);
                    } else {
                      final appSnackBar = context.appSnackBar;
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
                        final result = await context.push(
                          RouteName.CONTENTINFO,
                          extra: ContentInformationArgs(content: content),
                        );

                        if (result != null) {
                          await appSnackBar.onError(result);
                        }
                      }
                    }
                  },
                ),
              ),
              if (content is Anime && !isLibrary)
                Positioned(
                  top: 0,
                  left: 0,
                  child: IconButton(
                    onPressed: valueNotifierList.isEmpty
                        ? () => context.push(
                              RouteName.CONTENTINFO,
                              extra: ContentInformationArgs(content: content),
                            )
                        : null,
                    style: ButtonStyle(overlayColor: _OverlayColor(content)),
                    visualDensity: const VisualDensity(
                      horizontal: -2,
                      vertical: -1.5,
                    ),
                    iconSize: 22,
                    icon: Icon(MdiIcons.information),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayColor extends MaterialStateProperty<Color?> {
  _OverlayColor(this.content) {
    if (content is Anime) {
      _color = (content as Anime).isDublado ? Colors.blue : Colors.red;
    }
  }

  Color? _color;

  final Content content;

  @override
  Color? resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.pressed)) {
      return _color?.withOpacity(0.12);
    } else if (states.contains(MaterialState.hovered)) {
      return _color?.withOpacity(0.08);
    } else if (states.contains(MaterialState.focused)) {
      return Colors.transparent;
    }
    return Colors.transparent;
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
    String imageUrl = content.imageUrl;
    final params = context.findAncestorWidgetOfExactType<ItemContent>()!;

    final isLibrary = params.isLibrary;

    if (content is Anime && !isLibrary) {
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

    if (imageUrl.isEmpty && !isLibrary) {
      return const SizedBox(
        width: width,
        height: double.infinity,
        child: Card(margin: EdgeInsets.zero),
      );
    }

    // final themeData = Theme.of(context);

    Widget imageWidget = CachedNetworkImage(
      // errorWidget: (context, url, obj) {
      //   return Image(
      //     gaplessPlayback: true,
      //     image: ResizeImage.resizeIfNeeded(
      //       memCacheWidth,
      //       memCacheHeight,
      //       App.DEFAULT_IMAGE_PLACEHOLDER,
      //     ),
      //     alignment: Alignment.center,
      //     fit: BoxFit.cover,
      //   );
      // },
      alignment: FractionalOffset.center,
      imageUrl: imageUrl,
      fadeOutDuration: const Duration(milliseconds: 600),
      fadeInDuration: const Duration(milliseconds: 300),
      memCacheHeight: !isLibrary ? memCacheHeight : 380,
      memCacheWidth: !isLibrary ? memCacheWidth : 350,
      fit: BoxFit.cover,
    );

    if (!params.isLibrary) {
      imageWidget = SizedBox(
        width: width,
        height: double.infinity,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
