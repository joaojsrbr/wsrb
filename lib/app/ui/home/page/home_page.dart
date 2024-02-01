import 'package:app_wsrb_jsr/app/core/constants/order.dart';
import 'package:app_wsrb_jsr/app/core/constants/source.dart';
import 'package:app_wsrb_jsr/app/core/services/hive/hive_controller.dart';
import 'package:app_wsrb_jsr/app/utils/custom_log.dart';
import 'package:app_wsrb_jsr/app/ui/home/destinations/home_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/destinations/library_destination.dart';
import 'package:app_wsrb_jsr/app/ui/home/utils/home_utils.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, HomeUtils {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2)
      ..addListener(_tabListener);

    super.initState();
  }

  bool _enableMenu = true;

  void _tabListener() {
    if (!mounted) return;

    final int index = _tabController.index;

    setState(() {
      switch (index) {
        case 1 when _enableMenu:
          _enableMenu = false;
          break;
        case 0 when !_enableMenu:
          _enableMenu = true;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final HiveController hiveController = context.watch<HiveController>();

    return Scaffold(
      body: NestedScrollView(
        physics: mainPhysics,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: Text(hiveController.source.name),
          ),
          SliverAnimatedPaintExtent(
            duration: const Duration(milliseconds: 200),
            child: _enableMenu
                ? SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        // scrollDirection: Axis.horizontal,
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
                            onChange: (selected) {
                              customLog(selected);
                              // hiveController.setOrderBy(selected);
                            },
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
                            onChange: (selected) {
                              hiveController.setOrderBy(selected);
                            },
                            label: (data) => data.name,
                            items: OrderBy.values,
                            data: hiveController.orderBy,
                          ),
                        ],
                      ),
                    ),
                  )
                : const SliverToBoxAdapter(),
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
