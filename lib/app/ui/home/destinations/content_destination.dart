import 'dart:async';

import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/content_indicator_build.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auto_cache/flutter_auto_cache.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ContentDestination extends StatefulWidget {
  const ContentDestination({super.key});

  @override
  State<ContentDestination> createState() => _ContentDestinationState();
}

class _ContentDestinationState extends State<ContentDestination>
    with AutomaticKeepAliveClientMixin {
  late final ContentRepository _contentRepository;

  @override
  void initState() {
    super.initState();
    _contentRepository = context.read<ContentRepository>();
    _contentRepository.refresh(true);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final HomeScope scope = HomeScope.of(context);
    final TabController tabController = scope.tabController;

    Future<void> onRefresh() async {
      if (!mounted) return;
      if (tabController.index != 0) return;
      await _contentRepository.refresh(true);
    }

    final ConnectionChecker connectionChecker =
        context.watch<ConnectionChecker>();

    // customLog(railMenuController.isOpen);

    return RefreshIndicator(
      onRefresh: onRefresh,
      // child: ListView.builder(
      //   itemCount: Source.list.length,
      //   itemBuilder: (context, index) {
      //     final source = Source.list.elementAt(index);

      //     return ListTile(
      //       title: Text(source.label),
      //       onLongPress: () {},
      //       onTap: () {},
      //       trailing: TextButton(
      //         onPressed: () {},
      //         child: const Text('Recentes'),
      //       ),
      //     );
      //   },
      // ),

      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: connectionChecker.connectivityResult.isEmpty
            ? const FullScreenErrorWidget(btnAtualizar: false)
            : LoadingMoreList(
                ListConfig<Content>(
                  shrinkWrap: true,
                  // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  //   crossAxisCount: 2,
                  //   crossAxisSpacing: 8,
                  //   mainAxisSpacing: 8,
                  // ),
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  indicatorBuilder: contentIndicatorBuilder,
                  itemBuilder: _itemBuilder,
                  sourceList: _contentRepository,
                ),
                key: const PageStorageKey("content_destination"),
              ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, Content content, int index) {
    final ValueNotifierList valueNotifierList =
        context.watch<ValueNotifierList>();

    final HiveController hiveController = context.watch<HiveController>();

    final ThemeData themeData = Theme.of(context);

    final textTheme = themeData.textTheme;

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
          final appSnackBar = context.appSnackBar;
          final searchController = HomeScope.byKeyMaybeOf()?.searchController;

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
        overlayColor: _OverlayColor(content),
        child: ListTile(
          title: Text(
            content.title,
            maxLines: 2,
            style: textTheme.titleMedium!,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: false,
          dense: false,
          subtitle: Row(
            children: [
              Text(
                'Episódio ${content.releases.last.number}',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.normal,
                ),
              ),
              if (content is Anime) ...[
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: ' - '),
                      TextSpan(
                        text: (content).isDublado ? 'DUB' : 'LEG',
                        style: textTheme.titleSmall?.copyWith(
                          color:
                              (content).isDublado ? Colors.green : Colors.blue,
                        ),
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
                    borderRadius:
                        BorderRadius.circular(8).add(BorderRadius.circular(2)),
                    border: valueNotifierList.contains(content.stringID)
                        ? Border.all(color: Colors.white, width: 1.5)
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      filterQuality: FilterQuality.medium,
                      imageUrl: content.imageUrl,
                      placeholder: (context, url) => const _Placeholder(),
                      errorListener: customLog,
                      maxWidthDiskCache: 200,
                      maxHeightDiskCache: 150,
                      fit: BoxFit.cover,
                      alignment: FractionalOffset.center,
                      errorWidget: (context, url, error) =>
                          const _Placeholder(),
                      httpHeaders: {
                        ...App.HEADERS,
                        'Referer': '${hiveController.source.baseURL}/',
                      },
                    ),
                  ),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      if (valueNotifierList.isNotEmpty) {
                        valueNotifierList.toggle(content.stringID);
                        customLog(
                          'InkWell tapped title: ${content.title} - id: ${content.stringID}',
                        );
                        return;
                      }
                      final appSnackBar = context.appSnackBar;

                      customLog(
                        'InkWell tapped title: ${content.title} - id: ${content.stringID}',
                      );

                      final cache = await AutoCache.data.getJson(
                        key: content.stringID,
                      );
                      final cacheContent = switch (content) {
                        Anime _ when cache.data != null =>
                          Anime.fromMap(cache.data!),
                        Book _ when cache.data != null =>
                          Book.fromMap(cache.data!),
                        _ => null,
                      };
                      if (context.mounted) {
                        final result = await context.push(
                          RouteName.CONTENTINFO,
                          extra: ContentInformationArgs(
                            content: cacheContent ?? content,
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
    // return ItemContent(content: content);
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
