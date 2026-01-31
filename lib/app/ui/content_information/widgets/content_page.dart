import 'package:content_library/content_library.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../utils/content_utils.dart';
import '../../../utils/copy_to_clipboard.dart';
import '../../shared/widgets/custom_network_image_cache.dart';
import '../../shared/widgets/dot_text.dart';
import '../../shared/widgets/fade_through_transition_switcher.dart';
import '../../shared/widgets/shimmer_container.dart';
import '../destinations/information_destination.dart';
import '../destinations/release_destination.dart';
import 'scope.dart';

class ContentPage extends StatelessWidget {
  const ContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final noContent = ContentScope.noContentOf(context);
    final isLoading = ContentScope.isLoadingOf(context);
    // NestedScrollViewPlus
    return ExtendedNestedScrollView(
      // overscrollBehavior: OverscrollBehavior.outer,
      onlyOneScrollInBody: true,
      physics: isLoading
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      headerSliverBuilder: (context, __) => [const _Header()],
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
    final scope = ContentScope.of(context);
    final content = ContentScope.contentOf(context);
    final valueNotifierList = context.watch<ValueNotifierList>();
    final noContent = ContentScope.noContentOf(context);
    final isLoading = ContentScope.isLoadingOf(context);
    final isOpen = valueNotifierList.isNotEmpty;
    // final theme = Theme.of(context);
    return SliverAppBar(
      forceElevated: false,
      forceMaterialTransparency: true,
      expandedHeight: 250,
      pinned: false,
      floating: false,
      leading: IconButton(
        icon: Icon(isOpen ? Icons.close : Icons.arrow_back, color: Colors.white),
        onPressed: isOpen ? valueNotifierList.clear : scope.handleWillPop,
      ),
      actions: isLoading ? null : [const _ShareButton(), const _FavoriteButton()],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        stretchModes: const [],
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
    final size = context.calculateImageCacheSize(
      displayHeight: 250,
      optimizeMemory: true,
      displayWidth: 500,
      aspectRatio: 16 / 9,
    );

    // return Stack(
    //   fit: StackFit.expand,
    //   children: [
    //     ClipPath(
    //       clipper: ReversedBorderClipper(borderRadius: 20.0),
    //       child: ShimmerContainer(
    //         enable: isLoading,
    //         borderRadius: BorderRadius.circular(8),
    //         child: CustomCachedNetworkImage(
    //           memCacheHeight: size.height.round(),
    //           memCacheWidth: size.width.round(),
    //           width: double.infinity,
    //           height: double.infinity,
    //           imageUrl: content.imageUrl,
    //           fit: BoxFit.cover,
    //           httpHeaders: App.HEADERS,
    //           alignment: Alignment.center,
    //           shaderCallback: (bounds) => LinearGradient(
    //             begin: Alignment.center,
    //             end: Alignment.center,
    //             colors: [Colors.black.withAlpha(60), Colors.black.withAlpha(60)],
    //           ).createShader(bounds),
    //         ),
    //       ),
    //     ),
    //     Positioned(
    //       bottom: 70,
    //       right: 0,
    //       left: 0,
    //       child: SafeArea(
    //         child: _ContentDetails(content: content, isLoading: isLoading),
    //       ),
    //     ),
    //   ],
    // );

    // ClipPath(
    //     clipper: ReversedBorderClipper(borderRadius: 20.0),
    //     child:

    final extraLarge = content.anilistMedia?.bannerImage?.extraLarge ?? '';

    return SafeArea(
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        child: Stack(
          fit: StackFit.loose,
          alignment: AlignmentDirectional.center,
          children: [
            if (extraLarge.isNotEmpty)
              Center(
                child: CustomCachedNetworkImage(
                  height: 100,
                  width: double.infinity,
                  alignment: Alignment.center,
                  memCacheHeight: size.height.round(),
                  memCacheWidth: size.width.round(),
                  fit: BoxFit.cover,
                  imageUrl: extraLarge,
                  httpHeaders: App.HEADERS,
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black54, Color(0x3C000000), Colors.black54],
                    stops: [0.0, 0.4, 1.0],
                  ).createShader(rect),
                ),
              ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 70, right: 12),
                child: SafeArea(
                  child: _ContentDetails(content: content, isLoading: isLoading),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReversedBorderClipper extends CustomClipper<Path> {
  final double borderRadius;

  ReversedBorderClipper({this.borderRadius = 0.0});

  @override
  Path getClip(Size size) {
    final tabHeight = 58.0;
    final height = size.height - tabHeight;

    // final outerRect = Rect.fromLTWH(0, 90, size.width, size.height * 0.76);
    final outerRect = Rect.fromLTWH(0, 0, size.width, height);
    final outerRRect = RRect.fromRectAndRadius(outerRect, Radius.circular(borderRadius));

    // final testRect = Rect.fromLTWH(350, 260, size.width * 0.2, 80);
    // final testRRect = RRect.fromRectAndCorners(
    //   testRect,
    //   topLeft: Radius.circular(borderRadius),
    //   bottomLeft: Radius.circular(borderRadius),
    // );

    // final testPath = Path()..addRRect(testRRect);

    // Create paths for outer and inner rectangles
    final outerPath = Path()..addRRect(outerRRect);

    return Path.combine(PathOperation.difference, outerPath, Path());
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

// class _ContentDetails extends StatelessWidget {
//   final Content content;
//   final bool isLoading;

//   const _ContentDetails({required this.content, required this.isLoading});

//   @override
//   Widget build(BuildContext context) {
//     final genres = content.anilistMedia?.genres.getMax(4) ?? [];

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Gêneros
//           if (genres.isNotEmpty || isLoading)
//             ShimmerContainer(
//               height: 16,
//               enable: isLoading,
//               child: Row(
//                 spacing: 8,
//                 mainAxisSize: MainAxisSize.min,
//                 children: List.generate(genres.length, (index) {
//                   final txt = genres.elementAt(index);
//                   return DotText(
//                     text: txt,
//                     dotSize: 6,
//                     spacing: 6,
//                     textStyle: TextStyle(color: Colors.white70, fontSize: 12),
//                     dotColor: Colors.white70,
//                   );
//                 }),
//               ),
//             ),

//           const SizedBox(height: 4),

//           // Título
//           GestureDetector(
//             onLongPress: () {
//               copyToClipboard(
//                 context,
//                 messageSnackBar: "Texto copiado para a área de transferência!",
//                 messageCopy: content.title,
//               );
//               Feedback.forLongPress(context);
//             },
//             child: Text(
//               content.title,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           const SizedBox(height: 4),

//           // Ícones: Popularidade / Favoritos / Nota
//           ShimmerContainer(
//             height: 18,
//             enable: isLoading,
//             width: 180,
//             child: Row(
//               children: [
//                 if (content.anilistMedia?.popularity != null)
//                   _IconText(
//                     ico: Icons.people,
//                     txt: content.anilistMedia!.popularity!.toString(),
//                   ),
//                 if (content.anilistMedia?.favourites != null)
//                   Padding(
//                     padding: const EdgeInsets.only(left: 16),
//                     child: _IconText(
//                       ico: MdiIcons.heart,
//                       txt: content.anilistMedia!.favourites.toString(),
//                     ),
//                   ),
//                 if (content.anilistMedia?.averageScore != null)
//                   Padding(
//                     padding: const EdgeInsets.only(left: 16),
//                     child: _IconText(
//                       ico: MdiIcons.star,
//                       txt: (content.anilistMedia!.averageScore! / 10).toStringAsFixed(1),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _ContentDetails extends StatelessWidget {
  final Content content;
  final bool isLoading;

  const _ContentDetails({required this.content, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final size = context.calculateImageCacheSize(
      displayHeight: 200,
      displayWidth: 180,
      optimizeMemory: true,
    );

    final genres = content.anilistMedia?.genres ?? [];
    final loadingGenres = isLoading && genres.isEmpty;
    if (loadingGenres) {
      genres
        ..add("label")
        ..add("label")
        ..add("label");
    }

    final genresMax = genres.getMax(3);

    final popularity = content.anilistMedia?.popularity ?? -1;
    final favourites = content.anilistMedia?.favourites ?? -1;
    final averageScore = content.anilistMedia?.averageScore ?? -1;

    final loadingDetails =
        {popularity, favourites, averageScore}.contains(-1) && isLoading;

    final imageLoading = ContentScope.of(context).firstLoading && isLoading;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ShimmerContainer(
          width: 90,
          height: 130,
          enable: imageLoading,
          borderRadius: BorderRadius.circular(8),
          child: CustomCachedNetworkImage(
            fit: BoxFit.cover,
            memCacheHeight: size.height.round(),
            memCacheWidth: size.width.round(),
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
              ShimmerContainer(
                height: 16,
                enable: loadingGenres,
                child: Row(
                  spacing: 8,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(genresMax.length, (index) {
                    final txt = genresMax.elementAt(index);
                    return DotText(
                      text: txt,
                      dotSize: 6,
                      spacing: 4,
                      textStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                      dotColor: Colors.white70,
                    );
                  }),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onLongPress: () {
                  copyToClipboard(
                    context,
                    messageSnackBar: "Texto copiado para a área de transferência!",
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
                enable: loadingDetails,
                width: 180,
                child: Row(
                  spacing: 12,
                  children: [
                    if (popularity != -1)
                      _IconText(ico: Icons.people, txt: popularity.toString()),
                    if (favourites != -1)
                      _IconText(ico: MdiIcons.heart, txt: favourites.toString()),
                    if (averageScore != -1)
                      _IconText(
                        ico: MdiIcons.star,
                        txt: (averageScore / 10).toStringAsFixed(1),
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
      dividerColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      // indicatorColor: Colors.white,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white54,
      indicator: Material3TabIndicator(
        color: Theme.of(context).colorScheme.primary.withAlpha(26),
        height: 48,
        borderRadius: 8.0,
      ),
      splashFactory: NoSplash.splashFactory,
      overlayColor: OverlaySplashColor(theme.colorScheme),
      splashBorderRadius: BorderRadius.circular(8.0),
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
          ContentUtils.saveOrUpdate(context, content, true);
          Feedback.forLongPress(context);
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

class Material3TabIndicator extends Decoration {
  final Color color;
  final double height;
  final double borderRadius;

  const Material3TabIndicator({
    required this.color,
    this.height = 4.0,
    this.borderRadius = 2.0,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _Material3TabIndicatorPainter(
      color: color,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

class _Material3TabIndicatorPainter extends BoxPainter {
  final Color color;
  final double height;
  final double borderRadius;

  _Material3TabIndicatorPainter({
    required this.color,
    required this.height,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect =
        Offset(offset.dx, configuration.size!.height - height) &
        Size(configuration.size!.width, height);

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw rounded rectangle for the indicator
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)), paint);
  }
}

class OverlaySplashColor extends WidgetStateProperty<Color> {
  final ColorScheme colorScheme;

  OverlaySplashColor(this.colorScheme);

  @override
  Color resolve(Set<WidgetState> states) {
    // if (states.contains(WidgetState.pressed)) {
    //   return colorScheme.primary.withOpacity(0.1);
    // }
    return Colors.transparent;
  }
}
