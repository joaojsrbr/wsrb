import 'package:app_wsrb_jsr/app/ui/shared/widgets/image_filter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:flutter/src/rendering/sliver_persistent_header.dart'
    show OverScrollHeaderStretchConfiguration;

import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer.dart';
import 'package:app_wsrb_jsr/app/utils/copy_to_clipboard.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ContentPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  const ContentPersistentHeaderDelegate({
    required this.maxExtent,
    required this.content,
    required this.isLoading,
    required this.minExtent,
    this.onStretchTrigger,
  });

  final Content content;
  final bool isLoading;

  final Future<void> Function()? onStretchTrigger;

  @override
  final double maxExtent;

  @override
  final double minExtent;

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration =>
      OverScrollHeaderStretchConfiguration(
        stretchTriggerOffset: maxExtent,
        onStretchTrigger: onStretchTrigger,
      );

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double opacity =
        ((maxExtent - shrinkOffset) - 100).clamp(0.0, 100) / 100;

    Widget flexible = ClipRRect(
      clipper: _FlexibleSpaceBarClipper(radius: 18),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: isLoading
            ? const ShimmerLoading(
                isLoading: true,
                child: Card(child: SizedBox.expand()),
              )
            : _BuildContentWidget(opacity, content),
      ),
    );

    return Material(
      elevation: opacity == 0.0 ? 8 : 8,
      borderRadius: opacity == 0.0 ? null : BorderRadius.circular(18),
      color: Colors.transparent,
      child: flexible,
    );
  }

  @override
  bool shouldRebuild(covariant ContentPersistentHeaderDelegate oldDelegate) {
    return oldDelegate.isLoading != isLoading ||
        oldDelegate.content != oldDelegate.content ||
        oldDelegate.maxExtent != oldDelegate.maxExtent ||
        oldDelegate.minExtent != oldDelegate.minExtent;
  }
}

class _BuildContentWidget extends StatelessWidget {
  const _BuildContentWidget(this.opacity, this.content);

  final double opacity;
  final Content content;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final LibraryController libraryController =
        context.watch<LibraryController>();

    final LibraryService libraryService =
        LibraryService(libraryController, context.watch());

    // customLog(opacity);
    // final size = MediaQuery.sizeOf(context);

    List<Genre>? genres;

    switch (content) {
      case Anime data:
        genres = data.genres;
        break;
      case Book data:
        genres = data.genres;
        break;
    }

    final titleLarge =
        themeData.textTheme.titleLarge?.copyWith(color: Colors.white);
    final titleSmall = themeData.textTheme.titleSmall?.copyWith();
    return Material(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: opacity,
            child: ShaderMask(
              key: const ValueKey('flexible_space_bar_shader_mask'),
              blendMode: BlendMode.srcOver,
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).colorScheme.surface.withOpacity(0.55)
                  ],
                  stops: const [0.6, 1.0],
                ).createShader(bounds);
              },
              child: ImageFilter(
                saturation: 0.4,
                child: _ImageWidget(content.imageUrl),
              ),
            ),
          ),
          // Positioned.fill(
          //   child: ShaderMask(
          //     key: const ValueKey('flexible_space_bar_shader_mask'),
          //     blendMode: BlendMode.srcOver,
          //     shaderCallback: (bounds) {
          //       return LinearGradient(
          //         begin: Alignment.topCenter,
          //         end: Alignment.bottomCenter,
          //         colors: [
          //           Colors.transparent,
          //           Theme.of(context).colorScheme.background.withOpacity(0.6)
          //         ],
          //         stops: const [0.0, 1.0],
          //       ).createShader(bounds);
          //     },
          //   ),
          // ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: FadeThroughTransitionSwitcher(
                enableSecondChild: opacity < 0.7,
                duration: const Duration(milliseconds: 600),
                child: const BackButton(),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: FadeThroughTransitionSwitcher(
                enableSecondChild: opacity < 0.7,
                duration: const Duration(milliseconds: 600),
                child: IconButton(
                  onPressed: () {
                    customLog(
                        'IconButton[MdiIcons.heart|MdiIcons.heartOutline] tapped title: ${content.title} - id: ${content.stringID}');
                    if (libraryService.favoritesIDS
                        .contains(content.stringID)) {
                      libraryController.remove(
                          contentEntity: content.toEntity());
                    } else {
                      libraryController.add(
                          contentEntity: content.toEntity(isFavorite: true));
                    }
                  },
                  icon: FadeThroughTransitionSwitcher(
                    enableSecondChild: libraryService.favoritesIDS.contains(
                      content.stringID,
                    ),
                    secondChild: Icon(MdiIcons.heart, color: Colors.red),
                    child: Icon(MdiIcons.heartOutline),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 20,
            left: 20,
            right: 20,
            bottom: 20,
            child: GestureDetector(
              onLongPress: () async {
                copyToClipboard(
                  context,
                  messageCopy: content.title,
                  messageSnackBar: 'Copiado para a área de transferência!',
                );
                await Feedback.forLongPress(context);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 150),
                    child: Text(
                      content.title,
                      style: titleLarge?.copyWith(
                        shadows: opacity > 0.60
                            ? [
                                const Shadow(
                                  color: Colors.black,
                                  blurRadius: 18.0,
                                  offset: Offset(2.0, 2.0),
                                ),
                              ]
                            : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: opacity < 1.0 ? 1 : 2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: opacity <= 0.40 ? 0 : 1,
                    child: opacity <= 0.40
                        ? const SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (content is Anime)
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          (content as Anime).isDublado
                                              ? "Dublado"
                                              : "Legendado",
                                          style: titleSmall?.copyWith(
                                            fontSize: 10,
                                            color: (content as Anime).isDublado
                                                ? Colors.blue
                                                : Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if ((genres?.length ?? 0) > 0)
                                Wrap(
                                  spacing: 3.0,
                                  runSpacing: 0.0,
                                  children: genres!
                                      .map((genre) => genre.label)
                                      .map(
                                        (label) => Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              label,
                                              style: titleSmall?.copyWith(
                                                fontSize: 10,
                                                color: Colors.orangeAccent,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                )
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageWidget extends StatelessWidget {
  const _ImageWidget(this.imageUrl);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    // final Size sizeOf = MediaQuery.sizeOf(context);
    // customLog(sizeOf.height);
    final imageWidget = SizedBox(
      child: CachedNetworkImage(
        key: const ValueKey('flexible_space_bar_image'),
        cacheKey: imageUrl,
        imageUrl: imageUrl,
        width: 1080,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        maxHeightDiskCache: 2000,
        maxWidthDiskCache: 1080,
      ),
    );
    return imageWidget;
    // return ShaderMask(
    //   key: const ValueKey('flexible_space_bar_shader_mask'),
    //   blendMode: BlendMode.srcOver,
    //   shaderCallback: (bounds) {
    //     return LinearGradient(
    //       begin: Alignment.topCenter,
    //       end: Alignment.bottomCenter,
    //       colors: [
    //         Colors.transparent,
    //         Theme.of(context).colorScheme.background.withOpacity(0.6)
    //       ],
    //       stops: const [0.0, 1.0],
    //     ).createShader(bounds);
    //   },
    //   child: imageWidget,
    // );
  }
}

class _FlexibleSpaceBarClipper extends CustomClipper<RRect> {
  _FlexibleSpaceBarClipper({
    // ignore: unused_element
    this.axis = Axis.vertical,
    // ignore: unused_element
    this.topLeft = Radius.zero,
    // ignore: unused_element
    this.topRight = Radius.zero,
    required this.radius,
  });

  final Axis axis;
  final double radius;
  final Radius topLeft;
  final Radius topRight;

  @override
  RRect getClip(Size size) {
    switch (axis) {
      case Axis.horizontal:
        final double offset = size.width;
        if (offset < 0) {
          return RRect.fromLTRBAndCorners(
            size.width + offset,
            0.0,
            size.width,
            size.height,
            topLeft: Radius.circular(radius),
            bottomLeft: Radius.circular(radius),
          );
        }
        return RRect.fromLTRBAndCorners(
          0.0,
          0.0,
          offset,
          size.height,
          topRight: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        );
      case Axis.vertical:
        final double offset = size.height;

        if (offset < 0) {
          return RRect.fromLTRBAndCorners(
            0.0,
            size.height + offset,
            size.width,
            size.height,
            bottomRight: Radius.circular(radius),
            bottomLeft: Radius.circular(radius),
            topLeft: topLeft,
            topRight: topRight,
          );
        }
        return RRect.fromLTRBAndCorners(
          0.0,
          0.0,
          size.width,
          offset,
          bottomRight: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
          topLeft: topLeft,
          topRight: topRight,
        );
    }
  }

  RRect getApproximateClipRRect(Size size) => getClip(size);

  @override
  bool shouldReclip(_FlexibleSpaceBarClipper oldClipper) {
    return oldClipper.axis != axis;
  }
}

// class InvertedRoundedRectanglePainter extends CustomPainter {
//   InvertedRoundedRectanglePainter({
//     required this.radius,
//     required this.color,
//   });

//   final double radius;
//   final Color color;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final cornerSize = Size.square(radius * 2);
//     final Paint paint = Paint()..color = color;

//     // Desenha a linha superior do retângulo
//     canvas.drawLine(
//       Offset(radius, 0), // canto superior esquerdo
//       Offset(size.width - radius, 0), // canto superior direito
//       paint,
//     );

//     // Desenha o arco superior direito
//     canvas.drawArc(
//       Rect.fromLTWH(size.width - 2 * radius, 0, 2 * radius, 2 * radius),
//       -math.pi / 2, // 90 graus no sentido horário
//       math.pi / 2, // 90 graus no sentido horário
//       false,
//       paint,
//     );

//     // Desenha a linha inferior direita
//     canvas.drawLine(
//       Offset(size.width, 2 * radius), // canto superior direito do arco
//       Offset(size.width, size.height - radius), // canto inferior direito
//       paint,
//     );

//     // Desenha a linha inferior esquerda
//     canvas.drawLine(
//       Offset(size.width, size.height - radius), // canto inferior direito
//       Offset(0, size.height - radius), // canto inferior esquerdo
//       paint,
//     );

//     // Desenha o arco inferior esquerdo
//     canvas.drawArc(
//       Rect.fromLTWH(0, size.height - 2 * radius, 2 * radius, 2 * radius),
//       math.pi / 2, // 90 graus no sentido horário
//       math.pi / 2, // 90 graus no sentido horário
//       false,
//       paint,
//     );

//     // Desenha a linha superior esquerda
//     canvas.drawLine(
//       Offset(0, size.height - 2 * radius), // canto inferior esquerdo do arco
//       Offset(0, 0), // canto superior esquerdo
//       paint,
//     );
//   }

//   @override
//   bool shouldRepaint(InvertedRoundedRectanglePainter oldDelegate) =>
//       oldDelegate.radius != radius || oldDelegate.color != color;
// }
