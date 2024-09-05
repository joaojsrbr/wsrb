import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_search_anchor.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/item_content.dart';
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

  final Map<Source, List<Content>> _contents = {};

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
    final query = _searchController!.text.trim();

    if (!_searchController!.isOpen) {
      if (query.isEmpty) context.unFocusKeyBoard();

      setStateIfMounted(_contents.clear);
    }

    _searchDebouncer.cancel();
    if (query.length >= 4) {
      _searchDebouncer.call(() {
        _searchContents(query);
      });
    }
  }

  Future<void> _searchContents(String query, [forceSearch = false]) async {
    if (_contents.values.flattened.any((content) =>
            content.title.toLowerCase().contains(query.toLowerCase())) &&
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
    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    final CustomSearchController searchController =
        HomeScope.of(context).searchController;
    final TabController tabController = HomeScope.of(context).tabController;

    final ValueNotifierList valueNotifierList =
        context.watch<ValueNotifierList>();

    final ConnectionChecker connectionChecker =
        context.watch<ConnectionChecker>();
    return IgnorePointer(
      ignoring: tabController.index == 2 ||
          valueNotifierList.isNotEmpty ||
          (!connectionChecker.hasConnection && tabController.index == 1),
      child: CustomSearchAnchor(
        onSubmitted: (value) {
          if (value.length >= 4 && !searchController.isOpen) {
            searchController.openView();
          }
          if (value.length >= 4) {
            _searchDebouncer.cancel();
            _searchContents(value, true);
          }
        },
        dividerWidget: AnimatedBuilder(
          animation: _isLoading,
          child: const LinearProgressIndicator(minHeight: 2),
          builder: (context, child) =>
              _isLoading.value ? child! : const Divider(height: 2),
        ),
        onChanged: (String value) {
          if (tabController.index != 0) return;
          if (value.trim().isEmpty && searchController.isOpen) {
            searchController.closeView(value);
          } else if (value.trim().length >= 4) {
            searchController.openView();
          }
        },
        barTrailing: [
          AnimatedBuilder(
            animation: searchController,
            builder: (context, child) {
              return FadeThroughTransitionSwitcher(
                enableSecondChild: tabController.index != 1 ||
                    searchController.text.trim().isEmpty,
                duration: const Duration(seconds: 1),
                child: IconButton(
                  onPressed: () {
                    searchController.clear();
                    context.unFocusKeyBoard();
                  },
                  icon: Icon(MdiIcons.close),
                ),
              );
            },
          )
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

  FutureOr<Widget> _suggestionsBuilder(
    BuildContext context,
    CustomSearchController controller,
  ) async {
    // final ThemeData themeData = Theme.of(context);

    // final TextTheme textTheme = themeData.textTheme;
    // final BorderRadius borderRadius = BorderRadius.circular(12);
    return ValueListenableBuilder(
      valueListenable: _isLoading,
      builder: (context, loading, child) {
        if (!loading && _contents.isEmpty) return const SizedBox.shrink();

        return ListView.builder(
          itemCount: _contents.entries.length,
          itemBuilder: (context, index) {
            final MapEntry<Source, List<Content>> entry =
                _contents.entries.elementAt(index);
            return Theme(
              data: Theme.of(context).copyWith(),
              child: ExpansionTile(
                shape: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: DividerTheme.of(context).color ?? Colors.transparent,
                  ),
                ),
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
                            child: ItemContent.search(
                              content: content,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
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
    _searchController?.removeListener(_searchControllerListener);
    super.dispose();
  }
}

// class _OverlayColor extends WidgetStateProperty<Color?> {
//   _OverlayColor(this.content) {
//     if (content is Anime) {
//       _color = ((content as Anime).isDublado ||
//               content.title.toLowerCase().contains('dublado'))
//           ? Colors.blue
//           : Colors.red;
//     }
//   }

//   Color? _color;

//   final Content content;

//   @override
//   Color? resolve(Set<WidgetState> states) {
//     if (states.contains(WidgetState.pressed)) {
//       return _color?.withOpacity(0.12);
//     } else if (states.contains(WidgetState.hovered)) {
//       return _color?.withOpacity(0.08);
//     } else if (states.contains(WidgetState.focused)) {
//       return Colors.transparent;
//     }
//     return Colors.transparent;
//   }
// }

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
      color: colorScheme.primary.withAlpha(26),
    );
  }
}
