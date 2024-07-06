import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/home/widgets/home_rail_menu.dart';
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

    final TabController tabController = HomeScope.of(context).tabController;

    Future<void> onRefresh() async {
      if (!mounted) return;
      if (tabController.index != 0) return;
      await _contentRepository.refresh(true);
    }

    final RailMenuController railMenuController =
        HomeRailMenu.menuControllerOf(context);

    // customLog(railMenuController.isOpen);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 350),
        padding: EdgeInsets.only(right: railMenuController.isOpen ? 50 : 0),
        child: LoadingMoreList(
          // key: PageStorageKey('content_distination'),
          ListConfig<Content>(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            indicatorBuilder: contentIndicatorBuilder,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: _itemBuilder,
            sourceList: _contentRepository,
          ),
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, Content content, int index) {
    return ItemContent(content: content);
  }
}
