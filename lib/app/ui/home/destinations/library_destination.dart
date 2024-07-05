// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/home/widgets/home_rail_menu.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_wsrb_jsr/app/ui/shared/widgets/item_content.dart';
import 'package:app_wsrb_jsr/app/utils/subordinate_library_tab_controller.dart';

class LibraryDestination extends StatefulWidget {
  const LibraryDestination({super.key});

  @override
  State<LibraryDestination> createState() => LibraryeDestinationState();
}

class LibraryeDestinationState extends State<LibraryDestination>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<Widget> _children = [];
  final Debouncer _debouncer = Debouncer(
    duration: const Duration(milliseconds: 200),
  );

  List<List<Content>> _contents = [];
  int? _initialIndex;

  late final LibraryController _libraryController;
  late final LibraryService _libraryService;
  late final CategoryController _categoryController;

  @override
  void initState() {
    super.initState();

    _libraryController = context.read<LibraryController>()
      ..addListener(_setChildren);

    _libraryService = LibraryService(_libraryController);

    _categoryController = context.read<CategoryController>()
      ..addListener(_setChildren);

    scheduleMicrotask(() {
      final libraryTabController =
          HomeScope.of(context).subordinateLibraryTabController;

      libraryTabController.setParent =
          context.findAncestorWidgetOfExactType<PageView>()?.controller;
    });

    _setChildren();
  }

  void _setChildren() {
    // addPostFrameCallback((timer) {
    //   final SubordinateLibraryTabController subordinateLibraryTabController =
    //       HomeScope.of(context).subordinateLibraryTabController;
    //   subordinateLibraryTabController.setChangePage = false;
    // });

    final noCategories = _libraryService
        .byCategories(_categoryController, true)
        .getContent
        .toList();

    final yesCategories = _libraryService.entities
        .categoryByID(context)
        .map((e) => e.getContent.toList())
        .toList();

    _contents = [noCategories, ...yesCategories];

    final List<Widget> newChildrens = [
      buildGridView(noCategories, 0),
      ...yesCategories.mapIndexed((index, e) => buildGridView(e, index))
    ];

    _children
      ..clear()
      ..addAll(newChildrens);
    setStateIfMounted(() {});
  }

  @override
  void didChangeDependencies() {
    // _setChildren();
    final searchController = HomeScope.of(context).searchController;
    final tabController = HomeScope.of(context).tabController;

    searchController.removeListener(_searchControllerListener);

    if (tabController.index == 1) {
      searchController.addListener(_searchControllerListener);
    }

    super.didChangeDependencies();
  }

  void _searchControllerListener() async {
    final searchController = HomeScope.of(context).searchController;
    final String text = searchController.text.toLowerCase().trim();

    final SubordinateLibraryTabController subordinateLibraryTabController =
        HomeScope.of(context).subordinateLibraryTabController;
    if (text.isEmpty) {
      _debouncer.call(
          () => subordinateLibraryTabController.animateTo(_initialIndex!));
      return;
    }

    _initialIndex ??= subordinateLibraryTabController.index;

    final index = _contents.indexWhere((list) =>
        list.any((content) => content.title.toLowerCase().contains(text)));

    if (index != -1 && index != subordinateLibraryTabController.index) {
      _debouncer.call(() => subordinateLibraryTabController.animateTo(index));
    }
  }

  Widget buildGridView(List<Content> items, int index) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Builder(builder: (context) {
      final RailMenuController railMenuController =
          HomeRailMenu.menuControllerOf(context);

      // final RailMenuController railMenuController =
      //     HomeRailMenu.menuControllerOf(context);
      const gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
        // maxCrossAxisExtent: 170,
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 10,
        // mainAxisExtent: 170,
      );

      final searchController = HomeScope.of(context).searchController;

      final filter = items.where((content) => content.title
          .toLowerCase()
          .trim()
          .contains(searchController.text.toLowerCase().trim()));

      return AnimatedPadding(
        duration: const Duration(milliseconds: 350),
        padding: EdgeInsets.only(right: railMenuController.isOpen ? 50 : 0),
        child: GridView.builder(
          itemCount: filter.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.only(left: 8, right: 8, top: 12),
          gridDelegate: gridDelegate,
          itemBuilder: (context, index) {
            return ItemContent(
              content: filter.elementAt(index),
              isLibrary: true,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // if (kDebugMode) {
    // }
    // _setChildren();

    final SubordinateLibraryTabController subordinateLibraryTabController =
        HomeScope.of(context).subordinateLibraryTabController;

    return NotificationListener<ScrollNotification>(
      onNotification:
          subordinateLibraryTabController.scrollNotificationNextPage,
      child: TabBarView(
        physics: const ClampingScrollPhysics(),
        controller: subordinateLibraryTabController,
        children: _children,
      ),
    );
  }

  @override
  void dispose() {
    _libraryController.removeListener(_setChildren);
    _categoryController.removeListener(_setChildren);
    _debouncer.cancel();
    super.dispose();
  }
}
