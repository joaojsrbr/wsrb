import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/filtro_bottom_sheet.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/sliver_app_bar_flexible_space.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_search_anchor.dart';
import 'package:app_wsrb_jsr/app/utils/category_helper.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class HomeSliverAppBar extends StatelessWidget {
  const HomeSliverAppBar({super.key});

  void _pushTofilter(BuildContext context) async {
    final result = await Navigator.push(
      context,
      FiltroBottomSheetRoute(
        // genres: _map.keys.map((entity) => entity.anilistMedia?.genres).nonNulls.flattened.toList(),
        appConfigController: context.read(),
        bottomSheetAnimationController: HomeScope.of(
          context,
        ).bottomSheetAnimationController,
      ),
    );

    if (result != null) {
      // _appConfigController.setFilterWatching(result);
      customLog(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TabController tabController = HomeScope.of(context).tabController;
    final CustomSearchController searchController = HomeScope.of(
      context,
    ).searchController;
    final LibraryController libraryController = context.watch<LibraryController>();
    final libraryRepo = libraryController.repo;
    return SliverAppBar(
      automaticallyImplyLeading: false,
      title: SliverAppBarFlexibleSpace(searchController: searchController),
      bottom: TabBar(
        controller: tabController,
        dividerColor:
            (libraryRepo.notCompleted.isNotEmpty || libraryRepo.completed.isEmpty) &&
                tabController.index == 2
            ? Colors.transparent
            : null,
        tabs: [
          Tab(icon: Icon(MdiIcons.home)),
          Tab(icon: Icon(MdiIcons.history)),
          Tab(icon: Icon(MdiIcons.library)),
        ],
      ),
      actions: [
        ...switch (tabController.index) {
          0 => [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                visualDensity: const VisualDensity(horizontal: -4),
                onPressed: () async {
                  if (await PermissionUtils.manageExternalStorage() && context.mounted) {
                    context.push(RouteName.DOWNLOAD);
                  }
                },
                icon: Icon(MdiIcons.downloadBox),
              ),
            ),
          ],
          1 => [
            IconButton(
              onPressed: () => _pushTofilter(context),
              icon: Icon(MdiIcons.filter),
            ),
          ],
          2 => [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                visualDensity: const VisualDensity(horizontal: -4),
                onPressed: () => CategoryHelper.openCategoryCreator(context),
                icon: Icon(MdiIcons.tag),
              ),
            ),
          ],
          _ => [],
        },

        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            visualDensity: const VisualDensity(horizontal: -4),
            onPressed: () {
              context.push(RouteName.SETTINGS);
            },
            icon: Icon(MdiIcons.cog),
          ),
        ),
      ],
    );
  }
}
