import 'package:content_library/content_library.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ChipContentController extends StatefulWidget {
  const ChipContentController({super.key});

  @override
  State<ChipContentController> createState() => _ChipContentControllerState();
}

class _ChipContentControllerState extends State<ChipContentController> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {}

  @override
  Widget build(BuildContext context) {
    final isLoading = BookInformationScope.isLoadingOf(context);

    Widget container = const SliverToBoxAdapter();
    final releases = BookInformationScope.releasesOf(context);
    final index = BookInformationScope.indexOf(context);

    if (isLoading) {
      container = const _ShimmerWidget();
    } else if (releases.isNotEmpty) {
      final setListChapterIndex = BookInformationScope.of(context).setListIndex;
      // final contentOrders = context.watch<HiveController>().contentOrders;
      final hiveController = context.watch<HiveController>();

      final selectChips = List.generate(releases.length, (index) => false);

      selectChips[index] = true;

      final chipsWidgets = List.generate(selectChips.length, (index) {
        Release firstText = releases[index].first;
        Release lastText = releases[index].last;

        // if (selectChips.length == 1 && hiveController.contentOrders) {
        //   firstText = releases[index].last;
        //   lastText = releases[index].first;

        //   if (releases[index].last is Chapter) {
        //     firstText = releases[index].first;
        //     lastText = releases[index].last;
        //   }
        // } else if (selectChips.length == 1 && !hiveController.contentOrders) {
        //   firstText = releases[index].first;
        //   lastText = releases[index].last;
        //   if (releases[index].last is Chapter) {
        //     firstText = releases[index].last;
        //     lastText = releases[index].first;
        //   }
        // }

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            selected: selectChips[index],
            onSelected: (value) => setListChapterIndex.call(index),
            label: Text('${firstText.number} - ${lastText.number}'),
          ),
        );
      });

      container = SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 12),
          child: SizedBox(
            height: 36,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(selectChips.length + 2, (index) {
                  switch (index) {
                    case 0:
                      return IconButton.filled(
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        iconSize: 21,
                        onPressed: () => hiveController.setReverseContents(
                            !hiveController.reverseContents),
                        icon: FadeThroughTransitionSwitcher(
                          enableSecondChild: !hiveController.reverseContents,
                          duration: const Duration(milliseconds: 550),
                          secondChild: Icon(MdiIcons.sortNumericAscending),
                          child: Icon(MdiIcons.sortNumericDescending),
                        ),
                      );

                    case 1:
                      return const VerticalDivider();
                  }

                  return chipsWidgets[index - 2];
                }),
              ),
            ),
          ),
        ),
      );
    }

    return SliverAnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: container,
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

class _ShimmerWidget extends StatelessWidget {
  const _ShimmerWidget();

  @override
  Widget build(BuildContext context) {
    // final isLoading = BookInformationScope.isLoadingOf(context);

    return SliverToBoxAdapter(
      child: ShimmerLoading(
        isLoading: true,
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
                  7,
                  (index) {
                    const shape = RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    );

                    switch (index) {
                      case 0:
                        return const Card(
                          elevation: 2,
                          margin: EdgeInsets.zero,
                          shape: shape,
                          child: SizedBox(width: 42, height: 38),
                        );
                      case 1:
                        return const VerticalDivider();
                    }

                    return const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Card(
                        elevation: 2,
                        margin: EdgeInsets.zero,
                        shape: shape,
                        child: SizedBox(width: 60, height: 36),
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
}
