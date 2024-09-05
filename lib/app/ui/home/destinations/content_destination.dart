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

    final ConnectionChecker connectionChecker =
        context.watch<ConnectionChecker>();

    // customLog(railMenuController.isOpen);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Builder(builder: (context) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: connectionChecker.connectivityResult.isEmpty
              ? const FullScreenErrorWidget(btnAtualizar: false)
              : LoadingMoreList(
                  ListConfig<Content>(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    indicatorBuilder: contentIndicatorBuilder,
                    itemBuilder: _itemBuilder,
                    sourceList: _contentRepository,
                  ),
                  key: const PageStorageKey("content_destination"),
                ),
        );
      }),
    );
  }

  Widget _itemBuilder(BuildContext context, Content content, int index) {
    return ItemContent(
      content: content,
      key: ObjectKey(content),
    );
  }
}
