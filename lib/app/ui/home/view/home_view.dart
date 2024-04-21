import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/home/widgets/home_bottom_overlay.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/library_persistent_header_delegate.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_search_anchor.dart';
import 'package:app_wsrb_jsr/app/utils/category_utils.dart';
import 'package:app_wsrb_jsr/app/utils/value_notifier_list.dart';
import 'package:app_wsrb_jsr/app/utils/subordinate_library_tab_controller.dart';

import 'package:content_library/content_library.dart';

import 'package:app_wsrb_jsr/app/ui/home/destinations/home_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/destinations/library_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/destinations/settings_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_view_flexible_space.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_toggle_buttons.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late final TabController _tabController;
  late final CustomSearchController _searchController;
  late final ScrollController _scrollController;
  late SubordinateLibraryTabController _libraryTabController;
  late final CategoryController _categoryController;
  bool _disableScroll = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 3)
      ..addListener(_tabControllerListener);

    _scrollController = ScrollController();

    _searchController = CustomSearchController();

    _categoryController = context.read<CategoryController>()
      ..addListener(_categoryListener);

    _handleLibraryTabController();
  }

  void _handleLibraryTabController([bool dispose = false]) {
    int length = 1 + _categoryController.categories.length;

    SubordinateLibraryTabController newTabController;

    if (dispose == true) {
      setStateIfMounted(() {
        newTabController = _libraryTabController.copyWithAndDispose(
          length: length,
          vsync: this,
          initialIndex: _libraryTabController.index > length
              ? _libraryTabController.index - 1
              : _libraryTabController.index,
        );
        _libraryTabController = newTabController;
      });
    } else {
      newTabController = SubordinateLibraryTabController(
        vsync: this,
        initialIndex: 0,
        length: length,
      );
      _libraryTabController = newTabController;
    }
  }

  void _tabControllerListener() {
    final ValueNotifierList valueNotifierList =
        context.read<ValueNotifierList>();
    if (valueNotifierList.isNotEmpty) valueNotifierList.clear();
  }

  void _categoryListener() {
    _handleLibraryTabController(true);
  }

  void disableScroll([bool? disable]) {
    setStateIfMounted(() {
      _disableScroll = disable ?? !_disableScroll;
    });
  }

  ScrollPhysics get _mainPhysics {
    if (_disableScroll) return const NeverScrollableScrollPhysics();
    return const AlwaysScrollableScrollPhysics();
  }

  ScrollPhysics get _tabPhysics {
    if (_disableScroll) return const NeverScrollableScrollPhysics();
    return const FixedOverscrollBouncingScrollPhysics();
  }

  Widget _toggleBuilder(BuildContext context, Enum item, int index) {
    return Text(
      item.toString(),
      style: const TextStyle(fontSize: 13),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HiveController hiveController = context.watch<HiveController>();

    final tabBarIcons = List.generate(
      _tabController.length,
      (index) => Builder(
        builder: (context) {
          final tabIndex = HomeScope.of(context).tabController.index;

          final icons = {
            tabIndex == 0 ? MdiIcons.home : MdiIcons.homeOutline,
            tabIndex == 1 ? MdiIcons.library : MdiIcons.libraryOutline,
            tabIndex == 2 ? MdiIcons.cog : MdiIcons.cogOutline,
          };

          return Tab(icon: Icon(icons.elementAt(index)));
        },
      ),
    );

    return HomeScope(
      libraryTabController: _libraryTabController,
      searchController: _searchController,
      enabled: TickerMode.of(context),
      tabController: _tabController,
      child: Builder(builder: (context) {
        final TabController tabController = HomeScope.of(context).tabController;
        Color? dividerColor;
        bool pinned = false;
        bool floating = false;
        Decoration? indicator;
        if (tabController.index == 1) {
          pinned = true;
          dividerColor = Colors.transparent;
          indicator = const BoxDecoration();
          floating = true;
        }

        return Scaffold(
          bottomNavigationBar: const AnimatedSize(
            duration: Duration(milliseconds: 400),
            child: HomeBottomOverlay(),
          ),
          body: ExtendedNestedScrollView(
            controller: _scrollController,
            physics: _mainPhysics,
            onlyOneScrollInBody: true,
            key: const PageStorageKey('ExtendedNestedScrollView'),
            floatHeaderSlivers: false,
            pinnedHeaderSliverHeightBuilder: () {
              if (tabController.index == 0) return 0;
              final height = TabBar(tabs: tabBarIcons).preferredSize.height;
              return height + height + 25;
            },
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                pinned: pinned,
                floating: floating,
                bottom: TabBar(
                  dividerColor: dividerColor,
                  indicator: indicator,
                  controller: _tabController,
                  tabs: tabBarIcons,
                ),
                actions: [
                  if (tabController.index == 1)
                    IconButton(
                      onPressed: () => CategoryUtils().createCategory(context),
                      icon: Icon(MdiIcons.tag),
                    ),
                ],
                automaticallyImplyLeading: false,
                title: const HomeViewFlexibleSpace(),
              ),
              SliverPersistentHeader(
                delegate: LibraryPersistentHeaderDelegate(
                  enable: tabController.index == 1,
                ),
                pinned: true,
                floating: false,
              ),
              SliverAnimatedPaintExtent(
                duration: const Duration(milliseconds: 150),
                child: SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    padding: tabController.index != 0
                        ? EdgeInsets.zero
                        : const EdgeInsets.only(right: 12, top: 8),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeThroughTransitionSwitcher(
                          duration: const Duration(seconds: 1),
                          enableSecondChild: tabController.index != 0,
                          child: CustomToggleButtons(
                            didUpdate: (notifier) {
                              if (hiveController.source != notifier.value) {
                                notifier.value = hiveController.source;
                              }
                            },
                            initialSelected: hiveController.source,
                            padding: const EdgeInsets.only(left: 12),
                            borderRadius: BorderRadius.circular(10),
                            constraints: const BoxConstraints(
                              minWidth: 92,
                              maxWidth: 92,
                              maxHeight: 38,
                              minHeight: 38,
                            ),
                            items: Source.values,
                            itemBuilder: _toggleBuilder,
                            onTap: hiveController.setSource,
                          ),
                        ),
                        FadeThroughTransitionSwitcher(
                          duration: const Duration(seconds: 1),
                          enableSecondChild:
                              hiveController.source == Source.ANROLL ||
                                  tabController.index != 0,
                          child: CustomToggleButtons(
                            didUpdate: (notifier) {
                              if (hiveController.orderBy != notifier.value) {
                                notifier.value = hiveController.orderBy;
                              }
                            },
                            initialSelected: hiveController.orderBy,
                            padding: const EdgeInsets.only(left: 12),
                            borderRadius: BorderRadius.circular(10),
                            constraints: const BoxConstraints(
                              minWidth: 50,
                              maxWidth: 50,
                              maxHeight: 38,
                              minHeight: 38,
                            ),
                            items: OrderBy.values
                                .where(
                                    (element) => element != OrderBy.RELEVANCE)
                                .toList(),
                            itemBuilder: (context, item, index) =>
                                Icon(item.iconData),
                            onTap: hiveController.setOrderBy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: HomeAnchor(
              child: TabBarView(
                physics: _tabPhysics,
                controller: _tabController,
                children: const [
                  HomeDestination(),
                  LibraryDestination(),
                  SettingsDestination(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_tabControllerListener)
      ..dispose();
    _searchController.dispose();
    _categoryController.removeListener(_categoryListener);
    _scrollController.dispose();
    super.dispose();
  }
}

class HomeAnchor extends StatelessWidget {
  final Widget child;
  HomeAnchor({
    required this.child,
  }) : super(key: anchorKey);

  static final GlobalKey anchorKey = GlobalKey();

  static Future<T?> getWidget<T extends Widget>() async {
    Completer<T?> widgetComplete = Completer();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      anchorKey.currentContext?.visitChildElements((element) {
        Element? visitElement;
        while (true) {
          (visitElement ?? element).visitChildElements((element) {
            visitElement = element;
          });
          if (visitElement?.widget is T) {
            widgetComplete.complete(visitElement?.widget as T?);
            break;
          }
        }
      });
    });
    return await widgetComplete.future;
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class HomeScope extends InheritedNotifier<Listenable> {
  HomeScope({
    super.key,
    required super.child,
    required this.enabled,
    required this.tabController,
    required this.searchController,
    required this.libraryTabController,
  }) : super(notifier: Listenable.merge([tabController, searchController]));
  final CustomSearchController searchController;
  final TabController tabController;
  final SubordinateLibraryTabController libraryTabController;
  final bool enabled;

  static HomeScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeScope>();
  }

  static HomeScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeScope>()!;
  }

  @override
  bool updateShouldNotify(HomeScope oldWidget) {
    return enabled != oldWidget.enabled || super.updateShouldNotify(oldWidget);
  }
}
