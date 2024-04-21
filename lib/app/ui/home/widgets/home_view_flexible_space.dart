import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/home/view/home_view.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_search_anchor.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/utils/value_notifier_list.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class HomeViewFlexibleSpace extends StatefulWidget {
  const HomeViewFlexibleSpace({super.key});

  @override
  State<HomeViewFlexibleSpace> createState() => _HomeViewFlexibleSpaceState();
}

class _HomeViewFlexibleSpaceState extends State<HomeViewFlexibleSpace> {
  FutureOr<Widget> _suggestionsBuilder(
    BuildContext context,
    CustomSearchController controller,
  ) async {
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    final searchController = HomeScope.of(context).searchController;
    final tabController = HomeScope.of(context).tabController;

    final ValueNotifierList valueNotifierList =
        context.watch<ValueNotifierList>();

    return IgnorePointer(
      ignoring: tabController.index == 2 || valueNotifierList.isNotEmpty,
      child: CustomSearchAnchor(
        onChanged: (String value) {
          if (tabController.index != 0) return;
          if (value.trim().isEmpty && searchController.isOpen) {
            searchController.closeView(value);
          } else {
            searchController.openView();
          }
        },
        barLeading: FadeThroughTransitionSwitcher(
          enableSecondChild: valueNotifierList.isNotEmpty,
          duration: const Duration(seconds: 1),
          secondChild: IconButton(
            onPressed: () => valueNotifierList.clear(),
            icon: Icon(MdiIcons.close),
          ),
          child: Icon(MdiIcons.magnify),
        ),
        searchController: searchController,
        constraints: const BoxConstraints(maxHeight: 42, minHeight: 42),
        barShape: _BarShapeMaterialState(),
        labelText: valueNotifierList.isNotEmpty
            ? 'itens ${valueNotifierList.length}'
            : 'Pesquisa',
        barElevation: const MaterialStatePropertyAll(0),
        barSide: _BarSideMaterialState(themeData.colorScheme),
        viewElevation: 0,
        suggestionsBuilder: _suggestionsBuilder,
      ),
    );
  }
}

class _BarShapeMaterialState
    extends MaterialStatePropertyAll<RoundedRectangleBorder?> {
  final _defaultBarShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );

  _BarShapeMaterialState() : super(null);

  @override
  RoundedRectangleBorder? resolve(Set<MaterialState> states) {
    return _defaultBarShape;
  }
}

class _BarSideMaterialState extends MaterialStatePropertyAll<BorderSide?> {
  _BarSideMaterialState(this.colorScheme) : super(null);

  final ColorScheme colorScheme;

  @override
  BorderSide? resolve(Set<MaterialState> states) {
    // if (states.contains(MaterialState.focused)) {
    //   return BorderSide(
    //     color: colorScheme.primary.withOpacity(0.10),
    //   );
    // }
    return BorderSide(
      color: colorScheme.primary.withOpacity(0.10),
    );
  }
}
