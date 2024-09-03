// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class SubordinateLibraryTabController extends TabController {
  SubordinateLibraryTabController({
    required super.vsync,
    super.initialIndex,
    required super.length,
  });

  PageController? _parent;

  set setParent(PageController? pageView) {
    _parent?.removeListener(_pageListener);
    _parent = pageView;
    _parent?.addListener(_pageListener);
  }

  void _pageListener() {
    setIgnorePointer(false);
  }

  void setIgnorePointer([bool? active]) {
    _parent?.position.context.setIgnorePointer(active ?? true);
  }

  bool scrollNotificationNextPage(ScrollNotification notification) {
    // const horizontalDirections = {AxisDirection.right, AxisDirection.left};
    const verticalDirections = {AxisDirection.down, AxisDirection.up};
    final axisDirection = notification.metrics.axisDirection;

    if (verticalDirections.contains(axisDirection)) {
      setIgnorePointer(false);
      return false;
    }

    if (notification is ScrollUpdateNotification) setIgnorePointer(false);
    if (notification is OverscrollNotification) {
      final ScrollMetrics metrics = notification.metrics;
      final double pixels = metrics.pixels.roundToDouble();
      final double maxScrollExtent = metrics.maxScrollExtent.roundToDouble();
      final double minScrollExtent = metrics.minScrollExtent;
      if (pixels == minScrollExtent) {
        setIgnorePointer(true);
      } else if (pixels == maxScrollExtent) {
        setIgnorePointer(true);
      }
    }
    return false;
  }

  @override
  void dispose() {
    _parent?.removeListener(_pageListener);
    super.dispose();
  }

  SubordinateLibraryTabController copyWithAndDispose({
    int? currentIndex,
    int? length,
    int? initialIndex,
    required TickerProvider vsync,
  }) {
    final newTabController = SubordinateLibraryTabController(
      vsync: vsync,
      length: length ?? this.length,
      initialIndex: initialIndex ?? index,
    );

    newTabController.setParent = _parent;

    dispose();
    return newTabController;
  }
}

class SubordinateScrollController extends ScrollController {
  SubordinateScrollController(
    this.parent, {
    String subordinateDebugLabel = 'subordinate',
  }) : super(
          debugLabel: parent.debugLabel == null
              ? null
              : '${parent.debugLabel}/$subordinateDebugLabel',
          initialScrollOffset: parent.initialScrollOffset,
          keepScrollOffset: parent.keepScrollOffset,
        );
  final ScrollController parent;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) =>
      parent.createScrollPosition(physics, context, oldPosition);

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    parent.attach(position);
  }

  @override
  void detach(ScrollPosition position) {
    parent.detach(position);
    super.detach(position);
  }

  @override
  void dispose() {
    for (final position in positions) {
      parent.detach(position);
    }

    super.dispose();
  }

  @override
  void addListener(VoidCallback listener) {
    parent.addListener(listener);
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    parent.removeListener(listener);
    super.removeListener(listener);
  }
}
