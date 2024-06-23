import 'package:app_wsrb_jsr/app/ui/home/widgets/home_rail_menu.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_search_anchor.dart';
import 'package:app_wsrb_jsr/app/utils/category_utils.dart';
import 'package:app_wsrb_jsr/app/utils/subordinate_library_tab_controller.dart';

import 'package:content_library/content_library.dart';

import 'package:app_wsrb_jsr/app/ui/home/destinations/content_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/destinations/library_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/destinations/settings_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_view_flexible_space.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

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
  late final CategoryController _categoryController;
  late final ValueNotifierList _valueNotifierList;
  late final RailMenuController _railMenuController;
  bool _disableScroll = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 3)
      ..addListener(_tabControllerListener);

    _scrollController = ScrollController();

    _searchController = CustomSearchController();

    _categoryController = context.read<CategoryController>()
      ..addListener(_startTabController);

    _valueNotifierList = context.read<ValueNotifierList>()
      ..addListener(_valueNotifierListListener);

    _railMenuController = RailMenuController();

    _startTabController(false);
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

    if (dispose == true) {
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

  void _tabControllerListener() {
    final ValueNotifierList valueNotifierList =
        context.read<ValueNotifierList>();
    if (valueNotifierList.isNotEmpty) valueNotifierList.clear();
    _searchController.clear();

    final FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus &&
        _searchController.text.trim().isNotEmpty) {
      currentFocus.focusedChild?.unfocus();
    }
  }

  set setScroll(bool enable) {
    if (enable == _disableScroll) return;
    setStateIfMounted(() => _disableScroll = enable);
  }

  ScrollPhysics get _mainPhysics {
    if (_disableScroll) return const NeverScrollableScrollPhysics();
    if (_tabController.index == 1) return const ClampingScrollPhysics();
    return const AlwaysScrollableScrollPhysics();
  }

  ScrollPhysics get _tabPhysics {
    if (_disableScroll) return const NeverScrollableScrollPhysics();
    return const FixedOverscrollBouncingScrollPhysics();
  }

  @override
  Widget build(BuildContext context) {
    final HiveController hiveController = context.watch<HiveController>();

    return HomeScope(
      subordinateLibraryTabController: _subordinateLibraryTabController,
      searchController: _searchController,
      enabled: TickerMode.of(context),
      tabController: _tabController,
      child: Builder(builder: (context) {
        final TabController tabController = HomeScope.of(context).tabController;

        return Scaffold(
          body: ExtendedNestedScrollView(
            onlyOneScrollInBody: true,
            controller: _scrollController,
            physics: _mainPhysics,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              final CategoryController categoryController =
                  context.watch<CategoryController>();

              List<Widget> tabs = [
                const Tab(text: 'Padrão', key: ValueKey('Padrão'))
              ];

              void add(CategoryEntity entity) {
                final tab = GestureDetector(
                  onLongPress: () {
                    CategoryUtils().createCategory(context, entity);
                  },
                  child: Tab(
                    text: entity.title,
                    key: ValueKey(entity.title),
                  ),
                );
                tabs.addIfNoContains(tab);
              }

              categoryController.categories.forEach(add);
              return [
                SliverAppBar(
                  pinned: false,
                  floating: false,
                  bottom: TabBarSwitcher(
                    duration: const Duration(milliseconds: 650),
                    enableSecondChild: identical(tabController.index, 1),
                    tabBar: TabBar(
                      controller: _tabController,
                      tabs: List.generate(
                        _tabController.length,
                        (index) => Builder(
                          builder: (context) {
                            final tabIndex =
                                HomeScope.of(context).tabController.index;

                            final icons = {
                              tabIndex == 0
                                  ? MdiIcons.home
                                  : MdiIcons.homeOutline,
                              tabIndex == 1
                                  ? MdiIcons.library
                                  : MdiIcons.libraryOutline,
                              tabIndex == 2
                                  ? MdiIcons.cog
                                  : MdiIcons.cogOutline,
                            };

                            return Tab(icon: Icon(icons.elementAt(index)));
                          },
                        ),
                      ),
                    ),
                    secondTabBar: TabBar(
                      tabAlignment: TabAlignment.start,
                      controller: _subordinateLibraryTabController,
                      tabs: tabs,
                      isScrollable: true,
                    ),
                  ),
                  actions: [
                    if (identical(tabController.index, 1))
                      IconButton(
                        onPressed: () =>
                            CategoryUtils().createCategory(context),
                        icon: Icon(MdiIcons.tag),
                      ),
                  ],
                  automaticallyImplyLeading: false,
                  title: const HomeViewFlexibleSpace(),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    width: double.infinity,
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
                          _MenuButton(
                            data: Source.list,
                            onTap: hiveController.setSource,
                            enableSecondChild: tabController.index != 0,
                            child: Text(hiveController.source.toString()),
                          ),
                          _MenuButton(
                            data: OrderBy.list,
                            onTap: hiveController.setOrderBy,
                            leadingMenuItem: (data) => Icon(data.iconData),
                            enableSecondChild: Source.disableSourceMenuFilter(
                                  hiveController.source,
                                ) ||
                                tabController.index != 0,
                            child: Text(hiveController.orderBy.toString()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: HomeRailMenu(
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
      }),
    );
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_tabControllerListener)
      ..dispose();
    _railMenuController.dispose();
    _searchController.dispose();
    _categoryController.removeListener(_startTabController);
    _scrollController.dispose();
    _valueNotifierList.removeListener(_valueNotifierListListener);
    super.dispose();
  }
}

class HomeScope extends InheritedNotifier<Listenable> {
  HomeScope({
    super.key,
    required super.child,
    required this.enabled,
    required this.tabController,
    required this.searchController,
    required this.subordinateLibraryTabController,
  }) : super(notifier: Listenable.merge([tabController, searchController]));

  final CustomSearchController searchController;
  final TabController tabController;
  final SubordinateLibraryTabController subordinateLibraryTabController;
  final bool enabled;

  static HomeScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeScope>();
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

class _MenuButton<T> extends StatefulWidget {
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
  State<_MenuButton<T>> createState() => _MenuButtonState<T>();
}

class _MenuButtonState<T> extends State<_MenuButton<T>> {
  final GlobalKey _buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return FadeThroughTransitionSwitcher(
      duration: const Duration(milliseconds: 450),
      enableSecondChild: widget.enableSecondChild,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 4, top: 6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140, maxHeight: 38),
          child: FilledButton(
            key: _buttonKey,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: (widget.data.length == 1)
                ? null
                : () async {
                    final RenderBox? button = _buttonKey.currentContext
                        ?.findRenderObject() as RenderBox?;

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
                        items: widget.data
                            .map((e) => PopupMenuItem(
                                  value: e,
                                  enabled:
                                      widget.enableMenuItem?.call(e) ?? true,
                                  child: ListTile(
                                      leading: widget.leadingMenuItem?.call(e),
                                      title: Text(e.toString())),
                                ))
                            .toList(),
                      );

                      if (result == null) return;

                      widget.onTap?.call(result);
                    }
                  },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
