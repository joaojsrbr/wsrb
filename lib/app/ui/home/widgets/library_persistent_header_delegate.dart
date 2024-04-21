import 'package:app_wsrb_jsr/app/ui/home/view/home_view.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';

class LibraryPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  const LibraryPersistentHeaderDelegate({this.enable = true});

  final bool enable;

  @override
  bool shouldRebuild(covariant LibraryPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  double get maxExtent => enable ? preferredSize.height : 0;

  @override
  double get minExtent => enable ? preferredSize.height : 0;

  Size get preferredSize {
    double maxHeight = 46.0;

    for (int index = 0; index < 3; index++) {
      final double itemHeight =
          const Tab(icon: SizedBox.shrink()).preferredSize.height;
      maxHeight = math.max(itemHeight, maxHeight);
    }

    return Size.fromHeight(maxHeight + 2);
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final CategoryController categoryController =
        context.watch<CategoryController>();

    List<Widget> tabs = [const Tab(text: 'Padrão', key: ValueKey('Padrão'))];

    void add(CategoryEntity entity) {
      final tab = Tab(text: entity.title, key: ValueKey(entity.title));
      tabs.addIfNoContains(tab);
    }

    categoryController.categories.forEach(add);

    return Material(
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      elevation: overlapsContent ? 3 : 0,
      child: TabBar.secondary(
        tabAlignment: TabAlignment.start,
        controller: HomeScope.of(context).libraryTabController,
        tabs: tabs,
        isScrollable: true,
      ),
    );
  }
}



// class HomePersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
//   const HomePersistentHeaderDelegate({
//     this.enable = true,
//   });

//   final bool enable;

//   @override
//   bool shouldRebuild(covariant LibraryPersistentHeaderDelegate oldDelegate) {
//     return enable != oldDelegate.enable;
//   }

//   @override
//   double get maxExtent => enable ? preferredSize.height : 0;

//   @override
//   double get minExtent => enable ? preferredSize.height : 0;

//   Size get preferredSize {
//     double maxHeight = 46.0;

//     for (int index = 0; index < 3; index++) {
//       final double itemHeight =
//           const Tab(icon: SizedBox.shrink()).preferredSize.height;
//       maxHeight = math.max(itemHeight, maxHeight);
//     }

//     return Size.fromHeight(maxHeight + 2);
//   }

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return const _HomeSource();
//   }
// }

// class _HomeSource extends StatefulWidget {
//   const _HomeSource();

//   @override
//   State<_HomeSource> createState() => __HomeSourceState();
// }

// class __HomeSourceState extends State<_HomeSource>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;

//   @override
//   void initState() {
//     _tabController = TabController(vsync: this, length: Source.values.length);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
//       // elevation: overlapsContent ? 3 : 0,
//       child: TabBar.secondary(
//         tabAlignment: TabAlignment.start,
//         controller: _tabController,
//         tabs: Source.values
//             .map((e) => Tab(text: e.label, key: ValueKey(e.label)))
//             .toList(),
//         isScrollable: true,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
// }
