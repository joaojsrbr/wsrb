// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';

class SubordinateLibraryTabController extends TabController {
  SubordinateLibraryTabController({
    required super.vsync,
    super.initialIndex,
    required super.length,
  });

  // int get _currentIndex => 1;

  final Debouncer _changePageDebouncer = Debouncer(
    duration: const Duration(milliseconds: 100),
  );

  PageController? _parent;

  set setParent(PageController? pageView) {
    _parent?.removeListener(_setIgnorePointer);
    _parent = pageView;
    _parent?.addListener(_setIgnorePointer);
  }

  bool _changePage = false;

  set setChangePage(bool changePag) {
    _changePage = changePag;
  }

  void _setIgnorePointer() {
    if (_parent?.page == null) return;

    final parentPage = _parent!.page!;
    final nextPage = parentPage + 1;
    final previousPage = parentPage - 1;

    if ([
      nextPage.toInt(),
      previousPage.toInt(),
    ].contains(parentPage.toInt())) {
      _changePageDebouncer.cancel();
      _changePage = false;
    }

    // customLog(_currentIndex);
    // customLog(parentPage);

    // if (parentPage < nextPage && parentPage >= _currentIndex) {
    //   _parent?.position.context.setIgnorePointer(true);
    // } else if (_currentIndex != 0 &&
    //     parentPage > 0.8 &&
    //     parentPage < _currentIndex) {
    //   _parent?.position.context.setIgnorePointer(false);
    // }
  }

  Future<void> parentNextPage() async {
    if (_parent?.page == null) return;
    _parent?.position.context.setIgnorePointer(true);
    // await _parent?.animateToPage(
    //   _parent!.page!.toInt() + 1,
    //   duration: kTabScrollDuration,
    //   curve: Curves.ease,
    // );
    _changePage = false;
  }

  Future<void> parentPreviousPage() async {
    if (_parent?.page == null) return;
    _parent?.position.context.setIgnorePointer(true);
    // await _parent?.animateToPage(
    //   _parent!.page!.toInt() - 1,
    //   duration: kTabScrollDuration,
    //   curve: Curves.ease,
    // );
    _changePage = false;
  }

  bool scrollNotificationNextPage(ScrollNotification notification) {
    // const horizontalDirections = {AxisDirection.right, AxisDirection.left};
    const verticalDirections = {AxisDirection.down, AxisDirection.up};
    final axisDirection = notification.metrics.axisDirection;

    if (verticalDirections.contains(axisDirection)) {
      _setIgnorePointer();
      return false;
    }

    if (notification is ScrollUpdateNotification) _setIgnorePointer();
    if (notification is OverscrollNotification) {
      _changePageDebouncer.cancel();
      final ScrollMetrics metrics = notification.metrics;
      final double pixels = metrics.pixels.roundToDouble();
      final double maxScrollExtent = metrics.maxScrollExtent.roundToDouble();
      final double minScrollExtent = metrics.minScrollExtent;
      if (pixels == minScrollExtent) {
        _changePageDebouncer.call(() => _changePage = true);
        if (!_changePage) return false;
        parentPreviousPage();
      } else if (pixels == maxScrollExtent) {
        _changePageDebouncer.call(() => _changePage = true);
        if (!_changePage) return false;
        parentNextPage();
      }
    }
    return false;
  }

  @override
  void dispose() {
    // removeListener(_setIgnorePointer);
    _changePageDebouncer.cancel();
    _parent?.removeListener(_setIgnorePointer);
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
          debugLabel: parent?.debugLabel == null
              ? null
              : '${parent?.debugLabel}/$subordinateDebugLabel',
          initialScrollOffset: parent?.initialScrollOffset ?? 0,
          keepScrollOffset: parent?.keepScrollOffset ?? true,
        );
  final ScrollController? parent;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) =>
      parent?.createScrollPosition(physics, context, oldPosition) ??
      super.createScrollPosition(physics, context, oldPosition);

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    parent?.attach(position);
  }

  @override
  void detach(ScrollPosition position) {
    parent?.detach(position);
    super.detach(position);
  }

  @override
  void dispose() {
    for (final position in positions) {
      parent?.detach(position);
    }

    super.dispose();
  }

  @override
  void addListener(VoidCallback listener) {
    parent?.addListener(listener);
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    parent?.removeListener(listener);
    super.removeListener(listener);
  }
}
