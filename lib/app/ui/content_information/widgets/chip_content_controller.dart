import 'dart:async';

import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/list_extensions.dart';
import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/state_extensions.dart';
import 'package:app_wsrb_jsr/app/core/services/hive/hive_controller.dart';

import 'package:app_wsrb_jsr/app/models/release.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ChipContentController extends StatefulWidget {
  const ChipContentController({super.key});

  @override
  State<ChipContentController> createState() => ChipContentControllerState();
}

class ChipContentControllerState extends State<ChipContentController> {
  late final ScrollController _scrollController;

  List<GlobalKey> _keys = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    Future.delayed(const Duration(seconds: 4), _scrollToEnd);
  }

  void _scrollToEnd() async {
    final hiveController = context.read<HiveController>();
    if (!hiveController.pageOrders) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void _startKeys() {
    final releases = BookInformationScope.releasesOf(context);
    if (_keys.length == releases.length) return;
    _keys = releases.map((e) => GlobalKey()).toList();
  }

  @override
  void didChangeDependencies() {
    final isLoading = BookInformationScope.isLoadingOf(context);
    if (!isLoading) ifMounted(_startKeys);

    super.didChangeDependencies();
  }

  void _scrollListener() {}

  @override
  Widget build(BuildContext context) {
    final isLoading = BookInformationScope.isLoadingOf(context);

    if (isLoading) {
      return SliverToBoxAdapter(
        child: ShimmerLoading(
          isLoading: isLoading,
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            child: SizedBox(
              height: 36,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    8,
                    (index) {
                      switch (index) {
                        case 0:
                          return Material(
                            borderRadius: BorderRadius.circular(8),
                            child: const Chip(
                              side: BorderSide.none,
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              label: SizedBox(
                                width: 20,
                                height: 36,
                              ),
                            ),
                          );
                        case 1:
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Material(
                              borderRadius: BorderRadius.circular(8),
                              child: const Chip(
                                side: BorderSide.none,
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                label: SizedBox(
                                  width: 20,
                                  height: 36,
                                ),
                              ),
                            ),
                          );
                        case 2:
                          return const VerticalDivider();
                      }

                      return const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Chip(
                          side: BorderSide.none,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          label: SizedBox(
                            width: 50,
                            height: 36,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final setListChapterIndex = BookInformationScope.of(context).setListIndex;
    final contentOrders = context.watch<HiveController>().contentOrders;
    final releases = BookInformationScope.releasesOf(context).reversed.toList();
    final index = BookInformationScope.indexOf(context);
    final hiveController = context.watch<HiveController>();
    if (releases.isEmpty) return const SliverToBoxAdapter();

    final selectChips = releases.map((e) => false).toList();
    selectChips[index] = true;

    final chipsWidgets = List.generate(selectChips.length, (index) {
      Release firstText = releases[index].first;
      Release lastText = releases[index].last;

      if (contentOrders) {
        firstText = releases[index].last;
        lastText = releases[index].first;
        if (hiveController.pageOrders) {
          firstText = releases[index].first;
          lastText = releases[index].last;
        }
      } else {
        firstText = releases[index].first;
        lastText = releases[index].last;
      }

      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          key: _keys[index],
          // key: _keys[chapterIndex],
          padding: const EdgeInsets.symmetric(horizontal: 8),
          selected: selectChips[index],
          onSelected: (value) => setListChapterIndex.call(index),
          label: Text('${firstText.number} - ${lastText.number}'),
        ),
      );
    }).reverse(!hiveController.pageOrders);

    // print((_keys.last.currentContext?.findRenderObject() as RenderBox?)?.size);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        child: SizedBox(
          height: 36,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            scrollDirection: Axis.horizontal,
            // shrinkWrap: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(selectChips.length + 3, (index) {
                switch (index) {
                  case 0:
                    return IconButton.filled(
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      iconSize: 21,
                      onPressed: () => hiveController
                          .setChaptersOrders(!hiveController.contentOrders),
                      icon: FadeThroughTransitionSwitcher(
                        enableSecondChild: hiveController.contentOrders,
                        duration: const Duration(milliseconds: 550),
                        secondChild: Icon(MdiIcons.sortNumericDescending),
                        child: Icon(MdiIcons.sortNumericAscending),
                      ),
                    );
                  case 1:
                    return IconButton.filled(
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      iconSize: 21,
                      onPressed: selectChips.length == 1
                          ? null
                          : () => hiveController
                              .setPageOrders(!hiveController.pageOrders),
                      icon: RotatedBox(
                        quarterTurns: 3,
                        child: FadeThroughTransitionSwitcher(
                          enableSecondChild: hiveController.pageOrders,
                          duration: const Duration(milliseconds: 550),
                          secondChild: Icon(MdiIcons.sortNumericDescending),
                          child: Icon(MdiIcons.sortNumericAscending),
                        ),
                      ),
                    );
                  case 2:
                    return const VerticalDivider();
                }

                return chipsWidgets[index - 3];
              }),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_scrollListener)
      ..dispose();
    super.dispose();
  }
}
