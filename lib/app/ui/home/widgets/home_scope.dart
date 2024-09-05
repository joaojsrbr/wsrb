import 'package:app_wsrb_jsr/app/ui/shared/widgets/bottom_menu.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_search_anchor.dart';
import 'package:app_wsrb_jsr/app/utils/subordinate_library_tab_controller.dart';
import 'package:flutter/material.dart';

class HomeScope extends InheritedNotifier<Listenable> {
  HomeScope({
    required super.child,
    required this.enabled,
    required this.tabController,
    required this.homeController,
    required this.searchController,
    required this.bottomMenuController,
    required this.keepWatchingScrollController,
    required this.subordinateLibraryTabController,
  }) : super(
          notifier: Listenable.merge(
            [
              tabController,
              searchController,
              bottomMenuController,
            ],
          ),
          key: _homeScopeKey,
        );

  static final GlobalKey _homeScopeKey = GlobalKey();
  final BottomMenuController bottomMenuController;
  final CustomSearchController searchController;
  final TabController tabController;
  final ScrollController homeController;
  final SubordinateLibraryTabController subordinateLibraryTabController;
  final bool enabled;
  final ScrollController keepWatchingScrollController;

  static HomeScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeScope>();
  }

  static HomeScope? byKeyMaybeOf() {
    return _homeScopeKey.currentWidget as HomeScope?;
  }

  static HomeScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeScope>()!;
  }

  @override
  bool updateShouldNotify(HomeScope oldWidget) {
    return enabled != oldWidget.enabled ||
        tabController.index != oldWidget.tabController.index ||
        searchController.value != oldWidget.searchController.value ||
        subordinateLibraryTabController !=
            oldWidget.subordinateLibraryTabController;
  }
}
