import '../../shared/widgets/custom_search_anchor.dart';
import '../../../utils/subordinate_library_tab_controller.dart';
import 'package:flutter/material.dart';

class HomeScope extends InheritedNotifier<Listenable> {
  HomeScope({
    super.key,
    required this.tabController,
    required this.homeController,
    required this.searchController,
    required this.keepWatchingScrollController,
    required this.subordinateLibraryTabController,
    required this.bottomSheetAnimationController,
    WidgetBuilder? builder,
    Widget? child,
  }) : super(
         notifier: Listenable.merge([tabController]),
         child: Builder(builder: builder ?? (context) => child ?? const SizedBox.shrink()),
       );

  final AnimationController bottomSheetAnimationController;
  final CustomSearchController searchController;
  final TabController tabController;
  final ScrollController homeController;
  final SubordinateLibraryTabController subordinateLibraryTabController;
  final ScrollController keepWatchingScrollController;

  static HomeScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeScope>();
  }

  static HomeScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeScope>()!;
  }

  @override
  bool updateShouldNotify(HomeScope oldWidget) {
    return tabController.index != oldWidget.tabController.index ||
        subordinateLibraryTabController != oldWidget.subordinateLibraryTabController;
  }
}
