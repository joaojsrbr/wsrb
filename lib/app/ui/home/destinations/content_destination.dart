import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/shared/widgets/rail_menu.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:content_library/content_library.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/item_content.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/content_indicator_build.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContentDestination extends StatefulWidget {
  const ContentDestination({super.key});

  @override
  State<ContentDestination> createState() => _ContentDestinationState();
}

class _ContentDestinationState extends State<ContentDestination>
    with AutomaticKeepAliveClientMixin {
  late final ContentRepository _contentRepository;

  @override
  void initState() {
    super.initState();
    _contentRepository = context.read<ContentRepository>();
    _contentRepository.refresh(true);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final HomeScope scope = HomeScope.of(context);
    final TabController tabController = scope.tabController;

    Future<void> onRefresh() async {
      if (!mounted) return;
      if (tabController.index != 0) return;
      await _contentRepository.refresh(true);
    }

    final RailMenuController railMenuController =
        RailMenu.menuControllerOf(context);

    final ConnectionChecker connectionChecker =
        context.watch<ConnectionChecker>();

    // customLog(railMenuController.isOpen);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 350),
        padding: EdgeInsets.only(right: railMenuController.isOpen ? 50 : 0),
        child: Builder(builder: (context) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: connectionChecker.connectivityResult.isEmpty
                ? const FullScreenErrorWidget(btnAtualizar: false)
                : LoadingMoreList(
                    ListConfig<Content>(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      indicatorBuilder: contentIndicatorBuilder,
                      itemBuilder: _itemBuilder,
                      sourceList: _contentRepository,
                    ),
                  ),
          );
        }),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, Content content, int index) {
    return ItemContent(content: content);
  }
}
