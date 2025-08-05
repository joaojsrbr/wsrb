import 'package:app_wsrb_jsr/app/ui/shared/widgets/bottom_menu.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_search_anchor.dart';
import 'package:app_wsrb_jsr/app/utils/subordinate_library_tab_controller.dart';
import 'package:flutter/material.dart';

class HomeScope extends InheritedNotifier<Listenable> {
  HomeScope({
    super.key,

    required this.tabController,
    required this.homeController,
    required this.searchController,
    required this.bottomMenuController,
    required this.keepWatchingScrollController,
    required this.subordinateLibraryTabController,
    required this.bottomSheetAnimationController,
    WidgetBuilder? builder,
    Widget? child,
  }) : super(
         notifier: Listenable.merge([tabController, bottomMenuController]),
         child: Builder(
           builder: builder ?? (context) => child ?? SizedBox.shrink(),
         ),
       );

  final AnimationController bottomSheetAnimationController;
  final BottomMenuController bottomMenuController;
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
        bottomMenuController.isOpen != oldWidget.bottomMenuController.isOpen ||
        subordinateLibraryTabController !=
            oldWidget.subordinateLibraryTabController;
  }
}
