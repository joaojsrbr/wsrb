import 'dart:async';

import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/home/destinations/content_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/destinations/library_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/destinations/settings_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_view_flexible_space.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/keep_watching.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_search_anchor.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/rail_menu.dart';
import 'package:app_wsrb_jsr/app/utils/category_utils.dart';
import 'package:app_wsrb_jsr/app/utils/subordinate_library_tab_controller.dart';
import 'package:content_library/content_library.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with TickerProviderStateMixin, RestorationMixin {
  late final TabController _tabController;
  late final CustomSearchController _searchController;
  late final ScrollController _scrollController;
  // late final ConnectionChecker _connectionChecker;
  late SubordinateLibraryTabController _subordinateLibraryTabController;
  late final ScrollController _keepWatchingScrollController;
  late final CategoryController _categoryController;
  late final ValueNotifierList _valueNotifierList;
  late final RailMenuController _railMenuController;
  bool _disableScroll = false;

  @override
  String? get restorationId => 'home';

  // late RestorableRouteFuture<int> _counterRoute;
  final RestorableInt _homeTabControllerIndex = RestorableInt(0);
  final RestorableDouble _homeScrollControllerPosition = RestorableDouble(0.0);

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    // registerForRestoration(_counterRoute, 'route');
    registerForRestoration(
      _homeTabControllerIndex,
      'home_tab_controller_index',
    );
    registerForRestoration(
      _homeScrollControllerPosition,
      'home_scroll_controller_position',
    );
  }

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

    _railMenuController = RailMenuController();

    // _connectionChecker = context.read<ConnectionChecker>();

    _startTabController(false);

    scheduleMicrotask(() {
      addPostFrameCallback((timer) {
        _tabController.animateTo(
          _homeTabControllerIndex.value,
          duration: Duration.zero,
        );
        _scrollController.jumpTo(
          _homeScrollControllerPosition.value,
        );
      });
    });
  }

  void _valueNotifierListListener() {
    if (_valueNotifierList.isEmpty) {
      _railMenuController.close();
    } else {
      _railMenuController.open();
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
    _homeScrollControllerPosition.value = _scrollController.position.pixels;
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
    _homeTabControllerIndex.value = _tabController.index;
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
      railMenuController: _railMenuController,
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

          return Scaffold(
            body: ExtendedNestedScrollView(
              onlyOneScrollInBody: true,
              controller: _scrollController,
              physics: _mainPhysics,
              restorationId: 'home_scroll',
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    pinned: false,
                    primary: true,
                    floating: false,
                    bottom: TabBar(
                      controller: _tabController,
                      dividerColor:
                          _tabController.index == 1 ? Colors.transparent : null,
                      tabs: List.generate(
                        _tabController.length,
                        (index) => Builder(
                          builder: (context) {
                            final icons = {
                              _tabController.index == 0
                                  ? MdiIcons.home
                                  : MdiIcons.homeOutline,
                              _tabController.index == 1
                                  ? MdiIcons.library
                                  : MdiIcons.libraryOutline,
                              _tabController.index == 2
                                  ? MdiIcons.cog
                                  : MdiIcons.cogOutline,
                            };

                            return Tab(
                              icon: Icon(icons.elementAt(index)),
                            );
                          },
                        ),
                      ),
                    ),
                    actions: [
                      if ([0, 1].contains(tabController.index))
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: IconButton(
                            visualDensity: const VisualDensity(horizontal: -4),
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
                            visualDensity: const VisualDensity(horizontal: -4),
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
                  SliverToBoxAdapter(
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 350),
                      child: _tabController.index == 1
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
                              key: const ValueKey('menu_buttom_home'),
                              width: double.infinity,
                              height: _tabController.index == 0 ? 58 : 0,
                              child: ListView(
                                padding: tabController.index != 0
                                    ? EdgeInsets.zero
                                    : EdgeInsets.only(
                                        right: 12,
                                        top: _tabController.index == 0 ? 8 : 8,
                                      ),
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                cacheExtent: 300,
                                children: [
                                  _MenuButton(
                                    data: Source.list,
                                    onTap: hiveController.setSource,
                                    enableSecondChild: tabController.index != 0,
                                    enableMenuItem: (data) =>
                                        !(hiveController.source == data),
                                    child:
                                        Text(hiveController.source.toString()),
                                  ),
                                  _MenuButton(
                                    data: OrderBy.list,
                                    onTap: hiveController.setOrderBy,
                                    leadingMenuItem: (data) =>
                                        Icon(data.iconData),
                                    enableSecondChild:
                                        Source.disableSourceMenuFilter(
                                              hiveController.source,
                                            ) ||
                                            tabController.index != 0,
                                    child:
                                        Text(hiveController.orderBy.toString()),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ];
              },
              body: RailMenu(
                railMenuController: _railMenuController,
                child: TabBarView(
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

class _MenuButton<T> extends StatelessWidget {
  final void Function(T data)? onTap;
  final Widget? child;
  final bool enableSecondChild;
  final List<T> data;
  final bool Function(T data)? enableMenuItem;
  final Widget Function(T data)? leadingMenuItem;

  const _MenuButton({
    required this.onTap,
    required this.child,
    this.enableMenuItem,
    this.leadingMenuItem,
    this.enableSecondChild = false,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return FadeThroughTransitionSwitcher(
      duration: const Duration(milliseconds: 350),
      enableSecondChild: enableSecondChild,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 4),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140, maxHeight: 38),
          child: Builder(builder: (context) {
            return FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: (data.length == 1)
                  ? null
                  : () async {
                      final RenderBox? button =
                          context.findRenderObject() as RenderBox?;

                      final RenderBox? overlay = Navigator.of(context)
                          .overlay
                          ?.context
                          .findRenderObject() as RenderBox?;
                      if (overlay != null && button != null) {
                        final size = button.size;

                        final RelativeRect position = RelativeRect.fromRect(
                          Rect.fromPoints(
                            button.localToGlobal(size.bottomLeft(Offset.zero)),
                            button.localToGlobal(size.bottomLeft(Offset.zero)),
                          ),
                          Offset(size.width > 100 ? -5 : size.width, -5) &
                              overlay.size,
                        );

                        final result = await showMenu(
                          context: context,
                          position: position,
                          clipBehavior: Clip.hardEdge,
                          items: data
                              .map(
                                (e) => PopupMenuItem(
                                  value: e,
                                  enabled: enableMenuItem?.call(e) ?? true,
                                  child: ListTile(
                                    leading: leadingMenuItem?.call(e),
                                    title: Text(
                                      e.toString(),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        );

                        if (result == null) return;

                        onTap?.call(result);
                      }
                    },
              child: child,
            );
          }),
        ),
      ),
    );
  }
}
