import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/home/destinations/content_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/destinations/library_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/destinations/settings_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_view_flexible_space.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/keep_watching.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/bottom_menu.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_search_anchor.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/menu_button.dart';
import 'package:app_wsrb_jsr/app/utils/category_utils.dart';
import 'package:app_wsrb_jsr/app/utils/subordinate_library_tab_controller.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  late SubordinateLibraryTabController _subordinateLibraryTabController;
  late final ScrollController _keepWatchingScrollController;
  late final CategoryController _categoryController;
  late final ValueNotifierList _valueNotifierList;
  late final BottomMenuController _bottomMenuController;
  bool _disableScroll = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 3)
      ..addListener(_tabControllerListener);

    _scrollController = ScrollController()
      ..addListener(_scrollControllerListener);

    _keepWatchingScrollController = ScrollController();

    _searchController = CustomSearchController();

    _categoryController = context.read<CategoryController>()
      ..addListener(_startTabController);

    _valueNotifierList = context.read<ValueNotifierList>()
      ..addListener(_valueNotifierListListener);

    _bottomMenuController = BottomMenuController();

    _startTabController(false);
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

    SubordinateLibraryTabController newTabController;

    if (dispose) {
      setStateIfMounted(() {
        newTabController = _subordinateLibraryTabController.copyWithAndDispose(
          length: length,
          vsync: this,
          initialIndex: _subordinateLibraryTabController.index > length - 1
              ? _subordinateLibraryTabController.index - 1
              : _subordinateLibraryTabController.index,
        );
        _subordinateLibraryTabController = newTabController;
      });
    } else {
      newTabController = SubordinateLibraryTabController(
        vsync: this,
        initialIndex: 0,
        length: length,
      );
      _subordinateLibraryTabController = newTabController;
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

  set setScroll(bool enable) {
    if (enable == _disableScroll) return;
    setStateIfMounted(() => _disableScroll = enable);
  }

  ScrollPhysics get _mainPhysics {
    if (_disableScroll) {
      return const NeverScrollableScrollPhysics();
    }
    if (_tabController.index == 1) return const ClampingScrollPhysics();
    return const AlwaysScrollableScrollPhysics();
  }

  ScrollPhysics get _tabPhysics {
    if (_disableScroll) return const NeverScrollableScrollPhysics();
    return const FixedOverscrollBouncingScrollPhysics();
  }

  @override
  Widget build(BuildContext context) {
    final CategoryController categoryController =
        context.watch<CategoryController>();

    final HiveController hiveController = context.watch<HiveController>();

    return HomeScope(
      bottomMenuController: _bottomMenuController,
      keepWatchingScrollController: _keepWatchingScrollController,
      homeController: _scrollController,
      subordinateLibraryTabController: _subordinateLibraryTabController,
      searchController: _searchController,
      enabled: TickerMode.of(context),
      tabController: _tabController,
      child: Builder(
        builder: (context) {
          final TabController tabController =
              HomeScope.of(context).tabController;
          final LibraryService libraryService = context.watch<LibraryService>();

          return Scaffold(
            body: BottomMenu(
              bottomMenuController: _bottomMenuController,
              child: NestedScrollView(
                // onlyOneScrollInBody: true,
                controller: _scrollController,
                physics: _mainPhysics,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      bottom: TabBar(
                        controller: _tabController,
                        dividerColor: (libraryService.notCompleted.isNotEmpty ||
                                    libraryService.completed.isEmpty) &&
                                _tabController.index == 1
                            ? Colors.transparent
                            : null,
                        tabs: [
                          Tab(icon: Icon(MdiIcons.home)),
                          Tab(icon: Icon(MdiIcons.library)),
                          Tab(icon: Icon(MdiIcons.cog)),
                        ],
                      ),
                      actions: [
                        if ([0, 1].contains(tabController.index))
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: IconButton(
                              visualDensity:
                                  const VisualDensity(horizontal: -4),
                              onPressed: () async {
                                if (await PermissionUtils
                                        .manageExternalStorage() &&
                                    context.mounted) {
                                  context.push(RouteName.DOWNLOAD);
                                }
                              },
                              icon: Icon(MdiIcons.downloadBox),
                            ),
                          ),
                        if (identical(tabController.index, 1))
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: IconButton(
                              visualDensity:
                                  const VisualDensity(horizontal: -4),
                              onPressed: () =>
                                  CategoryUtils.createCategory(context),
                              icon: Icon(MdiIcons.tag),
                            ),
                          ),
                      ],
                      automaticallyImplyLeading: false,
                      title: const HomeViewFlexibleSpace(),
                    ),
                    const KeepWatching(),
                    SliverAnimatedPaintExtent(
                      duration: const Duration(milliseconds: 350),
                      child: SliverToBoxAdapter(
                        child: identical(tabController.index, 1)
                            ? TabBar(
                                key: const ValueKey('tab_bar_library'),
                                tabAlignment: TabAlignment.start,
                                controller: _subordinateLibraryTabController,
                                tabs: categoryController.categories.map<Widget>(
                                  (CategoryEntity entity) {
                                    return GestureDetector(
                                      key: ValueKey(entity.title),
                                      onLongPress: () {
                                        CategoryUtils.createCategory(
                                            context, entity);
                                      },
                                      child: Tab(
                                        text: entity.title,
                                      ),
                                    );
                                  },
                                ).toList()
                                  ..insert(
                                    0,
                                    const Tab(
                                      text: 'Padrão',
                                      key: ValueKey('Padrão'),
                                    ),
                                  ),
                                isScrollable: true,
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: _tabController.index == 0 ? 58 : 0,
                                child: ListView(
                                  padding: tabController.index != 0
                                      ? EdgeInsets.zero
                                      : EdgeInsets.only(
                                          right: 12,
                                          top:
                                              _tabController.index == 0 ? 8 : 8,
                                        ),
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    MenuButton(
                                      data: Source.list,
                                      onTap: hiveController.setSource,
                                      enableSecondChild:
                                          tabController.index != 0,
                                      enableMenuItem: (data) =>
                                          !(hiveController.source == data),
                                      child: Text(
                                        hiveController.source.toString(),
                                      ),
                                    ),
                                    MenuButton(
                                      data: OrderBy.list,
                                      onTap: hiveController.setOrderBy,
                                      leadingMenuItem: (data) =>
                                          Icon(data.iconData),
                                      enableSecondChild:
                                          Source.disableSourceMenuFilter(
                                                hiveController.source,
                                              ) ||
                                              tabController.index != 0,
                                      child: Text(
                                        hiveController.orderBy.toString(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  physics: _tabPhysics,
                  controller: _tabController,
                  children: const [
                    ContentDestination(),
                    LibraryDestination(),
                    SettingsDestination(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
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
