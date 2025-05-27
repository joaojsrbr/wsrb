import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/home/widgets/content_indicator_build.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/item_content.dart';
import 'package:content_library/content_library.dart';
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

  Future<void> onRefresh() async {
    if (!mounted) return;
    final HomeScope scope = HomeScope.of(context);
    final TabController tabController = scope.tabController;
    if (tabController.index != 0) return;
    await _contentRepository.refresh(true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    customLog('$widget[build]');

    // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //   crossAxisCount: 2,
    //   crossAxisSpacing: 8,
    //   mainAxisSpacing: 8,
    // ),

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: LoadingMoreList(
          ListConfig<Content>(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 6),
            indicatorBuilder: contentIndicatorBuilder,
            itemBuilder: _itemBuilder,
            sourceList: _contentRepository,
          ),
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, Content content, int index) {
    return ItemContent.content(content: content);
  }
}
