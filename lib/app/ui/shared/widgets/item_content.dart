import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ItemContent extends StatelessWidget {
  final bool _isLibrary;
  final bool _isSearch;
  final bool _isContent;
  final double? width;
  final double? height;
  final Content content;
  final void Function(Content content)? onTap;

  const ItemContent({
    super.key,
    required this.content,
    this.width,
    this.onTap,
    this.height,
  })  : _isSearch = false,
        _isLibrary = false,
        _isContent = false;

  const ItemContent.library({
    super.key,
    required this.content,
    this.width,
    this.onTap,
    this.height,
  })  : _isSearch = false,
        _isLibrary = true,
        _isContent = false;

  const ItemContent.search({
    super.key,
    required this.content,
    this.width,
    this.onTap,
    this.height,
  })  : _isSearch = true,
        _isLibrary = false,
        _isContent = false;

  const ItemContent.content({
    super.key,
    required this.content,
    this.width,
    this.onTap,
    this.height,
  })  : _isSearch = false,
        _isLibrary = false,
        _isContent = true;

  static ItemContent? maybeOf(BuildContext context) {
    return context.findAncestorWidgetOfExactType<ItemContent>();
  }

  static ItemContent of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<ItemContent>()!;
  }

  static final BorderRadius _borderRadius = BorderRadius.circular(8);

  @override
  Widget build(BuildContext context) {
    final ValueNotifierList valueNotifierList =
        context.watch<ValueNotifierList>();

    final AppConfigController appConfigController =
        context.watch<AppConfigController>();

    final ThemeData themeData = Theme.of(context);

    // final LibraryController libraryController =
    //     context.watch<LibraryController>();

    final searchController = HomeScope.maybeOf(context)?.searchController;

    final content = this.content;

    final _OverlayColor overlayColor = _OverlayColor(themeData.colorScheme);

    final textTheme = themeData.textTheme;

    final appSnackBar = context.appSnackBar;

    // final memCacheHeight = 300;
    // final memCacheWidth = 350;

    final memCacheHeight = _isLibrary || _isSearch
        ? 450
        : _isContent
            ? 150
            : 300;
    final memCacheWidth = _isLibrary || _isSearch
        ? 600
        : _isContent
            ? 200
            : 300;

    if (_isContent) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: InkWell(
          onLongPress: () {
            if (valueNotifierList.isEmpty) {
              customLog(
                'InkWell long tapped title: ${content.title} - id: ${content.stringID}',
              );
              valueNotifierList.toggle(content.stringID);
            }
          },
          onTap: () async {
            if (searchController?.isAttached == true &&
                searchController?.isOpen == true) {
              context.unFocusKeyBoard();
            }
            if (valueNotifierList.isNotEmpty) {
              valueNotifierList.toggle(content.stringID);
              customLog(
                'InkWell tapped title: ${content.title} - id: ${content.stringID}',
              );
            } else {
              if (content is Anime) {
                await context.push(
                  RouteName.PLAYER,
                  extra: PlayerArgs(
                    anime: content,
                    episode: content.releases.last,
                  ),
                );
              }
            }
          },
          splashFactory: InkRipple.splashFactory,
          overlayColor: _OverlayColor(themeData.colorScheme),
          child: ListTile(
            title: Text(
              content.title,
              maxLines: 2,
              style: textTheme.titleMedium!,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
            ),
            isThreeLine: false,
            dense: true,
            subtitle: Row(
              children: [
                Text(
                  'Episódio ${content.releases.last.number}',
                ),
                if (content is Anime) ...[
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: ' - '),
                        TextSpan(
                          text: content.isDublado ? 'DUB' : 'LEG',
                          style: TextStyle(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            minVerticalPadding: 0,
            minTileHeight: 68,
            visualDensity: const VisualDensity(vertical: 4, horizontal: -2),
            leading: Container(
              margin: const EdgeInsets.only(top: 3, bottom: 3),
              width: 100,
              height: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8)
                          .add(BorderRadius.circular(2)),
                      border: valueNotifierList.contains(content.stringID)
                          ? Border.all(color: Colors.white, width: 1.5)
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        cacheManager: App.APP_IMAGE_CACHE,
                        imageUrl: content.imageUrl,
                        placeholder: (context, url) => const _Placeholder(),
                        errorListener: customLog,
                        memCacheWidth: memCacheWidth,
                        memCacheHeight: memCacheHeight,
                        fit: BoxFit.cover,
                        alignment: FractionalOffset.center,
                        errorWidget: (context, url, error) =>
                            const _Placeholder(),
                        httpHeaders: {
                          ...App.HEADERS,
                          'Referer':
                              '${appConfigController.config.source.baseURL}/',
                        },
                      ),
                    ),
                  ),
                  Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        if (searchController?.isAttached == true &&
                            searchController?.isOpen == true) {
                          context.unFocusKeyBoard();
                        }
                        if (valueNotifierList.isNotEmpty) {
                          valueNotifierList.toggle(content.stringID);
                          customLog(
                            'InkWell tapped title: ${content.title} - id: ${content.stringID}',
                          );
                          return;
                        }

                        customLog(
                          'InkWell tapped title: ${content.title} - id: ${content.stringID}',
                        );

                        // final cache = await AutoCache.data.getJson(
                        //   key: content.stringID,
                        // );
                        // final cacheContent = switch (content) {
                        //   Anime _ when cache.data != null =>
                        //     Anime.fromMap(cache.data!),
                        //   Book _ when cache.data != null =>
                        //     Book.fromMap(cache.data!),
                        //   _ => null,
                        // };
                        if (context.mounted) {
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
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return AnimatedContainer(
      // key: ObjectKey(widget.content),
      duration: const Duration(milliseconds: 350),
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: ItemContent._borderRadius.add(BorderRadius.circular(2)),
        border: valueNotifierList.contains(content.stringID)
            ? Border.all(color: Colors.white, width: 1.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: ItemContent._borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ShaderMask(
              blendMode: BlendMode.srcOver,
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54.withAlpha(140)],
                  stops: const [0.0, .9],
                ).createShader(bounds);
              },
              child: CachedNetworkImage(
                imageUrl: content.imageUrl,
                cacheManager: App.APP_IMAGE_CACHE,
                placeholder: (context, url) => const _Placeholder(),
                errorListener: customLog,
                fit: BoxFit.cover,
                alignment: FractionalOffset.center,
                errorWidget: (context, url, error) => const _Placeholder(),
                memCacheHeight: memCacheHeight,
                memCacheWidth: memCacheWidth,
                httpHeaders: {
                  ...App.HEADERS,
                  'Referer': '${appConfigController.config.source.baseURL}/',
                },
              ),
            ),
            Positioned(
              bottom: 8,
              left: 12,
              right: 12,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (!_isLibrary && !_isSearch)
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 350),
                      style: (textTheme.titleSmall ?? const TextStyle())
                          .copyWith(fontSize: textTheme.titleSmall!.fontSize),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            if (content.releases.length == 1) ...[
                              TextSpan(
                                text:
                                    'Episódio ${content.releases.first.number}',
                              ),
                              const TextSpan(text: ' - '),
                            ],
                            if (content is Anime) ...[
                              TextSpan(
                                text: content.isDublado ? 'DUB' : 'LEG',
                                style: TextStyle(
                                  color: content.isDublado
                                      ? Colors.green
                                      : Colors.blue,
                                ),
                              ),
                            ],
                          ],
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 350),
                    style: _isLibrary
                        ? textTheme.titleMedium!
                        : textTheme.titleSmall!.copyWith(),
                    child: Text(
                      content.title,
                      maxLines: _isLibrary ? 2 : 1,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              borderRadius: ItemContent._borderRadius,
              child: InkWell(
                borderRadius: ItemContent._borderRadius,
                overlayColor: overlayColor,
                onLongPress: _isSearch
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
                  onTap?.call(content);

                  if (valueNotifierList.isNotEmpty) {
                    valueNotifierList.toggle(content.stringID);
                    customLog(
                      'InkWell tapped title: ${content.title} - id: ${content.stringID}',
                    );
                  } else {
                    if (content is Anime &&
                        content.releases.length == 1 &&
                        !_isLibrary &&
                        !_isSearch) {
                      await context.push(
                        RouteName.PLAYER,
                        extra: PlayerArgs(
                          anime: content,
                          episode: content.releases.first,
                        ),
                      );
                    } else {
                      // final saveContent =
                      //     libraryController.repo.getContentEntityByStringID(
                      //   content.stringID,
                      // );

                      // switch (saveContent) {
                      //   case AnimeEntity data:
                      //     await data.episodes.load();
                      //   case BookEntity data:
                      //     await data.chapters.load();
                      // }

                      // final toContent = switch (saveContent) {
                      //   AnimeEntity data => data.toAnime(),
                      //   BookEntity data => data.toBook(),
                      //   _ => null,
                      // };
                      if (context.mounted) {
                        final result = await context.push(
                          RouteName.CONTENTINFO,
                          extra: ContentInformationArgs(
                            content: content,
                            isLibrary: _isLibrary,
                          ),
                        );

                        if (result != null) {
                          await appSnackBar.onError(result);
                        }
                      }
                    }
                  }
                },
              ),
            ),
            Visibility(
              visible: content is Anime && !_isLibrary && !_isSearch,
              child: Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  onPressed: valueNotifierList.isEmpty
                      ? () async {
                          final appSnackBar = context.appSnackBar;
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
                  style: ButtonStyle(overlayColor: overlayColor),
                  visualDensity: const VisualDensity(
                    horizontal: -2,
                    vertical: -2,
                  ),
                  iconSize: 22,
                  icon: Icon(MdiIcons.information),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Card.filled(
      color: themeData.colorScheme.primary.withAlpha(10),
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
