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

  final Debouncer _debouncer = Debouncer(
    duration: const Duration(milliseconds: 200),
  );

  List<List<Content>> _contents = [];
  int? _initialIndex;

  late final LibraryController _libraryController;
  late final CategoryController _categoryController;

  @override
  void initState() {
    super.initState();

    _libraryController = context.read<LibraryController>()
      ..addListener(_setChildren);

    _categoryController = context.read<CategoryController>()
      ..addListener(_setChildren);

    scheduleMicrotask(() {
      final libraryTabController = HomeScope.of(
        context,
      ).subordinateLibraryTabController;
      final parent = context
          .findAncestorWidgetOfExactType<PageView>()
          ?.controller;
      libraryTabController.setParentController(parent);
    });

    _setChildren();
  }

  void _setChildren() {
    final noCategories = _libraryController.repo
        .byCategories(_categoryController, true)
        .getContent
        .toList();

    final yesCategories = _libraryController.repo.entities
        .categoryByID(context)
        .map((e) => e.getContent.toList())
        .toList();

    // final List<Widget> newChildrens = [
    //   buildGridView(noCategories),
    //   ...yesCategories.mapIndexed((index, e) => buildGridView(e))
    // ];

    // customLog(noCategories.length);

    setStateIfMounted(() {
      _contents = [noCategories, ...yesCategories];
    });
  }

  @override
  void didChangeDependencies() {
    // _setChildren();
    final searchController = HomeScope.of(context).searchController;
    final tabController = HomeScope.of(context).tabController;

    searchController.removeListener(_searchControllerListener);

    if (tabController.index == 2) {
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
      _debouncer.call(() {
        subordinateLibraryTabController.animateTo(_initialIndex!);
        _initialIndex = null;
      });

      return;
    }

    final index = _contents.indexWhere(
      (list) =>
          list.any((content) => content.title.toLowerCase().contains(text)),
    );

    if (index != -1 && index != subordinateLibraryTabController.index) {
      _initialIndex = subordinateLibraryTabController.index;
      _debouncer.call(() => subordinateLibraryTabController.animateTo(index));
    }
  }

  static const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    // maxCrossAxisExtent: 170,
    crossAxisCount: 3,
    childAspectRatio: 1.0,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    mainAxisExtent: 150,
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // _setChildren();
    customLog('$widget[build]');
    final SubordinateLibraryTabController subordinateLibraryTabController =
        HomeScope.of(context).subordinateLibraryTabController;
    final searchController = HomeScope.of(context).searchController;
    return NotificationListener<ScrollNotification>(
      onNotification: subordinateLibraryTabController.handleScrollNotification,
      child: ValueListenableBuilder(
        valueListenable: searchController,
        builder: (context, value, child) {
          // return LayoutBuilder(
          //   builder: (context, constraints) {
          //     return AnimatedCategory(
          //       startSize: 150,
          //       deltaSizeFirstTap: 100,
          //       deltaSizeSecondTap: 100,
          //       columnNumber: 2,
          //       onTapItemSelected: (item, expand) async {
          //         // item.width = constraints.maxWidth;
          //         // item.height = constraints.maxHeight;
          //         // setState(() {});
          //         // OpenContainerWrapper.action(item.widgetKey.currentContext!);

          //         // final result = await Navigator.push(
          //         //   context,
          //         //   _CustomPopupRoute(
          //         //     constraints: constraints,
          //         //     data: item.data,
          //         //   ),
          //         // );

          //         final category = _libraryService.getContentByStringId(
          //           _categoryController,
          //           item.data.firstOrNull,
          //         );

          //         await showModalBottomSheet(
          //           context: context,
          //           constraints: constraints,
          //           scrollControlDisabledMaxHeightRatio: 0.80,
          //           builder: (context) {
          //             return Material(
          //               child: Padding(
          //                 padding: EdgeInsets.symmetric(vertical: 12),
          //                 child: Scaffold(
          //                   primary: false,
          //                   appBar: AppBar(
          //                     title: Text(category?.title ?? 'Padrão'),
          //                   ),
          //                 ),
          //               ),
          //             );
          //           },
          //         );

          //         expand(true);
          //       },
          //       itemBorderRadius: BorderRadius.circular(8),
          //       items: _contents,
          //       childBuilder: (item) {
          //         final category = _libraryService.getContentByStringId(
          //           _categoryController,
          //           item.data.firstOrNull,
          //         );

          //         if (item.data.isEmpty) return const SizedBox.shrink();

          //         return Card.filled(
          //           margin: EdgeInsets.zero,
          //           child: InkWell(
          //             key: item.widgetKey,
          //             borderRadius: BorderRadius.circular(8),
          //             onTap: item.onTap,
          //             onLongPress: item.onLongPress,
          //             child: Stack(
          //               fit: StackFit.expand,
          //               children: [
          //                 Center(
          //                   child: Text(category?.title ?? 'Padrão'),
          //                 ),

          //               ],
          //             ),
          //           ),
          //         );
          //       },
          //     );
          //   },
          // );
          return TabBarView(
            controller: subordinateLibraryTabController,
            children: _contents.map((items) {
              if (items.isEmpty) return const SizedBox.shrink();
              final filter = value.text.isNotEmpty
                  ? items.where(
                      (content) => content.title.toLowerCase().trim().contains(
                        value.text.toLowerCase().trim(),
                      ),
                    )
                  : items;
              if (filter.isEmpty) return const SizedBox.shrink();
              return GridView.builder(
                itemCount: filter.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: _gridDelegate,
                shrinkWrap: true,
                padding: const EdgeInsets.only(
                  bottom: 40,
                  left: 8,
                  right: 8,
                  top: 12,
                ),
                itemBuilder: (context, index) {
                  return ContentTile.library(content: filter.elementAt(index));
                },
              );
            }).toList(),
          );
        },
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

// class _CustomPopupRoute extends PopupRoute {
//   _CustomPopupRoute({
//     required this.data,
//     required this.constraints,
//   });

//   final List<Content> data;
//   final BoxConstraints constraints;

//   @override
//   Color? get barrierColor => Colors.black54;

//   @override
//   bool get barrierDismissible => true;

//   @override
//   String? get barrierLabel => 'test';

//   @override
//   Widget buildPage(
//     BuildContext context,
//     Animation<double> animation,
//     Animation<double> secondaryAnimation,
//   ) {
//     return Hero(
//       tag: data,
//       child: ConstrainedBox(
//         constraints: constraints,
//         child: Scaffold(
//           appBar: AppBar(),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget buildTransitions(
//     BuildContext context,
//     Animation<double> animation,
//     Animation<double> secondaryAnimation,
//     Widget child,
//   ) {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Material(
//         type: MaterialType.transparency,
//         child: child,
//       ),
//     );
//     // return Align(
//     //   alignment: Alignment.bottomCenter,
//     //   child: FractionalTranslation(
//     //     translation: _offsetTween.evaluate(_animation!),
//     //     child: child,
//     //   ),
//     // );
//   }

//   @override
//   Duration get transitionDuration => const Duration(milliseconds: 350);
// }
