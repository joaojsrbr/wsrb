import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer_container.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ReleaseControll extends StatefulWidget {
  const ReleaseControll({super.key, required this.content});

  final Content? content;

  @override
  State<ReleaseControll> createState() => _ReleaseControllState();
}

class _ReleaseControllState extends State<ReleaseControll> {
  List<int> _totalPage = [];
  BoolList _selectChips = BoolList.empty();

  @override
  void initState() {
    _initSelectChips();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ReleaseControll oldWidget) {
    if (oldWidget.content != widget.content) {
      _initSelectChips();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _initSelectChips() {
    if (widget.content case Anime data
        when data.totalOfEpisodes != null && data.totalOfPages != null) {
      _totalPage = List.generate(data.totalOfPages!, (index) => index + 1);
    } else {
      _totalPage = List.generate(1, (index) => index + 1);
    }

    if (_totalPage.length != _selectChips.length) {
      _selectChips = BoolList.generate(_totalPage.length, (index) => false);
    }
  }

  @override
  void didChangeDependencies() {
    _setSelectChips();
    super.didChangeDependencies();
  }

  void _setSelectChips() {
    final index = ContentScope.indexOf(context);
    if (_selectChips.isEmpty) return;
    if (!_selectChips[index]) {
      final indexOf = _selectChips.indexWhere((select) => select);
      _selectChips[index] = true;
      if (indexOf != -1) _selectChips[indexOf] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.content == null || _selectChips.isEmpty || _totalPage.isEmpty) {
      return const SizedBox(height: 0, width: 0);
    }
    final isLoading = ContentScope.isLoadingOf(context);
    final AppConfigController appConfigController = context.watch<AppConfigController>();
    final setListIndex = ContentScope.of(context).setListIndex;

    // final chipsWidgets = List.generate(_selectChips.length, (index) {
    //   int page = _totalPage[index];

    //   return Padding(
    //     padding: const EdgeInsets.only(right: 8),
    //     child: ChoiceChip(
    //       padding: const EdgeInsets.symmetric(horizontal: 8),
    //       selected: _selectChips[index],
    //       onSelected: (value) => setListIndex.call(index),
    //       label: Text('$page'),
    //     ),
    //   );
    // });
    final bool releasesIsLoading = ContentScope.releasesIsLoadingOf(context);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ListView.builder(
        shrinkWrap: true,
        physics: isLoading
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 6),
        scrollDirection: Axis.horizontal,
        itemCount: _selectChips.length + 2,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return ShimmerContainer(
                borderRadius: BorderRadius.circular(8),
                height: 50,
                width: 40,
                enable: isLoading,
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  iconSize: 21,
                  onPressed: () => appConfigController.setReverseContents(
                    !appConfigController.config.reverseContents,
                  ),
                  icon: FadeThroughTransitionSwitcher(
                    enableSecondChild: !appConfigController.config.reverseContents,
                    duration: const Duration(milliseconds: 350),
                    secondChild: Icon(MdiIcons.sortNumericAscending),
                    child: Icon(MdiIcons.sortNumericDescending),
                  ),
                ),
              );

            case 1:
              return const VerticalDivider();
          }

          int page = _totalPage[index - 2];

          return Padding(
            padding: isLoading
                ? const EdgeInsets.only(left: 8, right: 8)
                : EdgeInsets.zero,
            child: ShimmerContainer(
              height: 50,
              borderRadius: BorderRadius.circular(8),
              width: !_selectChips[index - 2] && !isLoading ? 60 : 80,
              enable: isLoading,
              child: ChoiceChip(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                selected: _selectChips[index - 2],
                onSelected: releasesIsLoading
                    ? null
                    : (value) => setListIndex.call(index - 2),
                label: Text('$page'),
              ),
            ),
          );
        },
      ),
    );
  }
}
