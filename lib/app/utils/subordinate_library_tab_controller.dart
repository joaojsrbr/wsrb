// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:app_wsrb_jsr/app/ui/home/view/home_view.dart';
import 'package:app_wsrb_jsr/app/utils/debouncer.dart';

class SubordinateLibraryTabController extends TabController {
  SubordinateLibraryTabController({
    this.currentIndex = 1,
    required super.vsync,
    super.initialIndex,
    required super.length,
  }) {
    final pageview = HomeAnchor.getWidget<PageView>();
    pageview.then((pageview) {
      parent = pageview?.controller;
      parent?.addListener(_setIgnorePointer);
    });
  }

  final int currentIndex;

  final Debouncer _changePageDebouncer = Debouncer(
    duration: const Duration(milliseconds: 200),
  );

  PageController? parent;

  void _setIgnorePointer() {
    if (parent?.page == null) return;
    final parentPage = parent!.page!;
    final nextPage = parentPage + 1;
    final previousPage = parentPage - 1;

    if (parentPage.toInt() == nextPage.toInt() ||
        parentPage.toInt() == previousPage.toInt()) {
      _changePageDebouncer.cancel();
      // _changePage = false;
    }

    if (parentPage < nextPage && parentPage >= currentIndex) {
      parent?.position.context.setIgnorePointer(false);
    } else if (currentIndex != 0 &&
        parentPage > 0.8 &&
        parentPage < currentIndex) {
      parent?.position.context.setIgnorePointer(false);
    }
  }

  Future<void> parentNextPage() async {
    if (parent?.page == null) return;
    await parent?.animateToPage(
      parent!.page!.toInt() + 1,
      duration: kTabScrollDuration,
      curve: Curves.ease,
    );
  }

  Future<void> parentPreviousPage() async {
    if (parent?.page == null) return;
    await parent?.animateToPage(
      parent!.page!.toInt() - 1,
      duration: kTabScrollDuration,
      curve: Curves.ease,
    );
  }

  // void _nextPage() async {
  //   if (offset.round() == position.maxScrollExtent.round()) {
  //     _changePageDebouncer.call(() {
  //       _changePage = true;
  //     });
  //     if (!_changePage) return;
  //     await parentNextPage();
  //   } else if (offset.round() == position.minScrollExtent.round() &&
  //       parent?.page != 0) {
  //     _changePageDebouncer.call(() {
  //       _changePage = true;
  //     });
  //     if (!_changePage) return;
  //     await parentPreviousPage();
  //   } else {
  //     _changePageDebouncer.cancel();
  //     _changePage = false;
  //   }
  // }

  @override
  void dispose() {
    _changePageDebouncer.cancel();
    parent?.removeListener(_setIgnorePointer);
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
      currentIndex: currentIndex ?? this.currentIndex,
    );

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
