import 'package:flutter/material.dart';

final _defaultLinearGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.centerRight,
  colors: <Color>[
    Colors.grey.shade300,
    Colors.grey.shade300,
    Colors.grey.shade100,
    Colors.grey.shade300,
    Colors.grey.shade300,
  ],
  stops: const <double>[
    0.0,
    0.35,
    0.5,
    0.65,
    1.0,
  ],
);

class Shimmer extends StatefulWidget {
  static ShimmerState? of(BuildContext context) {
    return context.findAncestorStateOfType<ShimmerState>();
  }

  Shimmer({
    super.key,
    LinearGradient? linearGradient,
    required this.child,
  }) : linearGradient = linearGradient ?? _defaultLinearGradient;

  final LinearGradient linearGradient;
  final Widget child;

  @override
  ShimmerState createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  final GlobalKey _container = GlobalKey();

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 2.0, period: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  LinearGradient get gradient => LinearGradient(
        colors: widget.linearGradient.colors,
        stops: widget.linearGradient.stops,
        begin: widget.linearGradient.begin,
        end: widget.linearGradient.end,
        transform: _SlidingGradientTransform(
          slidePercent: _shimmerController.value,
        ),
      );

  bool get isSized {
    final hasSize =
        ((_container.currentContext ?? context).findRenderObject() as RenderBox)
            .hasSize;

    return hasSize;
  }

  Size get size =>
      ((_container.currentContext ?? context).findRenderObject() as RenderBox)
          .size;

  Offset getDescendantOffset({
    required RenderBox descendant,
    Offset offset = Offset.zero,
  }) {
    final shimmerBox =
        (_container.currentContext ?? context).findRenderObject() as RenderBox;
    return descendant.localToGlobal(offset, ancestor: shimmerBox);
  }

  Listenable get shimmerChanges => _shimmerController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: _container,
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> {
  Listenable? _shimmerChanges;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _shimmerChanges?.removeListener(_onShimmerChange);

    _shimmerChanges = Shimmer.of(context)?.shimmerChanges;

    _shimmerChanges?.addListener(_onShimmerChange);
  }

  @override
  void dispose() {
    _shimmerChanges?.removeListener(_onShimmerChange);

    super.dispose();
  }

  void _onShimmerChange() {
    if (widget.isLoading && mounted) {
      setState(() {
        // update the shimmer painting.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    // Collect ancestor shimmer info.
    final shimmer = Shimmer.of(context)!;

    if (!shimmer.isSized) {
      // The ancestor Shimmer widget has not laid
      // itself out yet. Return an empty box.
      return const SizedBox.shrink();
    }
    final shimmerSize = shimmer.size;
    final gradient = shimmer.gradient;

    Offset offsetWithinShimmer = Offset.zero;
    if (context.findRenderObject() != null) {
      final box = context.findRenderObject() as RenderBox;
      offsetWithinShimmer = shimmer.getDescendantOffset(
        descendant: box,
      );
    }

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(
            -offsetWithinShimmer.dx,
            -offsetWithinShimmer.dy,
            shimmerSize.width,
            shimmerSize.height,
          ),
        );
      },
      child: widget.child,
    );
  }
}
