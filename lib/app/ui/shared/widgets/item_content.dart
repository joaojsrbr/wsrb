import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/rail_menu.dart';
import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ItemContent extends StatefulWidget {
  final bool _isLibrary;
  final bool _isSearch;
  final double? width;
  final double? height;
  final Content content;

  const ItemContent({
    super.key,
    required this.content,
    this.width,
    this.height,
  })  : _isSearch = false,
        _isLibrary = false;

  const ItemContent.library({
    super.key,
    required this.content,
    this.width,
    this.height,
  })  : _isSearch = false,
        _isLibrary = true;

  const ItemContent.search({
    super.key,
    required this.content,
    this.width,
    this.height,
  })  : _isSearch = false,
        _isLibrary = true;

  static ItemContent? maybeOf(BuildContext context) {
    return context.findAncestorWidgetOfExactType<ItemContent>();
  }

  static ItemContent of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<ItemContent>()!;
  }

  @override
  State<ItemContent> createState() => _ItemContentState();
}

class _ItemContentState extends State<ItemContent> {
  static final BorderRadius _borderRadius = BorderRadius.circular(8);

  bool get _isLibrary => widget._isLibrary;
  bool get _isSearch => widget._isSearch;

  @override
  Widget build(BuildContext context) {
    final content = widget.content;

    final ValueNotifierList valueNotifierList =
        context.watch<ValueNotifierList>();

    final RailMenuController? railMenuController =
        RailMenu.menuControllerMaybeOf(context);

    // final ContentRepository contentRepository =
    //     context.read<ContentRepository>();

    final HiveController hiveController = context.watch<HiveController>();

    final ThemeData themeData = Theme.of(context);

    final textTheme = themeData.textTheme;
    // customLog(widget.content.imageUrl);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: _borderRadius.add(BorderRadius.circular(2)),
        border: valueNotifierList.contains(content.stringID)
            ? Border.all(color: Colors.white, width: 1.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: _borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              filterQuality: FilterQuality.medium,
              imageUrl: widget.content.imageUrl,

              placeholder: (context, url) {
                return Card.filled(
                  color: themeData.colorScheme.primary.withAlpha(10),
                );
              },
              imageBuilder: (context, imageProvider) {
                return ShaderMask(
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
                  child: Image(
                    fit: BoxFit.cover,
                    alignment: FractionalOffset.center,
                    image: imageProvider,
                  ),
                );
              },
              errorListener: (value) {
                customLog(value);
                // addPostFrameSetState(() => _error = true);
              },
              errorWidget: (context, url, error) {
                return Card.filled(
                  color: themeData.colorScheme.primary.withAlpha(10),
                );
              },
              maxHeightDiskCache: 350,
              maxWidthDiskCache: 300,

              httpHeaders: {
                ...App.HEADERS,
                'Referer': '${hiveController.source.baseURL}/',
              },
              // httpHeaders: App.HEADERS,
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
                          .copyWith(
                              fontSize: railMenuController?.isOpen == true
                                  ? (textTheme.titleSmall!.fontSize! - 2)
                                  : textTheme.titleSmall!.fontSize),
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
              borderRadius: _borderRadius,
              child: InkWell(
                borderRadius: _borderRadius,
                overlayColor: _OverlayColor(content),
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
                  final appSnackBar = context.appSnackBar;
                  final searchController =
                      HomeScope.byKeyMaybeOf()?.searchController;

                  if (searchController?.isOpen == true) {
                    // searchController?.closeView("");
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
                        !_isLibrary &&
                        !_isSearch) {
                      final anime = content;
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
                          getData: false,
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
                  style: ButtonStyle(overlayColor: _OverlayColor(content)),
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
      return _color?.withAlpha(30);
    } else if (states.contains(WidgetState.hovered)) {
      return _color?.withAlpha(20);
    } else if (states.contains(WidgetState.focused)) {
      return Colors.transparent;
    }
    return Colors.transparent;
  }
}
