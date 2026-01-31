import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const _defaultRadius = BorderRadius.all(Radius.circular(8));

class NeonCard extends StatefulWidget {
  final Widget child;
  final double intensity;
  final double glowSpread;
  final Color firstColor;
  final Color secondColor;
  final double blurSigma;
  final BorderRadius borderRadius;
  final bool enable;

  const NeonCard({
    super.key,
    required this.child,
    this.intensity = 0.3,
    this.glowSpread = 2.0,
    this.blurSigma = 50.00,
    this.enable = true,
    this.borderRadius = _defaultRadius,
    this.firstColor = const Color(0xFFFF00AA),
    this.secondColor = const Color(0xFF00FFF1),
  });

  @override
  State<NeonCard> createState() => _NeonCardState();
}

class _NeonCardState extends State<NeonCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: GlowRectanglePainter(
            progress: _controller.value,
            intensity: widget.intensity,
            blurSigma: widget.blurSigma,
            firstColor: widget.firstColor,
            secondColor: widget.secondColor,
            glowSpread: widget.glowSpread,
            enable: widget.enable,
            borderRadius: widget.borderRadius,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class GlowRectanglePainter extends CustomPainter {
  final double progress;
  final double intensity;
  final double glowSpread;
  final Color firstColor;
  final Color secondColor;
  final double blurSigma;
  final BorderRadius borderRadius;
  final bool enable;
  GlowRectanglePainter({
    required this.progress,
    this.intensity = 0.3,
    this.glowSpread = 2.0,
    required this.blurSigma,
    required this.enable,
    required this.borderRadius,
    required this.firstColor,
    required this.secondColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    // const firstColor = Color(0xFFFF00AA);
    // const secondColor = Color(0xFF00FFF1);
    // const blurSigma = 50.0;

    final backgroundPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width / 2, size.height / 2),
        size.width * glowSpread,
        [
          Color.lerp(firstColor, secondColor, progress)!.withOpacity(intensity),
          Color.lerp(firstColor, secondColor, progress)!.withOpacity(0.0),
        ],
      )
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    canvas.drawRect(rect.inflate(size.width * glowSpread), backgroundPaint);

    final blackPaint = Paint()..color = Colors.black;
    canvas.drawRRect(rrect, blackPaint);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..shader = LinearGradient(
        colors: [
          Color.lerp(firstColor, secondColor, progress)!,
          Color.lerp(secondColor, firstColor, progress)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    canvas.drawRRect(rrect, glowPaint);
  }

  @override
  bool shouldRepaint(GlowRectanglePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.firstColor != firstColor ||
      oldDelegate.secondColor != secondColor ||
      oldDelegate.blurSigma != blurSigma ||
      oldDelegate.intensity != intensity ||
      oldDelegate.enable != enable ||
      oldDelegate.glowSpread != glowSpread;
}

class GradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final List<Color> gradientColors;

  const GradientText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: gradientColors,
          stops: const [0.0, 0.3, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          height: 1,
          letterSpacing: -1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
