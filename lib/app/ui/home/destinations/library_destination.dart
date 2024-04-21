import 'package:app_wsrb_jsr/app/ui/shared/widgets/item_content.dart';
import 'package:app_wsrb_jsr/app/utils/subordinate_library_tab_controller.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_wsrb_jsr/app/ui/home/view/home_view.dart';
import 'package:app_wsrb_jsr/app/utils/debouncer.dart';
import 'package:provider/provider.dart';

class LibraryDestination extends StatefulWidget {
  const LibraryDestination({super.key});

  @override
  State<LibraryDestination> createState() => LibraryeDestinationState();
}

class LibraryeDestinationState extends State<LibraryDestination>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  TabController? _homeTabController;

  List<Widget> _children = [];
  late final LibraryController _libraryController;
  late final CategoryController _categoryController;
  SubordinateLibraryTabController? _libraryTabController;

  bool _changePage = false;

  final Debouncer _changePageDebouncer = Debouncer(
    duration: const Duration(milliseconds: 200),
  );

  @override
  void initState() {
    addPostFrameCallback((value) {
      _homeTabController = HomeScope.of(context).tabController;
      _homeTabController?.addListener(_resetIgnorePointerListener);
      _libraryTabController = HomeScope.of(context).libraryTabController;
    });
    _libraryController = context.read<LibraryController>()
      ..addListener(_setChildren);
    _categoryController = context.read<CategoryController>()
      ..addListener(_setChildren);
    _setChildren();
    super.initState();
  }

  void _setChildren() {
    final noCategories = _libraryController
        .noCategories(_categoryController)
        .map((entity) => switch (entity) {
              AnimeEntity data => data.toAnime,
              BookEntity data => data.toBook,
              _ => null,
            })
        .nonNulls
        .toList();

    final List<Widget> newChildrens = [
      buildGridView(noCategories),
      ..._getItens(_libraryController, _categoryController)
          .map((e) => buildGridView(e))
    ];

    final newkeys = newChildrens.map((widget) => widget.key).nonNulls.toList();
    final keys = _children.map((widget) => widget.key).nonNulls.toList();

    customLog(!listEquals(newkeys, keys));
    if (!listEquals(newkeys, keys)) {
      if (mounted) {
        setState(() {
          _children = newChildrens;
        });
        return;
      }
      _children = [
        buildGridView(noCategories),
        ..._getItens(_libraryController, _categoryController)
            .map((e) => buildGridView(e))
      ];
    }
  }

  void _resetIgnorePointerListener() {
    _changePageDebouncer.cancel();
    _changePage = false;
  }

  @override
  void didChangeDependencies() {
    final searchController = HomeScope.of(context).searchController;
    final tabController = HomeScope.of(context).tabController;

    searchController.removeListener(_searchControllerListener);

    if (tabController.index == 1) {
      searchController.addListener(_searchControllerListener);
    }

    super.didChangeDependencies();
  }

  void _searchControllerListener() {}

  void _scrollNotificationNextPage(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) _resetIgnorePointerListener();
    if (notification is! OverscrollNotification || !mounted) return;
    final metrics = notification.metrics;
    final pixels = metrics.pixels.roundToDouble();
    final maxScrollExtent = metrics.maxScrollExtent.roundToDouble();
    if (pixels == 0) {
      _changePageDebouncer.cancel();
      _changePageDebouncer.call(() {
        _changePage = true;
      });
      if (!_changePage) return;
      _libraryTabController
          ?.parentPreviousPage()
          .whenComplete(() => _changePage = false);
    } else if (pixels == maxScrollExtent) {
      _changePageDebouncer.cancel();
      _changePageDebouncer.call(() {
        _changePage = true;
      });
      if (!_changePage) return;
      _libraryTabController
          ?.parentNextPage()
          .whenComplete(() => _changePage = false);
    }
  }

  List<List<Content>> _getItens(LibraryController libraryController,
      CategoryController categoryController) {
    return categoryController.categories
        .map(
          (category) => libraryController.entities
              .where((entity) => switch (entity) {
                    AnimeEntity data => category.ids.contains(data.stringID),
                    BookEntity data => category.ids.contains(data.stringID),
                    _ => false,
                  })
              .map((entity) => switch (entity) {
                    AnimeEntity data => data.toAnime,
                    BookEntity data => data.toBook,
                    _ => null,
                  })
              .nonNulls
              .toList(),
        )
        .toList();
  }

  Widget buildGridView(List<Content> itens) {
    const gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 170,
      childAspectRatio: 1,
      crossAxisSpacing: 8,
      mainAxisSpacing: 10,
      mainAxisExtent: 170,
    );

    return GridView.builder(
      key: ValueKey(itens.toString()),
      itemCount: itens.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      gridDelegate: gridDelegate,
      itemBuilder: (context, index) {
        return ItemContent(
          content: itens[index],
          isLibrary: true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final libraryTabController = HomeScope.of(context).libraryTabController;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        const horizontalDirections = {AxisDirection.right, AxisDirection.left};
        const verticalDirections = {AxisDirection.down, AxisDirection.up};
        final axisDirection = notification.metrics.axisDirection;
        if (horizontalDirections.contains(axisDirection)) {
          _scrollNotificationNextPage(notification);
        } else if (verticalDirections.contains(axisDirection)) {
          _resetIgnorePointerListener();
        }
        return false;
      },
      child: TabBarView(
        physics: const ClampingScrollPhysics(),
        controller: libraryTabController,
        children: _children,
      ),
    );
  }

  @override
  void dispose() {
    _changePageDebouncer.cancel();
    _homeTabController?.removeListener(_resetIgnorePointerListener);
    super.dispose();
  }
}
