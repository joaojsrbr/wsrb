import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/home/view/home_view.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_search_anchor.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class HomeViewFlexibleSpace extends StatefulWidget {
  const HomeViewFlexibleSpace({super.key});

  @override
  State<HomeViewFlexibleSpace> createState() => _HomeViewFlexibleSpaceState();
}

class _HomeViewFlexibleSpaceState extends State<HomeViewFlexibleSpace> {
  late final ContentRepository _contentRepository;

  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  final Debouncer _searchDebouncer =
      Debouncer(duration: const Duration(seconds: 1));

  CustomSearchController? _searchController;

  @override
  void initState() {
    super.initState();
    _contentRepository = context.read<ContentRepository>();
    scheduleMicrotask(() {
      _searchController = HomeScope.of(context).searchController
        ..addListener(_searchControllerListener);
    });
    // _searchContents(value.trim());
  }

  void _searchControllerListener() {
    _searchDebouncer.cancel();
    _searchDebouncer.call(() {
      _searchContents(_searchController!.text.trim());
    });
  }

  @override
  void dispose() {
    _searchDebouncer.cancel();
    _isLoading.dispose();
    _searchController?.removeListener(_searchControllerListener);
    super.dispose();
  }

  Future<void> _searchContents(String query) async {
    if (query.length < 4) return;
    _isLoading.value = true;
    await _contentRepository.searchContents(
      query,
      searchSources: Source.list,
      onSuccess: (value) {
        customLog(value);
      },
    );
    _isLoading.value = false;
  }

  FutureOr<Widget> _suggestionsBuilder(
    BuildContext context,
    CustomSearchController controller,
  ) async {
    return Center(
      child: Container(
        height: 200,
        width: 200,
        color: Colors.blue,
      ),
    );
  }

  void _unFocus(BuildContext context) {
    final FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.focusedChild?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    final searchController = HomeScope.of(context).searchController;
    final tabController = HomeScope.of(context).tabController;

    final ValueNotifierList valueNotifierList =
        context.watch<ValueNotifierList>();

    final ConnectionChecker connectionChecker =
        context.watch<ConnectionChecker>();

    return IgnorePointer(
      ignoring: tabController.index == 2 ||
          valueNotifierList.isNotEmpty ||
          (!connectionChecker.hasConnection && tabController.index == 1),
      child: CustomSearchAnchor(
        dividerWidget: AnimatedBuilder(
          animation: _isLoading,
          child: const LinearProgressIndicator(),
          builder: (context, child) =>
              _isLoading.value ? child! : const Divider(height: 1),
        ),
        onChanged: (String value) {
          if (tabController.index != 0) return;
          if (value.trim().isEmpty && searchController.isOpen) {
            searchController.closeView(value);
          } else {
            searchController.openView();
          }
        },
        barTrailing: [
          FadeThroughTransitionSwitcher(
            enableSecondChild: tabController.index != 1 ||
                searchController.text.trim().isEmpty,
            duration: const Duration(seconds: 1),
            child: IconButton(
              onPressed: () {
                searchController.clear();
                _unFocus(context);
              },
              icon: Icon(MdiIcons.close),
            ),
          )
        ],
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
        barElevation: const WidgetStatePropertyAll(0),
        barSide: _BarSideMaterialState(themeData.colorScheme),
        viewElevation: 0,
        suggestionsBuilder: _suggestionsBuilder,
      ),
    );
  }
}

class _BarShapeMaterialState
    extends WidgetStateProperty<RoundedRectangleBorder?> {
  final _defaultBarShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );

  _BarShapeMaterialState();

  @override
  RoundedRectangleBorder? resolve(Set<WidgetState> states) {
    return _defaultBarShape;
  }
}

class _BarSideMaterialState extends WidgetStateProperty<BorderSide?> {
  _BarSideMaterialState(this.colorScheme);

  final ColorScheme colorScheme;

  @override
  BorderSide? resolve(Set<WidgetState> states) {
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
