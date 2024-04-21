import 'package:app_wsrb_jsr/app/utils/copy_to_clipboard.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';

class FlexibleSpaceBarWidget extends StatelessWidget {
  const FlexibleSpaceBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // final odArgs =
    //     ModalRoute.of(context)?.settings.arguments as BookInformationArgs;
    final isLoading = BookInformationScope.isLoadingOf(context);

    final FlexibleSpaceBarSettings? settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

    Widget flexible = ClipRRect(
      clipper: _FlexibleSpaceBarClipper(radius: 18),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: isLoading
            ? ShimmerLoading(
                isLoading: isLoading,
                child: const Material(
                  child: Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    child: SizedBox.expand(),
                  ),
                ),
              )
            : const FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: _BuildContentWidget(),
              ),
      ),
    );

    if (settings != null && settings.isScrolledUnder != null) {
      final isScrolledUnder = settings.isScrolledUnder!;
      flexible = Material(
        key: ValueKey(isScrolledUnder),
        elevation: isScrolledUnder ? 0 : 8,
        borderRadius: isScrolledUnder ? null : BorderRadius.circular(18),
        color: Colors.transparent,
        child: flexible,
      );
    }

    return flexible;
  }
}

class _BuildContentWidget extends StatelessWidget {
  const _BuildContentWidget();

  @override
  Widget build(BuildContext context) {
    final book = BookInformationScope.contentOf(context);
    final themeData = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final titleLarge =
        themeData.textTheme.titleLarge?.copyWith(color: Colors.white);
    return Material(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _ImageWidget(book.imageUrl),
          Positioned(
            top: size.height * .15,
            left: 20,
            right: 50,
            child: GestureDetector(
              onLongPress: () async {
                copyToClipboard(
                  context,
                  messageCopy: book.title,
                  messageSnackBar: 'Copiado para a área de transferência!',
                );
                await Feedback.forLongPress(context);
              },
              child: Text(
                book.title,
                style: titleLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageWidget extends StatefulWidget {
  const _ImageWidget(this.imageUrl);

  final String imageUrl;

  @override
  State<_ImageWidget> createState() => __ImageWidgetState();
}

class __ImageWidgetState extends State<_ImageWidget> {
  String get _imageUrl => widget.imageUrl;

  bool _error = false;

  void _errorListener(Object object) {
    setStateIfMounted(() {
      _error = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = CachedNetworkImage(
      key: const ValueKey('flexible_space_bar_image'),
      errorListener: _errorListener,
      cacheKey: _imageUrl,
      imageUrl: _imageUrl,
      memCacheHeight: 1200,
      memCacheWidth: 900,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
    );

    if (_error) {
      return const Card(
        margin: EdgeInsets.zero,
      );
    }

    return ShaderMask(
      key: const ValueKey('flexible_space_bar_shader_mask'),
      blendMode: BlendMode.srcOver,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Theme.of(context).colorScheme.background.withOpacity(0.6)
          ],
          stops: const [0.0, 1.0],
        ).createShader(bounds);
      },
      child: imageWidget,
    );
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
