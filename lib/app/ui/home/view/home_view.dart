import 'package:app_wsrb_jsr/app/core/constants/order.dart';
import 'package:app_wsrb_jsr/app/core/constants/source.dart';
import 'package:app_wsrb_jsr/app/core/services/hive/hive_controller.dart';
import 'package:app_wsrb_jsr/app/repositories/content_repository.dart';
import 'package:app_wsrb_jsr/app/ui/home/destinations/home_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/destinations/library_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/mixins/home_utils.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/menu_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin, HomeUtilsMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2)
      ..addListener(_tabListener);

    super.initState();
  }

  void _tabListener() {
    // final int index = _tabController.index;

    // setStateIfMounted(() {
    //   switch (index) {
    //     case 1 when _enableMenu:
    //       _enableMenu = false;
    //       break;
    //     case 0 when !_enableMenu:
    //       _enableMenu = true;
    //       break;
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    final HiveController hiveController = context.watch<HiveController>();
    final ContentRepository repository = context.read<ContentRepository>();

    return Scaffold(
      body: NestedScrollView(
        physics: mainPhysics,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: Text(hiveController.source.name),
            actions: kDebugMode
                ? [
                    IconButton(
                      onPressed: () {
                        repository.refresh(true);
                      },
                      icon: Icon(MdiIcons.refresh),
                    ),
                  ]
                : null,
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              // primary: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MenuWidget(
                    key: ObjectKey(hiveController.source),
                    borderRadius: BorderRadius.circular(8),
                    menuBorderRadius: BorderRadius.circular(8),
                    constraints: const BoxConstraints(
                      minWidth: 100,
                      maxWidth: 135,
                      maxHeight: 40,
                      minHeight: 40,
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
                    onChange: hiveController.setSource,
                    label: (data) => data.name,
                    items: Source.values,
                    data: hiveController.source,
                  ),
                  MenuWidget(
                    key: ObjectKey(hiveController.orderBy),
                    borderRadius: BorderRadius.circular(8),
                    menuBorderRadius: BorderRadius.circular(8),
                    constraints: const BoxConstraints(
                      minWidth: 100,
                      maxWidth: 135,
                      maxHeight: 40,
                      minHeight: 40,
                    ),
                    padding: EdgeInsets.zero,
                    onChange: hiveController.setOrderBy,
                    label: (data) => data.name,
                    items: OrderBy.values,
                    data: hiveController.orderBy,
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          physics: tabPhysics,
          controller: _tabController,
          children: const [
            HomeDestination(),
            LibraryDestination(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_tabListener)
      ..dispose();
    super.dispose();
  }
}
