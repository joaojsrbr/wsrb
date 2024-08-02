import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

class SinopseWidget extends StatefulWidget {
  const SinopseWidget({super.key});

  @override
  State<SinopseWidget> createState() => _SinopseWidgetState();
}

class _SinopseWidgetState extends State<SinopseWidget> {
  bool _expanded = false;

  void _onTap() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);
    final isLoading = BookInformationScope.isLoadingOf(context);
    final ThemeData themeData = Theme.of(context);
    final content = BookInformationScope.contentOf(context);

    String substring = content.sinopse ?? "";

    final bool isOver100 = (content.sinopse ?? "").length > 100;

    if (isOver100 && !_expanded) {
      substring = "${content.sinopse?.substring(0, 100)} ...";
    }

    Widget container = const SliverToBoxAdapter();

    if (isLoading) {
      container = SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, right: 8, left: 8),
          child: ShimmerWidget(
            height: 60,
            borderRadius: borderRadius,
          ),
        ),
      );
    } else if (substring.isNotEmpty) {
      if (substring.isEmpty) return const SliverToBoxAdapter();

      container = SliverAnimatedPaintExtent(
        duration: const Duration(milliseconds: 150),
        child: SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, right: 8, left: 8),
            child: Card.filled(
              color: themeData.colorScheme.primary.withOpacity(0.04),
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              child: InkWell(
                overlayColor: _OverlayColor(context),
                borderRadius: borderRadius,
                onTap: isOver100 ? _onTap : null,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    // isOver100 && !_expanded ? substring : widget.sinopse,
                    substring,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return SliverAnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: container,
    );
  }
}

class _OverlayColor extends WidgetStateProperty<Color?> {
  _OverlayColor(this._context);
  final BuildContext _context;

  ColorScheme get _colorScheme => Theme.of(_context).colorScheme;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) {
      return _colorScheme.primary.withOpacity(0.12);
    } else if (states.contains(WidgetState.hovered)) {
      return _colorScheme.primary.withOpacity(0.08);
    } else if (states.contains(WidgetState.focused)) {
      return Colors.transparent;
    }
    return Colors.transparent;
  }
}
