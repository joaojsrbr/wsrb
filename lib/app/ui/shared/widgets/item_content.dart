import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/image_filter.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/rail_menu.dart';
import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ItemContent extends StatelessWidget {
  const ItemContent({
    super.key,
    this.isLibrary = false,
    this.isSearch = false,
    this.height,
    this.width,
    required this.content,
  });

  final double? width;
  final double? height;
  final bool isLibrary;
  final bool isSearch;

  final Content content;

  static final _borderRadius = BorderRadius.circular(12);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    final TextTheme textTheme = themeData.textTheme;

    final ValueNotifierList valueNotifierList =
        context.watch<ValueNotifierList>();

    final RailMenuController? railMenuController =
        RailMenu.menuControllerMaybeOf(context);

    final bool isOpen = railMenuController?.isOpen ?? false;

    final AppSnackBar appSnackBar = context.appSnackBar;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: height ??
            (!isLibrary
                ? isOpen
                    ? 140
                    : 160
                : null),
        width: width,
        decoration: BoxDecoration(
          borderRadius: _borderRadius.subtract(BorderRadius.circular(2)),
          border: valueNotifierList.contains(content.stringID)
              ? Border.all(color: Colors.white, width: 1.5)
              : null,
        ),
        child: Material(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width:
                    isOpen ? (180 - railMenuController!.menuSize.width) : 160,
                child: ClipRRect(
                  borderRadius: _borderRadius,
                  child: _ImageWidget(content),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (content is Anime &&
                        content.releases.isNotEmpty &&
                        content.releases.firstOrNull != null)
                      Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(
                          left: 14,
                          top: 8,
                          right: 12,
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    'Episódio ${content.releases.first.number}',
                              ),
                              if (content is Anime) const TextSpan(text: ' - '),
                              if (content is Anime)
                                TextSpan(
                                  text: (content as Anime).isDublado
                                      ? 'DUB'
                                      : 'LEG',
                                  style: TextStyle(
                                    color: (content as Anime).isDublado
                                        ? Colors.green
                                        : Colors.blue,
                                  ),
                                ),
                            ],
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelMedium?.copyWith(),
                        ),
                      ),
                    Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(
                        left: 14,
                        right: 12,
                        bottom: 8,
                      ),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 350),
                        style: (textTheme.titleSmall ?? const TextStyle())
                            .copyWith(
                          fontSize: isOpen ? 14 : 16,
                        ),
                        child: Text(
                          content.title,
                          maxLines: 1,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // if (!(isLibrary || isSearch))
              //   Row(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     mainAxisSize: MainAxisSize.max,
              //     children: [
              //       Expanded(
              //         child: Column(
              //           mainAxisAlignment: MainAxisAlignment.start,
              //           mainAxisSize: MainAxisSize.max,
              //           children: [
              //             Container(
              //               alignment: Alignment.topLeft,
              //               padding: const EdgeInsets.only(
              //                 left: 14,
              //                 top: 12,
              //                 right: 12,
              //               ),
              //               child: AnimatedDefaultTextStyle(
              //                 duration: const Duration(milliseconds: 350),
              //                 style: (textTheme.titleMedium ?? const TextStyle())
              //                     .copyWith(
              //                   fontSize: isOpen ? 14 : 16,
              //                 ),
              //                 child: Text(
              //                   content.title,
              //                   maxLines: 2,
              //                   textAlign: TextAlign.start,
              //                   overflow: TextOverflow.ellipsis,
              //                 ),
              //               ),
              //             ),
              //             if (content is Anime &&
              //                 content.releases.isNotEmpty &&
              //                 content.releases.firstOrNull != null)
              //               Container(
              //                 alignment: Alignment.topLeft,
              //                 padding: const EdgeInsets.only(
              //                   left: 14,
              //                   top: 8,
              //                   right: 12,
              //                 ),
              //                 child: Text(
              //                   content.releases.first.title,
              //                   maxLines: 2,
              //                   textAlign: TextAlign.start,
              //                   overflow: TextOverflow.ellipsis,
              //                   style: textTheme.labelSmall?.copyWith(),
              //                 ),
              //               ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   )
              // else
              //   ClipRRect(
              //     clipBehavior: Clip.antiAliasWithSaveLayer,
              //     borderRadius: _borderRadius,
              //     child: Stack(
              //       fit: StackFit.expand,
              //       children: [
              //         ShaderMask(
              //           blendMode: BlendMode.srcOver,
              //           shaderCallback: (bounds) {
              //             return LinearGradient(
              //               begin: Alignment.center,
              //               end: Alignment.bottomCenter,
              //               colors: [
              //                 Colors.transparent,
              //                 Colors.black38.withOpacity(0.75),
              //               ],
              //               stops: const [0.0, .9],
              //             ).createShader(bounds);
              //           },
              //           child: _ImageWidget(content),
              //         ),
              //         Container(
              //           alignment: Alignment.bottomLeft,
              //           padding: const EdgeInsets.only(
              //             left: 12,
              //             bottom: 8,
              //             right: 12,
              //           ),
              //           child: AnimatedDefaultTextStyle(
              //             duration: const Duration(milliseconds: 350),
              //             style: (textTheme.titleMedium ?? const TextStyle())
              //                 .copyWith(
              //               fontSize: isOpen ? 12 : 14,
              //             ),
              //             child: Text(
              //               content.title,
              //               maxLines: 2,
              //               textAlign: TextAlign.start,
              //               overflow: TextOverflow.ellipsis,
              //             ),
              //           ),
              //         ),
              //         if (content is Anime)
              //           Positioned(
              //             top: 0,
              //             right: 0,
              //             child: Card(
              //               elevation: 1,
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: _borderRadius.copyWith(
              //                   bottomLeft: const Radius.circular(6),
              //                   topRight: Radius.zero,
              //                   bottomRight: Radius.zero,
              //                   topLeft: Radius.zero,
              //                 ),
              //               ),
              //               margin: EdgeInsets.zero,
              //               child: Padding(
              //                 padding: const EdgeInsets.all(6.6),
              //                 child: Text(
              //                   (content as Anime).isDublado ? 'DUB' : 'LEG',
              //                   style: textTheme.labelMedium?.copyWith(
              //                     fontSize: 10,
              //                     color: (content as Anime).isDublado
              //                         ? Colors.blue
              //                         : Colors.red,
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //       ],
              //     ),
              //   ),
              Material(
                color: Colors.transparent,
                borderRadius: _borderRadius,
                child: InkWell(
                  borderRadius: _borderRadius,
                  overlayColor: _OverlayColor(content),
                  onLongPress: isSearch
                      ? null
                      : () {
                          if (valueNotifierList.isEmpty) {
                            customLog(
                              'InkWell long tapped title: ${content.title} - id: ${content.stringID}',
                            );
                            valueNotifierList.toggle(content.stringID);
                          }
                          // HomeRailMenu.menuControllerMaybeOf(context)?.open();
                        },
                  onTap: () async {
                    final searchController =
                        HomeScope.byKeyMaybeOf()?.searchController;

                    if (searchController?.isOpen == true) {
                      searchController?.closeView("");
                      context.unFocusKeyBoard();
                      // searchController?.clear();
                    }
                    if (valueNotifierList.isNotEmpty) {
                      valueNotifierList.toggle(content.stringID);
                      customLog(
                        'InkWell tapped title: ${content.title} - id: ${content.stringID}',
                      );
                    } else {
                      if (content is Anime &&
                              content.releases.length == 1 &&
                              !isLibrary ||
                          HomeScope.maybeOf(context) != null) {
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
                          extra: ContentInformationArgs(
                            content: content,
                          ),
                        );

                        if (result != null) {
                          await appSnackBar.onError(result);
                        }
                      }
                    }
                  },
                ),
              ),
              if (content is Anime && !(isLibrary || isSearch))
                Positioned(
                  top: 0,
                  left: 0,
                  child: IconButton(
                    onPressed: valueNotifierList.isEmpty
                        ? () async {
                            customLog(
                              'IconButton[MdiIcons.information] tapped title: ${content.title} - id: ${content.stringID}',
                            );

                            final result = await context.push(
                              RouteName.CONTENTINFO,
                              extra: ContentInformationArgs(
                                content: content,
                              ),
                            );
                            if (result != null) {
                              await appSnackBar.onError(result);
                            }
                          }
                        : null,
                    style: ButtonStyle(overlayColor: _OverlayColor(content)),
                    visualDensity: const VisualDensity(
                      horizontal: -2,
                      vertical: -2,
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

class _OverlayColor extends WidgetStateProperty<Color?> {
  _OverlayColor(this.content) {
    if (content is Anime) {
      _color = (content as Anime).isDublado ? Colors.blue : Colors.red;
    }
  }

  Color? _color;

  final Content content;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) {
      return _color?.withOpacity(0.12);
    } else if (states.contains(WidgetState.hovered)) {
      return _color?.withOpacity(0.08);
    } else if (states.contains(WidgetState.focused)) {
      return Colors.transparent;
    }
    return Colors.transparent;
  }
}

class _ImageWidget extends StatelessWidget {
  const _ImageWidget(this.content);

  final Content content;

  @override
  Widget build(BuildContext context) {
    final ItemContent params =
        context.findAncestorWidgetOfExactType<ItemContent>()!;

    final themeData = Theme.of(context);

    if (content.imageUrl.isEmpty &&
        ![params.isLibrary, params.isSearch].contains(true)) {
      return SizedBox(
        child: Card.filled(
          color: themeData.colorScheme.primary.withOpacity(0.04),
        ),
      );
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: content.imageUrl,
      imageBuilder: (context, imageProvider) {
        return ShaderMask(
          blendMode: BlendMode.srcOver,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black38.withOpacity(0.45),
              ],
              stops: const [0.0, .6],
            ).createShader(bounds);
          },
          child: Image(
            fit: BoxFit.cover,
            alignment: FractionalOffset.center,
            image: imageProvider,
          ),
        );
      },
      errorListener: (value) {
        customLog(value.toString());
      },
      errorWidget: (context, url, error) {
        return Card.filled(
          color: themeData.colorScheme.secondary.withOpacity(0.04),
          shape: RoundedRectangleBorder(),
        );
      },
      maxHeightDiskCache: params.isLibrary ? 500 : 500,
      maxWidthDiskCache: params.isLibrary ? 500 : 500,
      httpHeaders: App.HEADERS,
    );

    if (HomeScope.maybeOf(context)?.tabController.index == 1) {
      imageWidget = Hero(
        tag: content.getHeroTag(),
        child: Material(
          borderRadius: BorderRadius.circular(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageWidget,
          ),
        ),
      );
    }

    return ImageFilter(saturation: 0.2, child: imageWidget);
  }
}
