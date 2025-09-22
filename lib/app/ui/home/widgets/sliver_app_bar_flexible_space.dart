import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_search_anchor.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/item_content.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer_container.dart';
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
  final _SearchIsloading _isLoading = _SearchIsloading();
  // final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final Map<Source, SearchResult> _contents = {};

  final Debouncer _searchDebouncer = Debouncer(duration: const Duration(seconds: 1));

  final ValueNotifier<SearchFilter> _filter = ValueNotifier(
    const SearchFilter(query: ""),
  );

  CustomSearchController get _searchController => widget.searchController;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchControllerListener);
    _contentRepository = context.read<ContentRepository>();
  }

  void _searchControllerListener() {
    setState(() {});
  }

  Future<void> _searchContents(
    String query, {
    int page = 1,
    required List<Source> sources,
  }) async {
    if (query.isEmpty) return;
    _isLoading.setIsloading(sources, true);

    _filter.value = _filter.value.copyWith(query: query, page: page);
    await _contentRepository.searchContents(
      _filter.value,
      searchSources: sources,
      onSuccess: (value) {
        final (source, result) = value;
        final contents = result.contents;
        setStateIfMounted(() {
          if (contents.isNotEmpty) _contents[source] = result;
          _isLoading.setIsloading([source], false);

          _contents.removeWhere((key, values) => values.contents.isEmpty);
        });
      },
    );
    _searchController.unFocusKeyBoard();
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
            _searchContents(value, sources: Source.list);
          }
        },
        dividerWidget: StatefulBuilder(
          builder: (context, _) {
            return Column(
              children: [
                _buildFilters(context),
                const SizedBox(height: 4),
                AnimatedBuilder(
                  animation: _isLoading,
                  child: const LinearProgressIndicator(minHeight: 2),
                  builder: (context, child) =>
                      _isLoading.isLoading ? child! : const Divider(height: 2),
                ),
              ],
            );
          },
        ),
        barTrailing: [
          AnimatedBuilder(
            animation: _searchController,
            builder: (context, child) {
              return FadeThroughTransitionSwitcher(
                enableSecondChild:
                    tabController.index != 1 || _searchController.text.trim().isEmpty,
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
          secondChild: IconButton(
            onPressed: valueNotifierList.clear,
            icon: Icon(MdiIcons.close),
          ),
          child: Icon(MdiIcons.magnify),
        ),
        searchController: _searchController,
        constraints: const BoxConstraints(maxHeight: 42, minHeight: 42),
        // viewConstraints: const BoxConstraints(maxHeight: 50, minHeight: 50),
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

  Widget _buildFilters(BuildContext context) {
    return ValueListenableBuilder<SearchFilter>(
      valueListenable: _filter,
      builder: (context, filter, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            height: 50,
            child: Row(
              children: [
                // _buildDropdown(
                //   label: "Genres",
                //   value: filter.genre ?? "Any",
                //   items: ["Any", "Action", "Romance", "Comedy", "Drama"],
                //   onChanged: (v) => _filter.value = filter.copyWith(genre: v),
                // ),
                _buildDropdown(
                  label: "Year",
                  value: filter.year ?? "Any",
                  items: ["Any", "2023", "2024", "2025"],
                  onChanged: (v) => _filter.value = filter.copyWith(year: v),
                ),
                _buildDropdown(
                  label: "Season",
                  value: filter.season ?? "Any",
                  items: ["Any", "Winter", "Spring", "Summer", "Fall"],
                  onChanged: (v) => _filter.value = filter.copyWith(season: v),
                ),
                _buildDropdown(
                  label: "Format",
                  value: filter.format ?? "Any",
                  items: ["Any", "TV", "Movie", "OVA"],
                  onChanged: (v) => _filter.value = filter.copyWith(format: v),
                ),
                _buildDropdown(
                  label: "Airing Status",
                  value: filter.airingStatus ?? "Any",
                  items: ["Any", "Ongoing", "Completed", "Upcoming"],
                  onChanged: (v) => _filter.value = filter.copyWith(airingStatus: v),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    double width = 120,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: width,
        child: DropdownButtonFormField<T>(
          decoration: InputDecoration(
            isDense: true,
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          value: value,
          items: items
              .map((e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  FutureOr<Widget> _suggestionsBuilder(
    BuildContext context,
    CustomSearchController controller,
  ) async {
    return AnimatedBuilder(
      animation: _isLoading,
      builder: (context, child) {
        if (!_isLoading.isLoading && _contents.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.builder(
          itemCount: _contents.entries.length,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final MapEntry<Source, SearchResult> entry = _contents.entries.elementAt(
              index,
            );
            final result = entry.value;
            final contents = entry.value.contents;
            return ExpansionTile(
              shape: Border(
                bottom: BorderSide(
                  width: 1,
                  color: DividerTheme.of(context).color ?? Colors.transparent,
                ),
              ),
              title: Text(entry.key.name),
              initiallyExpanded: true,
              maintainState: true,
              trailing: result.totalOfPages != null
                  ? ValueListenableBuilder<SearchFilter>(
                      valueListenable: _filter,
                      builder: (context, filter, _) {
                        return _buildDropdown(
                          label: "Page",
                          value: filter.page,
                          items: List.generate(
                            result.totalOfPages!,
                            (index) => index + 1,
                          ),
                          width: 80,
                          onChanged: (data) {
                            if (data != null) {
                              _searchContents(
                                filter.query,
                                page: data,
                                sources: [contents.first.source],
                              );
                            }
                          },
                        );
                      },
                    )
                  : null,
              tilePadding: EdgeInsets.symmetric(horizontal: 8.0),
              controlAffinity: ListTileControlAffinity.leading,
              children: <Widget>[
                ShimmerContainer(
                  enable: _isLoading._isLoading[entry.key] ?? false,
                  height: 200,
                  child: ListView.builder(
                    itemCount: contents.length,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(8.0),
                    itemBuilder: (context, index) {
                      final content = contents.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 140,
                          child: ContentTile.search(
                            content: content,
                            onTap: (content) {
                              if (_searchController.isAttached &&
                                  _searchController.isOpen) {
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
    _filter.dispose();
    super.dispose();
  }
}

class _BarShapeMaterialState extends WidgetStateProperty<RoundedRectangleBorder?> {
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
    return BorderSide(color: colorScheme.primary.withAlpha(26));
  }
}

final class _SearchIsloading extends ChangeNotifier {
  final Map<Source, bool> _isLoading = {};

  void setIsloading(List<Source> sources, bool value) {
    for (final source in sources) {
      _isLoading[source] = value;
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading.values.contains(true);
}
