import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/list_extensions.dart';
import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/state_extensions.dart';
import 'package:app_wsrb_jsr/app/core/services/hive/hive_controller.dart';
import 'package:app_wsrb_jsr/app/models/chapter.dart';
import 'package:app_wsrb_jsr/app/ui/book_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ChipBookController extends StatefulWidget {
  const ChipBookController({super.key});

  @override
  State<ChipBookController> createState() => ChipBookControllerState();
}

class ChipBookControllerState extends State<ChipBookController> {
  late final ScrollController _scrollController;

  List<GlobalKey> _keys = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  void _startKeys() {
    final chapters = BookInformationScope.chaptersOf(context);
    if (_keys.length == chapters.length) return;
    _keys = chapters.map((e) => GlobalKey()).toList();
  }

  @override
  void didChangeDependencies() {
    final isLoading = BookInformationScope.isLoadingOf(context);
    if (!isLoading) ifMounted(_startKeys);
    // Future.delayed(const Duration(seconds: 1), _scrollAtSelect);

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
    final chaptersOrders = BookInformationScope.of(context).chaptersOrders;
    final chapters = BookInformationScope.chaptersOf(context).reversed.toList();
    final index = BookInformationScope.indexOf(context);
    final hiveController = context.watch<HiveController>();
    if (chapters.isEmpty) return const SliverToBoxAdapter();

    final selectChips = chapters.map((e) => false).toList();
    selectChips[index] = true;

    final chipsWidgets = List.generate(selectChips.length, (index) {
      Chapter firstText = chapters[index].first;
      Chapter lastText = chapters[index].last;

      if (chaptersOrders) {
        firstText = chapters[index].last;
        lastText = chapters[index].first;
        if (hiveController.pageOrders) {
          firstText = chapters[index].first;
          lastText = chapters[index].last;
        }
      } else {
        firstText = chapters[index].first;
        lastText = chapters[index].last;
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
                          .setChaptersOrders(!hiveController.chaptersOrders),
                      icon: FadeThroughTransitionSwitcher(
                        replace: hiveController.chaptersOrders,
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
                      onPressed: () => hiveController
                          .setPageOrders(!hiveController.pageOrders),
                      icon: RotatedBox(
                        quarterTurns: 3,
                        child: FadeThroughTransitionSwitcher(
                          replace: hiveController.pageOrders,
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
    // _timer?.cancel();
    // _timer = null;
    _scrollController
      ..removeListener(_scrollListener)
      ..dispose();
    super.dispose();
  }
}
