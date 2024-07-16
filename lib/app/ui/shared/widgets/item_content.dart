import 'package:app_wsrb_jsr/app/ui/home/widgets/home_rail_menu.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_search_anchor.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/image_filter.dart';
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
        HomeRailMenu.menuControllerMaybeOf(context);

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
          borderRadius: _borderRadius.add(BorderRadius.circular(1.2)),
          border: valueNotifierList.contains(content.stringID)
              ? Border.all(color: Colors.white, width: 1.5)
              : null,
        ),
        child: Card.filled(
          color: themeData.colorScheme.primary.withOpacity(0.04),
          borderOnForeground: false,
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (!(isLibrary || isSearch))
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      width: isOpen
                          ? (180 - railMenuController!.menuSize.width)
                          : 160,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _ImageWidget(content),
                          if (content is Anime)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: Card.outlined(
                                shape: RoundedRectangleBorder(
                                  borderRadius: _borderRadius.copyWith(
                                    bottomLeft: Radius.zero,
                                    topRight: const Radius.circular(6),
                                    bottomRight: Radius.zero,
                                    topLeft: Radius.zero,
                                  ),
                                ),
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(6.6),
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
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 350),
                              style:
                                  (textTheme.titleMedium ?? const TextStyle())
                                      .copyWith(
                                fontSize: isOpen ? 14 : 16,
                              ),
                              child: Text(
                                content.title,
                                maxLines: 2,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
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
                              child: Text(
                                content.releases.first.title,
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
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 350),
                          style: (textTheme.titleMedium ?? const TextStyle())
                              .copyWith(
                            fontSize: isOpen ? 12 : 14,
                          ),
                          child: Text(
                            content.title,
                            maxLines: 2,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (content is Anime)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Card(
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
                              padding: const EdgeInsets.all(6.6),
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
                              extra: ContentInformationArgs(content: content),
                            );
                            if (result != null) {
                              await appSnackBar.onError(result);
                            }
                          }
                        : null,
                    style: ButtonStyle(overlayColor: _OverlayColor(content)),
                    visualDensity: const VisualDensity(
                      horizontal: -1,
                      vertical: -1,
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
    String imageUrl = content.imageUrl;
    final ItemContent params =
        context.findAncestorWidgetOfExactType<ItemContent>()!;

    if (content is Anime &&
        ![params.isLibrary, params.isSearch].contains(true)) {
      imageUrl = (content.releases.first as Episode).thumbnail ?? '';
    }

    const double width = 145;

    if (imageUrl.isEmpty &&
        ![params.isLibrary, params.isSearch].contains(true)) {
      return const SizedBox(
        width: width,
        height: double.infinity,
        child: Card.filled(shape: RoundedRectangleBorder()),
      );
    }

    // final themeData = Theme.of(context);

    Widget imageWidget = CachedNetworkImage(
      fit: BoxFit.cover,
      alignment: FractionalOffset.center,
      imageUrl: imageUrl,
      width: width,
      height: double.infinity,
      errorWidget: (context, url, error) {
        return const Card.filled(shape: RoundedRectangleBorder());
      },
      fadeOutDuration: const Duration(milliseconds: 600),
      fadeInDuration: const Duration(milliseconds: 300),
      maxHeightDiskCache: params.isLibrary ? 300 : 500,
      maxWidthDiskCache: params.isLibrary ? 300 : 500,
      httpHeaders: App.HEADERS,
      // memCacheHeight: !isLibrary ? memCacheHeight : 350,
      // memCacheWidth: !isLibrary ? memCacheWidth : 390,
    );

    if (![params.isLibrary, params.isSearch].contains(true)) {
      imageWidget = imageWidget;
    } else {
      imageWidget = ImageFilter(
        saturation: 0.2,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
