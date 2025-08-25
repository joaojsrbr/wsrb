// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_network_image_cache.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/global_overlay.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ContentTile extends StatelessWidget {
  final bool isFromLibrary;
  final bool isFromSearch;
  final bool isListTile;
  final double? width;
  final double? height;
  final Content content;
  final EdgeInsetsGeometry padding;
  final void Function(Content content)? onTap;

  const ContentTile({
    super.key,
    required this.content,
    this.width,
    this.height,
    this.onTap,
    this.padding = EdgeInsets.zero,
  }) : isFromLibrary = false,
       isFromSearch = false,
       isListTile = false;

  const ContentTile.library({
    super.key,
    required this.content,
    this.width,
    this.height,
    this.onTap,
    this.padding = EdgeInsets.zero,
  }) : isFromLibrary = true,
       isFromSearch = false,
       isListTile = false;

  const ContentTile.search({
    super.key,
    required this.content,
    this.width,
    this.height,
    this.onTap,
    this.padding = EdgeInsets.zero,
  }) : isFromLibrary = false,
       isFromSearch = true,
       isListTile = false;

  const ContentTile.list({
    super.key,
    required this.content,
    this.width,
    this.height,
    this.onTap,
    this.padding = EdgeInsets.zero,
  }) : isFromLibrary = false,
       isFromSearch = false,
       isListTile = true;

  static final BorderRadius _radius = BorderRadius.circular(8);

  @override
  Widget build(BuildContext context) {
    final content = this.content;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final searchController = HomeScope.maybeOf(context)?.searchController;
    final valueNotifierList = context.watch<ValueNotifierList>();
    final appConfig = context.watch<AppConfigController>();

    final isSelected = valueNotifierList.contains(content.stringID);
    final headers = {...App.HEADERS, 'Referer': '${appConfig.config.source.baseURL}/'};

    if (isListTile) {
      return InkWell(
        onLongPress: valueNotifierList.isEmpty
            ? () => valueNotifierList.toggle(content.stringID)
            : null,
        onTap: () async {
          onTap?.call(content);
          if (searchController?.isAttached == true && searchController!.isOpen) {
            context.unFocusKeyBoard();
          }
          if (valueNotifierList.isNotEmpty) {
            valueNotifierList.toggle(content.stringID);
            return;
          }
          if (content is Anime &&
              content.releases.length == 1 &&
              !isFromLibrary &&
              !isFromSearch) {
            await context.push(
              RouteName.PLAYER.route,
              extra: PlayerArgs(anime: content, episode: content.releases.first),
            );
          } else {
            final result = await context.push(
              RouteName.CONTENTINFO.route,
              extra: ContentInformationArgs(content: content, isLibrary: isFromLibrary),
            );
            if (result != null && context.mounted) {
              context.showErrorNotification(result.toString());
            }
          }
        },
        splashFactory: InkRipple.splashFactory,
        overlayColor: WidgetStatePropertyAll(theme.colorScheme.primary.withAlpha(36)),
        child: ListTile(
          selectedTileColor: Theme.of(context).colorScheme.primary.withAlpha(25),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0).add(padding),
          selected: isSelected,
          title: Text(
            content.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium,
          ),
          subtitle: content is Anime
              ? Text(
                  '${content.releases.last.getEpisodeTitle()} - ${content.releases.last.isDublado ? "DUB" : "LEG"}',
                )
              : null,
          leading: Container(
            width: 100,
            margin: const EdgeInsets.symmetric(vertical: 2),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cacheSize = context.calculateImageCacheSizeByBoxConstraints(
                  constraints: constraints,
                  optimizeMemory: true,
                );

                return CustomCachedNetworkImage(
                  imageUrl: content.imageUrl,
                  width: cacheSize.width,
                  height: cacheSize.height,
                  fit: BoxFit.cover,
                  onTap: () async {
                    if (searchController?.isAttached == true &&
                        searchController!.isOpen) {
                      context.unFocusKeyBoard();
                    }
                    if (valueNotifierList.isNotEmpty) {
                      valueNotifierList.toggle(content.stringID);
                      return;
                    }
                    final result = await context.push(
                      RouteName.CONTENTINFO.route,
                      extra: ContentInformationArgs(
                        content: content,
                        isLibrary: isFromLibrary,
                      ),
                    );
                    if (result != null && context.mounted) {
                      context.showErrorNotification(result.toString());
                    }
                  },
                  borderRadius: _radius,
                  alignment: Alignment.center,
                  memCacheHeight: cacheSize.height.round(),
                  memCacheWidth: cacheSize.width.round(),
                  httpHeaders: headers,
                );
              },
            ),
          ),

          dense: true,
          minTileHeight: 68,
          minVerticalPadding: 0,
          visualDensity: const VisualDensity(vertical: 4, horizontal: -2),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: _radius.add(BorderRadiusGeometry.circular(2)),
        border: isSelected
            ? Border.all(color: Colors.white, width: 1.5)
            : Border.all(color: Colors.transparent, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: _radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final cacheSize = context.calculateImageCacheSizeByBoxConstraints(
                  constraints: constraints,
                  optimizeMemory: true,
                );

                return CustomCachedNetworkImage(
                  imageUrl: content.imageUrl,
                  fit: BoxFit.cover,
                  borderRadius: _radius,
                  alignment: Alignment.center,
                  memCacheHeight: cacheSize.height.round(),
                  memCacheWidth: cacheSize.width.round(),
                  httpHeaders: headers,
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54.withAlpha(140)],
                    stops: const [0.0, .9],
                  ).createShader(bounds),
                );
              },
            ),
            Positioned(
              bottom: 8,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isFromLibrary && !isFromSearch)
                    Text.rich(
                      TextSpan(
                        children: [
                          if (content.releases.length == 1) ...[
                            TextSpan(
                              text: '${content.releases.first.getEpisodeTitle()} - ',
                            ),
                          ],
                          if (content is Anime)
                            TextSpan(
                              text: content.isDublado ? 'DUB' : 'LEG',
                              style: TextStyle(
                                color: content.isDublado ? Colors.green : Colors.blue,
                              ),
                            ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall,
                    ),
                  Text(
                    content.title,
                    maxLines: isFromLibrary ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall,
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: _radius,
                onTap: () async {
                  onTap?.call(content);
                  if (searchController?.isAttached == true && searchController!.isOpen) {
                    context.unFocusKeyBoard();
                  }
                  if (valueNotifierList.isNotEmpty) {
                    valueNotifierList.toggle(content.stringID);
                    return;
                  }
                  if (content is Anime &&
                      content.releases.length == 1 &&
                      !isFromLibrary &&
                      !isFromSearch) {
                    await context.push(
                      RouteName.PLAYER.route,
                      extra: PlayerArgs(anime: content, episode: content.releases.first),
                    );
                  } else {
                    final result = await context.push(
                      RouteName.CONTENTINFO.route,
                      extra: ContentInformationArgs(
                        content: content,
                        isLibrary: isFromLibrary,
                      ),
                    );
                    if (result != null && context.mounted) {
                      context.showErrorNotification(result.toString());
                    }
                  }
                },
                onLongPress: isFromSearch
                    ? null
                    : () => valueNotifierList.toggle(content.stringID),
              ),
            ),
            if (content is Anime && !isFromLibrary && !isFromSearch)
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  icon: Icon(MdiIcons.information, size: 22),
                  visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                  onPressed: valueNotifierList.isEmpty
                      ? () async {
                          final result = await context.push(
                            RouteName.CONTENTINFO.route,
                            extra: ContentInformationArgs(content: content),
                          );
                          if (result != null && context.mounted) {
                            context.showErrorNotification(result.toString());
                          }
                        }
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
