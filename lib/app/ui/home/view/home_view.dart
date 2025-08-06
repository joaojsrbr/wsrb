import 'package:app_wsrb_jsr/app/ui/home/destinations/content_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/destinations/history_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/destinations/library_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_sliver_app_bar.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/bottom_menu.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_search_anchor.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/menu_button.dart';
import 'package:app_wsrb_jsr/app/utils/category_helper.dart';
import 'package:app_wsrb_jsr/app/utils/subordinate_library_tab_controller.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nested_scroll_view_plus/nested_scroll_view_plus.dart';
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
  late SubordinateLibraryTabController _subordinateLibraryTabController;
  late final ScrollController _keepWatchingScrollController;
  late final CategoryController _categoryController;
  late final ValueNotifierList _valueNotifierList;
  late final BottomMenuController _bottomMenuController;
  late final AnimationController _bottomSheetAnimationController;

  @override
  void initState() {
    super.initState();
    _bottomSheetAnimationController = BottomSheet.createAnimationController(this);
    _tabController = TabController(vsync: this, length: 3)
      ..addListener(_tabControllerListener);

    _scrollController = ScrollController()..addListener(_scrollControllerListener);

    _keepWatchingScrollController = ScrollController();

    _searchController = CustomSearchController();

    _categoryController = context.read<CategoryController>()
      ..addListener(_startTabController);

    _valueNotifierList = context.read<ValueNotifierList>()
      ..addListener(_valueNotifierListListener);

    _bottomMenuController = BottomMenuController(minHeight: 60, initialArgs: null);

    _startTabController(false);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void _valueNotifierListListener() {
    if (_valueNotifierList.isEmpty) {
      _bottomMenuController.close();
    } else {
      _bottomMenuController.open();
    }
  }

  void _startTabController([bool dispose = true]) {
    int length = 1 + _categoryController.categories.length;

    if (dispose) {
      setState(() {
        _subordinateLibraryTabController = _subordinateLibraryTabController
            .copyWithAndDispose(
              length: length,
              vsync: this,
              initialIndex: _subordinateLibraryTabController.index > length - 1
                  ? _subordinateLibraryTabController.index - 1
                  : _subordinateLibraryTabController.index,
            );
      });
    } else {
      _subordinateLibraryTabController = SubordinateLibraryTabController(
        vsync: this,
        initialIndex: 0,
        length: length,
      );
    }
  }

  void _scrollControllerListener() {
    addPostFrameCallback((timer) {
      if (_scrollController.position.pixels <= 10.0 &&
          _keepWatchingScrollController.hasClients) {
        _keepWatchingScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 450),
          curve: Curves.ease,
        );
      }
    });
  }

  void _tabControllerListener() {
    if (_valueNotifierList.isNotEmpty) _valueNotifierList.clear();
    _searchController.clear();

    addPostFrameCallback((timer) {
      if (mounted) context.unFocusKeyBoard();

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 450),
        curve: Curves.ease,
      );
    });
  }

  ScrollPhysics get _mainPhysics {
    if (_tabController.index == 2) return const BouncingScrollPhysics();
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  ScrollPhysics get _tabPhysics {
    return const FixedOverscrollBouncingScrollPhysics();
  }

  Future<void> _onRefresh() async {
    final contentRepository = context.read<ContentRepository>();
    if (_tabController.index != 0) return;
    await contentRepository.refresh(true);
  }

  List<Widget> _headerSliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    final tabController = HomeScope.of(context).tabController;
    final List<Widget> slivers = [];

    slivers.add(const HomeSliverAppBar());

    if (tabController.index == 0) {
      slivers.add(
        CupertinoSliverRefreshControl(
          refreshTriggerPullDistance: 130,
          onRefresh: _onRefresh,
        ),
      );
    }

    slivers.add(const _HomeButtonMenuSliver());

    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    customLog('$widget[build]');

    return Scaffold(
      body: HomeScope(
        bottomSheetAnimationController: _bottomSheetAnimationController,
        bottomMenuController: _bottomMenuController,
        keepWatchingScrollController: _keepWatchingScrollController,
        homeController: _scrollController,
        subordinateLibraryTabController: _subordinateLibraryTabController,
        searchController: _searchController,
        tabController: _tabController,
        child: BottomMenu(
          isDismissible: false,
          bottomMenuController: _bottomMenuController,
          child: NestedScrollViewPlus(
            overscrollBehavior: OverscrollBehavior.outer,
            controller: _scrollController,
            physics: _mainPhysics,
            headerSliverBuilder: _headerSliverBuilder,
            body: TabBarView(
              physics: _tabPhysics,
              controller: _tabController,
              children: const [
                ContentDestination(),
                HistoryDestination(),
                LibraryDestination(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bottomSheetAnimationController.dispose();
    _tabController
      ..removeListener(_tabControllerListener)
      ..dispose();
    _searchController.dispose();
    _keepWatchingScrollController.dispose();
    _categoryController.removeListener(_startTabController);
    _scrollController
      ..removeListener(_scrollControllerListener)
      ..dispose();
    _valueNotifierList.removeListener(_valueNotifierListListener);
    super.dispose();
  }
}

class _HomeButtonMenuSliver extends StatelessWidget {
  const _HomeButtonMenuSliver();

  @override
  Widget build(BuildContext context) {
    final HomeScope scope = HomeScope.of(context);
    final TabController tabController = scope.tabController;
    final SubordinateLibraryTabController subordinateLibraryTabController =
        scope.subordinateLibraryTabController;
    final CategoryController categoryController = context.watch<CategoryController>();
    final AppConfigController appConfigController = context.watch<AppConfigController>();
    return SliverAnimatedPaintExtent(
      duration: const Duration(milliseconds: 350),
      child: SliverToBoxAdapter(
        child: Visibility(
          maintainState: false,
          visible: identical(tabController.index, 2),
          replacement: SizedBox(
            width: double.infinity,
            height: tabController.index == 0 ? 58 : 0,
            child: ListView(
              padding: tabController.index != 0
                  ? EdgeInsets.zero
                  : EdgeInsets.only(right: 12, top: 12),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: [
                DropdownMenuButton<Source>(
                  onSelected: appConfigController.setSource,

                  items: Source.list,

                  enableSecondChild: tabController.index != 0,
                  itemEnabled: (data) => !(appConfigController.config.source == data),
                  child: Text(
                    appConfigController.config.source.toString(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),

                // ! menu de tipo de anime
                // MenuButton(
                //   data: OrderBy.list,
                //   onTap: hiveController.setOrderBy,
                //   leadingMenuItem: (data) =>
                //       Icon(data.iconData),
                //   enableSecondChild:
                //       Source.disableSourceMenuFilter(
                //             hiveController.source,
                //           ) ||
                //           tabController.index != 0,
                //   child: Text(
                //     hiveController.orderBy.toString(),
                //   ),
                // ),
              ],
            ),
          ),
          child: TabBar(
            tabAlignment: TabAlignment.start,
            controller: subordinateLibraryTabController,
            tabs: categoryController.categories.map<Widget>((CategoryEntity entity) {
              return GestureDetector(
                onLongPress: () => CategoryHelper.openCategoryCreator(context, entity),
                child: Tab(text: entity.title),
              );
            }).toList()..insert(0, const Tab(text: 'Padrão')),
            isScrollable: true,
          ),
        ),
      ),
    );
  }
}
