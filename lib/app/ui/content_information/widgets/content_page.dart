import 'package:app_wsrb_jsr/app/ui/content_information/destinations/information_destination.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/destinations/release_destination.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/bottom_menu.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_network_image_cache.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/dot_text.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer_container.dart';
import 'package:app_wsrb_jsr/app/utils/content_utils.dart';
import 'package:app_wsrb_jsr/app/utils/copy_to_clipboard.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nested_scroll_view_plus/nested_scroll_view_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ContentPage extends StatelessWidget {
  const ContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final noContent = ContentScope.noContentOf(context);
    final isLoading = ContentScope.isLoadingOf(context);

    return NestedScrollViewPlus(
      overscrollBehavior: OverscrollBehavior.outer,
      physics: isLoading
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      headerSliverBuilder: (context, __) => [_Header()],
      body: TabBarView(
        physics: isLoading || noContent
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        children: const [ReleaseDestination(), InformationDestination()],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final content = ContentScope.contentOf(context);
    final menu = BottomMenu.menuControllerMaybeOf<List<String>>(context);
    final noContent = ContentScope.noContentOf(context);
    final isLoading = ContentScope.isLoadingOf(context);
    final isOpen = menu?.isOpen ?? false;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      floating: true,
      leading: IconButton(
        icon: Icon(
          isOpen ? Icons.close : Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: isOpen
            ? () => menu?.close()
            : () => Navigator.of(context).pop(),
      ),
      actions: isLoading ? null : [_ShareButton(), _FavoriteButton()],
      flexibleSpace: FlexibleSpaceBar(
        background: _BannerContent(content: content, isLoading: isLoading),
      ),
      bottom: _TabHeader(noContent: noContent, content: content),
    );
  }
}

class _BannerContent extends StatelessWidget {
  final Content content;
  final bool isLoading;

  const _BannerContent({required this.content, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (content.anilistMedia?.bannerImage?.extraLarge != null)
          CustomCachedNetworkImage(
            fit: BoxFit.fitWidth,
            imageUrl: content.anilistMedia!.bannerImage!.extraLarge!,
            httpHeaders: App.HEADERS,
          ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black54, Color(0x3C000000), Colors.black54],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 60, right: 12),
          child: SafeArea(
            child: _ContentDetails(content: content, isLoading: isLoading),
          ),
        ),
      ],
    );
  }
}

class _ContentDetails extends StatelessWidget {
  final Content content;
  final bool isLoading;

  const _ContentDetails({required this.content, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ShimmerContainer(
          width: 90,
          height: 130,
          enable: isLoading,
          borderRadius: BorderRadius.circular(8),
          child: CustomCachedNetworkImage(
            fit: BoxFit.cover,
            memCacheHeight: 300,
            memCacheWidth: 250,
            imageUrl: content.imageUrl,
            httpHeaders: App.HEADERS,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (content.anilistMedia?.genres != null || isLoading)
                ShimmerContainer(
                  height: 16,
                  enable: isLoading,
                  child: Row(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      (content.anilistMedia?.genres ?? []).getMax(3).length,
                      (index) {
                        final txt = content.anilistMedia!.genres
                            .getMax(3)
                            .elementAt(index);
                        return DotText(
                          text: txt,
                          dotSize: 6,
                          spacing: 6,
                          textStyle: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          dotColor: Colors.white70,
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              GestureDetector(
                onLongPress: () {
                  copyToClipboard(
                    context,
                    messageSnackBar:
                        "Texto copiado para a área de transferência!",
                    messageCopy: content.title,
                  );
                  Feedback.forLongPress(context);
                },
                child: Text(
                  content.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              ShimmerContainer(
                height: 18,
                enable: isLoading,
                width: 180,
                child: Row(
                  spacing: 12,
                  children: [
                    if (content.anilistMedia?.popularity != null)
                      _IconText(
                        ico: Icons.people,
                        txt: content.anilistMedia!.popularity!.toString(),
                      ),
                    if (content.anilistMedia?.favourites != null)
                      _IconText(
                        ico: MdiIcons.heart,
                        txt: content.anilistMedia!.favourites.toString(),
                      ),
                    if (content.anilistMedia?.averageScore != null)
                      _IconText(
                        ico: MdiIcons.star,
                        txt: (content.anilistMedia!.averageScore! / 10)
                            .toStringAsFixed(1),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool noContent;
  final Content content;

  const _TabHeader({required this.noContent, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TabBar(
      indicatorColor: Colors.white,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white54,
      onTap: (index) {
        final selected = ContentTabBar.values[index];
        if (noContent && selected == ContentTabBar.INFORMATION) {
          DefaultTabController.of(context).animateTo(0);
        }
      },
      tabs: ContentTabBar.values.map((data) {
        final disabled = noContent && data == ContentTabBar.INFORMATION;
        return Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                data.getIconData(content),
                color: disabled ? theme.disabledColor : null,
              ),
              const SizedBox(width: 8),
              Text(
                data.getTitle(content),
                style: TextStyle(color: disabled ? theme.disabledColor : null),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ShareButton extends StatelessWidget {
  const _ShareButton();

  @override
  Widget build(BuildContext context) {
    final content = ContentScope.contentOf(context);
    return IconButton(
      icon: Icon(MdiIcons.share),
      onPressed: () async {
        final uri = Uri.parse(content.url);
        final result = await SharePlus.instance.share(ShareParams(uri: uri));
        if (result.status == ShareResultStatus.success) {
          customLog('Obrigado por compartilhar!');
        }
      },
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton();

  @override
  Widget build(BuildContext context) {
    final content = ContentScope.contentOf(context);
    final library = context.watch<LibraryController>();
    final isFav = library.repo.containsFav(content: content);

    return IconButton(
      onPressed: () {
        if (isFav) {
          customLog('Favorite remove: ${content.title}');
          library.remove(contentEntity: content.toEntity());
        } else {
          customLog('Favorite add: ${content.title}');
          ContentUtils.saveOrUpdate(context, content);
          // ContentScope.of(context).saveData();
        }
      },
      icon: FadeThroughTransitionSwitcher(
        enableSecondChild: isFav,
        secondChild: Icon(MdiIcons.heart, color: Colors.red),
        child: Icon(MdiIcons.heartOutline),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  final IconData ico;
  final String txt;

  const _IconText({required this.txt, required this.ico});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(ico, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(txt, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
