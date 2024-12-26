import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
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
        _isLibrary = false;

  const ItemContent.library({
    super.key,
    required this.content,
    this.width,
    this.onTap,
    this.height,
  })  : _isSearch = false,
        _isLibrary = true;

  const ItemContent.search({
    super.key,
    required this.content,
    this.width,
    this.onTap,
    this.height,
  })  : _isSearch = true,
        _isLibrary = false;

  static ItemContent? maybeOf(BuildContext context) {
    return context.findAncestorWidgetOfExactType<ItemContent>();
  }

  static ItemContent of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<ItemContent>()!;
  }

  static final BorderRadius _borderRadius = BorderRadius.circular(8);

  static final _OverlayColor _overlayColor = _OverlayColor();

  @override
  Widget build(BuildContext context) {
    final appSnackBar = context.appSnackBar;

    final memCacheHeight = _isLibrary
        ? 300
        : _isSearch
            ? 350
            : 200;
    final memCacheWidth = _isLibrary
        ? 500
        : _isSearch
            ? 300
            : 300;

    final ValueNotifierList valueNotifierList =
        context.watch<ValueNotifierList>();

    final HiveController hiveController = context.watch<HiveController>();

    final ThemeData themeData = Theme.of(context);

    final textTheme = themeData.textTheme;

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
                  colors: [
                    Colors.transparent,
                    Colors.black54.withAlpha(90),
                  ],
                  stops: const [0.0, .9],
                ).createShader(bounds);
              },
              child: CachedNetworkImage(
                filterQuality: FilterQuality.medium,
                imageUrl: content.imageUrl,
                placeholder: (context, url) => const _Placeholder(),
                errorListener: customLog,
                fit: BoxFit.cover,
                alignment: FractionalOffset.center,
                errorWidget: (context, url, error) => const _Placeholder(),
                memCacheHeight: memCacheHeight,
                memCacheWidth: memCacheWidth,
                httpHeaders: {
                  ...App.HEADERS,
                  'Referer': '${hiveController.source.baseURL}/',
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
                overlayColor: ItemContent._overlayColor,
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
                          isLibrary: _isLibrary,
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
                  style: ButtonStyle(
                    overlayColor: ItemContent._overlayColor,
                  ),
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

class _OverlayColor extends WidgetStateProperty<Color?> {
  _OverlayColor();

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) {
      return Colors.blue.withAlpha(30);
    } else if (states.contains(WidgetState.hovered)) {
      return Colors.blue.withAlpha(20);
    } else if (states.contains(WidgetState.focused)) {
      return Colors.transparent;
    }
    return Colors.transparent;
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
