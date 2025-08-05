import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_search_anchor.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/item_content.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class SliverAppBarFlexibleSpace extends StatefulWidget {
  const SliverAppBarFlexibleSpace({super.key, required this.searchController});
  final CustomSearchController searchController;

  @override
  State<SliverAppBarFlexibleSpace> createState() => _SliverAppBarFlexibleSpaceState();
}

class _SliverAppBarFlexibleSpaceState extends State<SliverAppBarFlexibleSpace> {
  late final ContentRepository _contentRepository;

  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  final Map<Source, List<Content>> _contents = {};

  final Debouncer _searchDebouncer = Debouncer(duration: const Duration(seconds: 1));

  CustomSearchController get _searchController => widget.searchController;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchControllerListener);
    _contentRepository = context.read<ContentRepository>();
  }

  void _searchControllerListener() {
    customLog(_searchController.isOpen);
  }

  Future<void> _searchContents(String query, [forceSearch = false]) async {
    if (_contents.values.flattened.any((content) => content.title.toLowerCase().contains(query.toLowerCase())) &&
        !forceSearch) {
      return;
    }
    _isLoading.value = true;
    await _contentRepository.searchContents(
      query,
      searchSources: Source.list,
      onSuccess: (value) {
        final (source, contents) = value;
        setStateIfMounted(() => _contents[source] = contents);
      },
    );
    _searchController.unFocusKeyBoard();
    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    final TabController tabController = HomeScope.of(context).tabController;

    final ValueNotifierList valueNotifierList = context.watch<ValueNotifierList>();

    return IgnorePointer(
      ignoring: tabController.index == 2,
      child: CustomSearchAnchor(
        onSubmitted: (value) {
          if (value.isEmpty || tabController.index != 0) {
            context.unFocusKeyBoard();
            return;
          }

          if (value.length >= 2 && !_searchController.isOpen) {
            _searchController.openView();
          }
          if (value.length >= 2) {
            _searchDebouncer.cancel();
            _searchContents(value, true);
          }
        },
        dividerWidget: AnimatedBuilder(
          animation: _isLoading,
          child: const LinearProgressIndicator(minHeight: 2),
          builder: (context, child) => _isLoading.value ? child! : const Divider(height: 2),
        ),
        // onChanged: (String value) {
        //   if (tabController.index != 0) return;
        //   if (value.trim().isEmpty && searchController.isOpen) {
        //     searchController.closeView(value);
        //   } else if (value.trim().length >= 4) {
        //     searchController.openView();
        //   }
        // },
        barTrailing: [
          AnimatedBuilder(
            animation: _searchController,
            builder: (context, child) {
              return FadeThroughTransitionSwitcher(
                enableSecondChild: tabController.index != 1 || _searchController.text.trim().isEmpty,
                duration: const Duration(seconds: 1),
                child: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    context.unFocusKeyBoard();
                  },
                  icon: Icon(MdiIcons.close),
                ),
              );
            },
          ),
        ],
        barLeading: FadeThroughTransitionSwitcher(
          enableSecondChild: valueNotifierList.isNotEmpty,
          duration: const Duration(milliseconds: 350),
          secondChild: IconButton(onPressed: valueNotifierList.clear, icon: Icon(MdiIcons.close)),
          child: Icon(MdiIcons.magnify),
        ),
        searchController: _searchController,
        constraints: const BoxConstraints(maxHeight: 42, minHeight: 42),
        barShape: _BarShapeMaterialState(),
        labelText: _labelText(valueNotifierList, tabController),
        barElevation: const WidgetStatePropertyAll(0),
        barSide: _BarSideMaterialState(themeData.colorScheme),
        viewElevation: 0,
        suggestionsBuilder: _suggestionsBuilder,
      ),
    );
  }

  String _labelText(ValueNotifierList valueNotifierList, TabController tabController) {
    if (valueNotifierList.isNotEmpty) return 'itens ${valueNotifierList.length}';
    return switch (tabController.index) {
      0 => 'Pesquisa',
      1 => 'Historico',
      2 => 'Biblioteca',
      _ => "",
    };
  }

  FutureOr<Widget> _suggestionsBuilder(BuildContext context, CustomSearchController controller) async {
    return ValueListenableBuilder(
      valueListenable: _isLoading,
      builder: (context, loading, child) {
        if (!loading && _contents.isEmpty) return const SizedBox.shrink();

        return ListView.builder(
          itemCount: _contents.entries.length,
          itemBuilder: (context, index) {
            final MapEntry<Source, List<Content>> entry = _contents.entries.elementAt(index);
            return ExpansionTile(
              shape: Border(bottom: BorderSide(width: 1, color: DividerTheme.of(context).color ?? Colors.transparent)),
              title: Text(entry.key.name),
              initiallyExpanded: entry.value.isNotEmpty,
              maintainState: true,
              controlAffinity: ListTileControlAffinity.leading,
              children: <Widget>[
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: entry.value.length,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(8.0),
                    itemBuilder: (context, index) {
                      final content = entry.value[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 140,
                          child: ContentTile.search(
                            content: content,
                            onTap: (content) {
                              if (_searchController.isAttached && _searchController.isOpen) {
                                context.unFocusKeyBoard();
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchDebouncer.cancel();
    _isLoading.dispose();
    _searchController.removeListener(_searchControllerListener);
    super.dispose();
  }
}

class _BarShapeMaterialState extends WidgetStateProperty<RoundedRectangleBorder?> {
  final _defaultBarShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

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
    return BorderSide(color: colorScheme.primary.withAlpha(26));
  }
}
