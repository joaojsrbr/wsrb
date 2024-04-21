import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/home/view/home_view.dart';
import 'package:content_library/content_library.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/item_content.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/indicator_build.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeDestination extends StatefulWidget {
  const HomeDestination({super.key});

  @override
  State<HomeDestination> createState() => _HomeDestinationState();
}

class _HomeDestinationState extends State<HomeDestination>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final ContentRepository _contentRepository;

  @override
  void initState() {
    super.initState();
    _contentRepository = context.read<ContentRepository>();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final TabController tabController = HomeScope.of(context).tabController;

    Future<void> onRefresh() async {
      if (!mounted) return;

      if (tabController.index != 0) return;
      await _contentRepository.refresh(true);
    }

    // final HiveController hiveController = context.watch<HiveController>();

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LoadingMoreList(
        ListConfig<Content>(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          indicatorBuilder: indicatorBuilder,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: _itemBuilder,
          restorationId: 'home_distination',
          sourceList: _contentRepository,
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, Content content, int index) {
    return ItemContent(content: content);
  }
}
