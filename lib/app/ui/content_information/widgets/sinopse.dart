import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

class SinopseWidget extends StatefulWidget {
  const SinopseWidget({super.key, required this.sinopse});

  final String sinopse;

  @override
  State<SinopseWidget> createState() => _SinopseWidgetState();
}

class _SinopseWidgetState extends State<SinopseWidget> {
  String _substring = "";
  bool _expanded = false;

  bool get _isOver100 => widget.sinopse.length > 100;

  @override
  void initState() {
    super.initState();

    if (_isOver100) {
      _substring = "${widget.sinopse.substring(0, 100)} ...";
    }
  }

  void _onTap() {
    setState(() => _expanded = !_expanded);
  }

  @override
  void didUpdateWidget(covariant SinopseWidget oldWidget) {
    if (widget.sinopse != oldWidget.sinopse && widget.sinopse.length > 100) {
      _substring = "${widget.sinopse.substring(0, 100)} ...";
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);
    final isLoading = BookInformationScope.isLoadingOf(context);

    if (isLoading) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, right: 8, left: 8),
          child: SizedBox(
            height: 60,
            child: ShimmerLoading(
              isLoading: isLoading,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: borderRadius),
                margin: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      );
    }

    return SliverAnimatedPaintExtent(
      duration: const Duration(milliseconds: 300),
      child: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, right: 8, left: 8),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            margin: EdgeInsets.zero,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: _isOver100 ? _onTap : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _isOver100 && !_expanded ? _substring : widget.sinopse,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
