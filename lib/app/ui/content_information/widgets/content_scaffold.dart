import 'package:app_wsrb_jsr/app/ui/content_information/destinations/information_destination.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/destinations/release_destination.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/dot_text.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ContentScaffold extends StatelessWidget {
  const ContentScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final noContent = ContentScope.noContentOf(context);
    final saveData = ContentScope.of(context).saveData;
    final content = ContentScope.contentOf(context);
    final isLoading = ContentScope.isLoadingOf(context);
    final libraryService = context.watch<LibraryService>();
    final libraryController = context.watch<LibraryController>();
    final themeData = Theme.of(context);
    // final sizeOf = MediaQuery.sizeOf(context);
    // customLog(Colors.black.withOpacity(0.3).a);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          physics: BouncingScrollPhysics(),
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              floating: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    customLog(
                        'IconButton[MdiIcons.heart|MdiIcons.heartOutline] tapped title: ${content.title} - id: ${content.stringID}');
                    if (libraryService.favoritesIDS
                        .contains(content.stringID)) {
                      libraryController.remove(
                        contentEntity: content.toEntity(),
                      );
                    } else {
                      saveData(content);
                    }
                  },
                  icon: FadeThroughTransitionSwitcher(
                    enableSecondChild: libraryService.favoritesIDS.contains(
                      content.stringID,
                    ),
                    secondChild: Icon(
                      MdiIcons.heart,
                      color: Colors.red,
                    ),
                    child: Icon(MdiIcons.heartOutline),
                  ),
                ),
                // PopupMenuButton(
                //   icon: Icon(Icons.more_vert, color: Colors.white),
                //   itemBuilder: (_) => [
                //     PopupMenuItem(child: Text("Share")),
                //     PopupMenuItem(child: Text("Report")),
                //   ],
                // ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: [StretchMode.zoomBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (content.anilistMedia?.bannerImage?.extraLarge != null)
                      CachedNetworkImage(
                        cacheManager: App.APP_IMAGE_CACHE,
                        placeholder: (context, url) {
                          return Card.filled(
                            color: themeData.colorScheme.primary.withAlpha(10),
                          );
                        },
                        fit: BoxFit.fitWidth,
                        imageUrl:
                            content.anilistMedia!.bannerImage!.extraLarge!,
                        httpHeaders: App.HEADERS,
                      ),

                    // BackdropFilter(
                    //   filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    //   child: Container(
                    //     color: Colors.black.withValues(alpha: 0.3),
                    //   ),
                    // ),
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black54,
                            Colors.transparent.withAlpha(60),
                            Colors.black54,
                          ],
                          stops: [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                    // Conteúdo sobre o banner
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        bottom: 60,
                        right: 12,
                      ),
                      child: SafeArea(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                cacheManager: App.APP_IMAGE_CACHE,
                                placeholder: (context, url) {
                                  return Card.filled(
                                    color: themeData.colorScheme.primary
                                        .withAlpha(10),
                                  );
                                },
                                fit: BoxFit.cover,
                                width: 90,
                                height: 130,
                                memCacheHeight: 300,
                                memCacheWidth: 250,
                                imageUrl: content.imageUrl,
                                httpHeaders: App.HEADERS,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (content.anilistMedia?.genres != null)
                                    Row(
                                      spacing: 8,
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(
                                        content.anilistMedia!.genres
                                            .getMax(3)
                                            .length,
                                        (index) {
                                          final txt = content
                                              .anilistMedia!.genres
                                              .getMax(3)
                                              .elementAt(index);
                                          return SizedBox(
                                            height: 16,
                                            child: DotText(
                                              text: txt,
                                              dotSize: 6,
                                              spacing: 6,
                                              textStyle: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                              dotColor: Colors.white70,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  SizedBox(height: 4),
                                  // _ExpandableText(content!
                                  //     .anilistMedia!.description!
                                  //     .substring(0, 150)),
                                  Text(
                                    content.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  // if(content.anilistMedia)
                                  // Text(
                                  //   "SOY MEDIA, Hansol",
                                  //   style: TextStyle(
                                  //     color: Colors.white70,
                                  //     fontSize: 12,
                                  //   ),
                                  // ),
                                  // SizedBox(height: 8),
                                  Row(
                                    spacing: 12,
                                    children: [
                                      if (content.anilistMedia?.popularity !=
                                          null)
                                        _IconText(
                                          ico: Icons.people,
                                          txt: content.anilistMedia!.popularity!
                                              .toString(),
                                        ),
                                      if (content.anilistMedia?.popularity !=
                                          null) ...[
                                        _IconText(
                                            ico: MdiIcons.heart,
                                            txt: content
                                                    .anilistMedia?.favourites
                                                    .toString() ??
                                                ""),
                                      ],
                                      if (content.anilistMedia?.averageScore !=
                                          null) ...[
                                        _IconText(
                                          ico: MdiIcons.star,
                                          txt: (content.anilistMedia!
                                                      .averageScore! /
                                                  10)
                                              .toString(),
                                        ),
                                      ],
                                    ],
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
              bottom: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                onTap: (index) {
                  final data = ContentTabBar.values.elementAt(index);
                  final disable =
                      noContent && data == ContentTabBar.INFORMATION;
                  if (disable) {
                    DefaultTabController.maybeOf(context)?.animateTo(0);
                  }
                },
                tabs: ContentTabBar.values.map(
                  (data) {
                    final themeData = Theme.of(context);
                    final disable =
                        noContent && data == ContentTabBar.INFORMATION;
                    return Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            data.getIconData(content),
                            color: disable ? themeData.disabledColor : null,
                          ),
                          const SizedBox(width: 8),
                          Center(
                            child: Text(
                              data.getTitle(content),
                              style: TextStyle(
                                color: disable ? themeData.disabledColor : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ],
          body: TabBarView(
            physics: isLoading || noContent
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            children: const [
              ReleaseDestination(),
              InformationDestination(),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  final IconData ico;
  final String txt;
  const _IconText({
    required this.txt,
    required this.ico,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(ico, color: Colors.white70, size: 14),
        SizedBox(width: 4),
        Text(txt, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
