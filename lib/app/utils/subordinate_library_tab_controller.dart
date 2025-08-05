import 'package:flutter/material.dart';

class SubordinateLibraryTabController extends TabController {
  SubordinateLibraryTabController({
    required super.vsync,
    required super.length,
    super.initialIndex,
    PageController? parentPageController,
  }) {
    _parent = parentPageController;
    _parent?.addListener(_pageListener);
  }

  PageController? _parent;

  /// Atualiza o PageController pai (chamar no initState se mudar dinamicamente)
  void setParentController(PageController? controller) {
    _parent?.removeListener(_pageListener);
    _parent = controller;
    _parent?.addListener(_pageListener);
  }

  void _pageListener() {
    // Aqui você pode responder ao scroll da PageView
    // customLog('Page position: ${_parent?.page}');
    _setIgnorePointer(false);
  }

  void _setIgnorePointer([bool value = false]) {
    _parent?.position.context.setIgnorePointer(value);
  }

  bool handleScrollNotification(ScrollNotification notification) {
    const verticalDirections = {AxisDirection.down, AxisDirection.up};
    final axisDirection = notification.metrics.axisDirection;

    if (verticalDirections.contains(axisDirection)) {
      _setIgnorePointer(false);
      return false;
    }

    switch (notification) {
      case ScrollUpdateNotification():
        _setIgnorePointer(false);
        break;
      case OverscrollNotification():
        final metrics = notification.metrics;
        final pixels = metrics.pixels.roundToDouble();
        final maxScrollExtent = metrics.maxScrollExtent.roundToDouble();
        final minScrollExtent = metrics.minScrollExtent.roundToDouble();

        if (pixels == minScrollExtent || pixels == maxScrollExtent) {
          _setIgnorePointer(true);
        }
        break;
    }

    return false;
  }

  @override
  void dispose() {
    _parent?.removeListener(_pageListener);
    super.dispose();
  }

  /// Cria uma nova instância com estado preservado e descarta a atual
  SubordinateLibraryTabController copyWithAndDispose({required TickerProvider vsync, int? length, int? initialIndex}) {
    final newController = SubordinateLibraryTabController(
      vsync: vsync,
      length: length ?? this.length,
      initialIndex: initialIndex ?? index,
      parentPageController: _parent,
    );
    dispose();
    return newController;
  }
}

class SubordinateScrollController extends ScrollController {
  SubordinateScrollController(this._parent, {String? subordinateDebugLabel})
    : super(
        initialScrollOffset: _parent.initialScrollOffset,
        keepScrollOffset: _parent.keepScrollOffset,
        debugLabel: subordinateDebugLabel != null ? '${_parent.debugLabel}/$subordinateDebugLabel' : _parent.debugLabel,
      );

  final ScrollController _parent;

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    if (!_parent.positions.contains(position)) {
      _parent.attach(position);
    }
  }

  @override
  void detach(ScrollPosition position) {
    if (_parent.positions.contains(position)) {
      _parent.detach(position);
    }
    super.detach(position);
  }

  @override
  void dispose() {
    // Importante: não chamamos parent.dispose() aqui.
    super.dispose();
  }

  @override
  void addListener(VoidCallback listener) {
    _parent.addListener(listener);
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _parent.removeListener(listener);
    super.removeListener(listener);
  }
}
