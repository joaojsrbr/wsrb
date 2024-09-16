// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/item_content.dart';
import 'package:app_wsrb_jsr/app/utils/subordinate_library_tab_controller.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
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

  List<Widget> _children = [];
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

    _libraryService = LibraryService(_libraryController, context.read());

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
      buildGridView(noCategories),
      ...yesCategories.mapIndexed((index, e) => buildGridView(e))
    ];

    // customLog(noCategories.length);

    setStateIfMounted(() {
      _children = newChildrens;
    });
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

  Widget buildGridView(List<Content> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Builder(builder: (context) {
      const gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
        // maxCrossAxisExtent: 170,
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 260,
      );

      final searchController = HomeScope.of(context).searchController;

      final filter = searchController.text.isNotEmpty
          ? items.where((content) => content.title
              .toLowerCase()
              .trim()
              .contains(searchController.text.toLowerCase().trim()))
          : items;

      return GridView.builder(
        itemCount: filter.length,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: gridDelegate,
        padding: const EdgeInsets.only(
          bottom: 40,
          left: 8,
          right: 8,
          top: 12,
        ),
        itemBuilder: (context, index) {
          return ItemContent.library(
            content: filter.elementAt(index),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _setChildren();

    final SubordinateLibraryTabController subordinateLibraryTabController =
        HomeScope.of(context).subordinateLibraryTabController;

    return NotificationListener<ScrollNotification>(
      onNotification:
          subordinateLibraryTabController.scrollNotificationNextPage,
      child: TabBarView(
        key: const PageStorageKey('library_page'),
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
