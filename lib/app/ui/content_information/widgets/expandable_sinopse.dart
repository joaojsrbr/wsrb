// ignore_for_file: public_member_api_docs, sort_constructors_first, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html2md/html2md.dart' as html2md;

class ExpandableSinopse extends StatefulWidget {
  final String sinopse;
  final int maxLines;
  final TextStyle? style;

  const ExpandableSinopse({
    super.key,
    required this.sinopse,
    this.maxLines = 2,
    this.style,
  });

  @override
  State<ExpandableSinopse> createState() => _ExpandableSinopseState();
}

class _ExpandableSinopseState extends State<ExpandableSinopse>
    with TickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textStyle = widget.style ?? themeData.textTheme.bodyMedium!;

    return LayoutBuilder(builder: (context, constraints) {
      final span = TextSpan(text: widget.sinopse, style: textStyle);
      final tp = TextPainter(
        text: span,
        maxLines: widget.maxLines,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: constraints.maxWidth);

      final fitLength = tp
          .getPositionForOffset(
            Offset(
              constraints.maxWidth,
              tp.preferredLineHeight * widget.maxLines,
            ),
          )
          .offset;

      final needsTrim = tp.didExceedMaxLines;
      final displayText = _expanded || !needsTrim
          ? widget.sinopse
          : '${widget.sinopse.substring(0, fitLength.clamp(0, widget.sinopse.length))}...';
      return InkWell(
        onTap: needsTrim ? () => setState(() => _expanded = !_expanded) : null,
        borderRadius: BorderRadius.circular(8),
        overlayColor: _OverlayColor(context),
        child: Card.filled(
          margin: EdgeInsets.zero,
          color: themeData.colorScheme.primary.withAlpha(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sinopse',
                  style: themeData.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: themeData.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedSize(
                  duration: const Duration(milliseconds: 350),
                  alignment: Alignment.topCenter,
                  child: Markdown(
                    data: html2md.convert(displayText),
                    styleSheet:
                        MarkdownStyleSheet.fromTheme(themeData).copyWith(
                      p: textStyle,
                      textAlign: WrapAlignment.spaceBetween,
                    ),
                    selectable: true,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    onTapText: needsTrim
                        ? () => setState(() => _expanded = !_expanded)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _OverlayColor extends WidgetStateProperty<Color?> {
  _OverlayColor(this._context);
  final BuildContext _context;

  ColorScheme get _colorScheme => Theme.of(_context).colorScheme;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) {
      return _colorScheme.primary.withAlpha(30);
    } else if (states.contains(WidgetState.hovered)) {
      return _colorScheme.primary.withAlpha(20);
    } else if (states.contains(WidgetState.focused)) {
      return Colors.transparent;
    }
    return Colors.transparent;
  }
}
