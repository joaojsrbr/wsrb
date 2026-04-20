import 'package:content_library/content_library.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../routes/routes.dart';
import '../../../utils/category_helper.dart';
import '../../../utils/dual.dart';
import '../../../utils/subordinate_library_tab_controller.dart';
import '../../shared/mixins/subscriptions.dart';
import '../../shared/widgets/custom_search_anchor.dart';
import '../../shared/widgets/global_overlay.dart';
import '../../shared/widgets/highlight.dart';
import '../../shared/widgets/menu_button.dart';
import '../destinations/content_destination.dart';
import '../destinations/history_destination.dart';
import '../destinations/library_destination.dart';
import '../widgets/home_scope.dart';
import '../widgets/home_sliver_app_bar.dart';
import '../widgets/library_buttons.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with TickerProviderStateMixin, SubscriptionsMixin, WidgetsBindingObserver {
  late final TabController _tabController;
  late final CustomSearchController _searchController;
  late final ScrollController _scrollController;
  late SubordinateLibraryTabController _subordinateLibraryTabController;
  late final ScrollController _keepWatchingScrollController;
  late final CategoryController _categoryController;
  late final ValueNotifierList _valueNotifierList;
  late final ValueNotifier<double> _progressNotifier;
  late final AnimationController _bottomSheetAnimationController;
  late final HighlightController<String> _highlightController;

  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _progressNotifier = ValueNotifier<double>(0.0);
    _highlightController = HighlightController();
    _bottomSheetAnimationController = BottomSheet.createAnimationController(
      this,
    );
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
    _startTabController(false);
    subscriptions.addAll([
      ReleaseUpdateService.progressStream.listen(_releaseProgressListener),
    ]);
    WidgetsBinding.instance.addObserver(this);
  }

  void _releaseProgressListener(ProgressMessage data) {
    _isCompleted = data.completed;
    _progressNotifier.value = data.percent;
    final path = GoRouter.of(context).state.path;

    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    if (context.mounted &&
        !data.completed &&
        lifecycleState == AppLifecycleState.resumed &&
        !context.hasNotification() &&
        path == RouteName.HOME.route) {
      context.showProgressNotification(
        "Atualizando a biblioteca...",
        progress: _progressNotifier,
        height: 81,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        position: NotificationPosition.top,
      );
    } else if (context.hasNotification()) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          context.closeNotification();
          _progressNotifier.value = 0.0;
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.resumed:
        if (_isCompleted && context.hasNotification())
          context.closeNotification();
      case AppLifecycleState.detached:
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void _valueNotifierListListener() {
    if (_valueNotifierList.isEmpty) {
      context.closeNotification();
    } else if (!context.hasNotification()) {
      final size = MediaQuery.sizeOf(context);
      final height = size.height * .08;

      context.showBottomNotification(
        LibraryButtons(
          context: context,
          tabController: _tabController,
          onAdd: () {
            context.showSuccessNotification(
              "${_valueNotifierList.isEmpty ? "Item" : "Itens"} adicionados com sucesso.",
            );
          },
        ),
        height: height,
        // duration: const Duration(seconds: 20),
        persistent: true,
        showCountdown: false,
        // duration: const Duration(minutes: 10),
        // height: 52 + 24,
      );
    } else {
      context.maintainOverlap(duration: const Duration(seconds: 20));
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

  // ScrollPhysics get _mainPhysics {
  //   if (_tabController.index == 2) return const BouncingScrollPhysics();
  //   return const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());
  // }

  List<Widget> _headerSliverBuilder(
    BuildContext context,
    bool innerBoxIsScrolled,
  ) {
    // final tabController = HomeScope.of(context).tabController;
    final List<Widget> slivers = [];

    slivers.add(const HomeSliverAppBar());

    // if (tabController.index == 0) {
    //   slivers.add(
    //     CupertinoSliverRefreshControl(
    //       refreshTriggerPullDistance: 130,
    //       onRefresh: _onRefresh,
    //     ),
    //   );
    // }

    slivers.add(const _HomeButtonMenuSliver());

    return slivers;
  }

  Future<void> _onRefresh() async {
    final contentRepository = context.read<ContentRepository>();
    switch (_tabController.index) {
      case 0:
        await contentRepository.refresh(true);
      case 2:
        await Workmanager().registerOneOffTask(
          UniqueKey().toString(),
          App.APP_WORK_NEW_RELEASE,
          tag: App.APP_WORK_NEW_RELEASE,
          existingWorkPolicy: ExistingWorkPolicy.replace,
          constraints: Constraints(
            networkType: NetworkType.connected,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false,
          ),
        );
    }
  }

  static const _mainPhysics = Dual(
    BouncingScrollPhysics(),
    AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
  );

  static const _tabPhysics = Dual(PageScrollPhysics(), PageScrollPhysics());

  bool _notificationPredicate(ScrollNotification notification) {
    return {0, 1, 2}.contains(notification.depth) &&
        {0, 2}.contains(_tabController.index);
  }

  @override
  Widget build(BuildContext context) {
    final contentRepository = context.read<ContentRepository>();
    // final test = const GlobalObjectKey("a");
    // test.currentContext;
    return CustomHighlight(
      controller: _highlightController,
      child: Scaffold(
        key: contentRepository.anchor,
        floatingActionButton: kDebugMode
            ? FloatingActionButton(
                onPressed: () async {
                  // _highlightController.isActive(
                  //   "64e0b8f3-71cd-504e-bd16-8a653cc523f4",
                  // );
                  _highlightController.toggle(
                    "64e0b8f3-71cd-504e-bd16-8a653cc523f4",
                  );
                  // await Workmanager().cancelByTag(App.APP_WORK_NEW_RELEASE);
                  // await Workmanager().registerOneOffTask(
                  //   UniqueKey().toString(),
                  //   App.APP_WORK_NEW_RELEASE,
                  //   tag: App.APP_WORK_NEW_RELEASE,
                  //   existingWorkPolicy: ExistingWorkPolicy.replace,
                  //   constraints: Constraints(networkType: NetworkType.connected),
                  // );

                  // final LibraryController libraryController = context.read();
                  // final repo = libraryController.repo;
                  // final data = repo.favorites.first;

                  // await NotificationService.I.show(
                  //   id: data.stringID.hashCode,
                  //   title: "Novo episódio disponível!",
                  //   body: "${data.title} lançou o episódio ${10}",
                  //   payload: "contentInfo/${data.stringID}",
                  // );

                  // context.showTopNotification(Text("test"), overlay: true);
                  // context.showCancelableNotification(
                  //   "test",
                  //   position: NotificationPosition.bottom,
                  // );
                  // context.closeByType(NotificationType.error);
                  // context.showErrorNotification(
                  //   DioException(requestOptions: RequestOptions()).toString(),
                  // );
                  // context.showErrorNotification(
                  //   DioException(requestOptions: RequestOptions()).toString(),
                  // );
                  // context.showSuccessNotification(
                  //   DioException(requestOptions: RequestOptions()).toString(),
                  // );
                  // context.showSuccessNotification("test");

                  // context.showSuccessNotification(
                  //   "${_valueNotifierList.isEmpty ? "Item" : "Itens"} adicionados com sucesso.",
                  // );
                },
              )
            : null,
        body: HomeScope(
          bottomSheetAnimationController: _bottomSheetAnimationController,
          keepWatchingScrollController: _keepWatchingScrollController,
          homeController: _scrollController,
          subordinateLibraryTabController: _subordinateLibraryTabController,
          searchController: _searchController,
          tabController: _tabController,
          child: ExtendedNestedScrollView(
            // overscrollBehavior: OverscrollBehavior.outer,
            onlyOneScrollInBody: true,
            controller: _scrollController,
            physics: _mainPhysics.pick(_tabController.index == 2),
            headerSliverBuilder: _headerSliverBuilder,
            body: RefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              notificationPredicate: _notificationPredicate,
              onRefresh: _onRefresh,
              child: TabBarView(
                physics: _tabPhysics.first,
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
      ),
    );
  }

  @override
  void dispose() {
    ReleaseUpdateService.removePortNameMapping();
    _progressNotifier.dispose();
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
    WidgetsBinding.instance.removeObserver(this);

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
    final CategoryController categoryController = context
        .watch<CategoryController>();
    final AppConfigController appConfigController = context
        .watch<AppConfigController>();
    // final popupKey = GlobalKey<pop.CustomPopupState>();

    return SliverAnimatedPaintExtent(
      duration: const Duration(milliseconds: 200),
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
                  : const EdgeInsets.only(right: 12, top: 12),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: [
                DropdownMenuButton<Source>(
                  onSelected: appConfigController.setSource,
                  items: Source.values,
                  enableSecondChild: tabController.index != 0,
                  itemEnabled: (data) =>
                      !(appConfigController.config.source == data),
                  child: Text(
                    appConfigController.config.source.toString(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
                // pop.CustomPopup(
                //   key: popupKey,
                //   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                //   contentPadding: EdgeInsets.zero,
                //   content: Column(
                //     mainAxisSize: MainAxisSize.min,
                //     spacing: 8,
                //     children: List.generate(
                //       Source.list.length,
                //       (index) => SizedBox(
                //         width: 160,
                //         child: ListTile(
                //           contentPadding: EdgeInsets.zero,
                //           horizontalTitleGap: 0,
                //           title: Text(Source.list.elementAt(index).label),
                //           onTap: () {
                //             final context = popupKey.currentContext;
                //             if (context != null) {
                //               Navigator.pop(context);
                //             }
                //             // appConfigController.setSource(Source.list.elementAt(index));
                //           },
                //         ),
                //       ),
                //     ),
                //   ),
                //   child: Icon(Icons.help),
                // ),
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
          child: TabBar.secondary(
            tabAlignment: TabAlignment.start,
            controller: subordinateLibraryTabController,
            tabs: categoryController.categories.map<Widget>((
              CategoryEntity entity,
            ) {
              return GestureDetector(
                onLongPress: () =>
                    CategoryHelper.openCategoryCreator(context, entity),
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
