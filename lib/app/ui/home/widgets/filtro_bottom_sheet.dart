import 'package:app_wsrb_jsr/app/ui/shared/widgets/filtro_dias_com_infinito.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FiltroBottomSheet extends StatefulWidget {
  const FiltroBottomSheet({super.key});

  @override
  State<FiltroBottomSheet> createState() => FiltroBottomSheetState();

  static FiltroBottomSheetState of(BuildContext context) =>
      context.findAncestorStateOfType<FiltroBottomSheetState>()!;
}

class FiltroBottomSheetState extends State<FiltroBottomSheet> {
  late final AppConfigController _appConfigController;
  late FilterWatching _newFilterWatching;
  bool _onlyFavorites = false;

  @override
  void initState() {
    _appConfigController = context.read<AppConfigController>();
    _newFilterWatching = _appConfigController.config.filterWatching;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final args = ModalRoute.of(context)?.settings.arguments;

    _onlyFavorites = args != null;

    super.didChangeDependencies();
  }

  void _handleFiltroDeDias(DateTime? start, DateTime? end, bool dataInfinita) {
    _newFilterWatching = _newFilterWatching.copyWith(
      start: start,
      end: end,
      infiniteDate: dataInfinita,
    );
    _updateFilter();
  }

  void _handleLimparFiltroDeDias() {
    _newFilterWatching = _newFilterWatching.copyWith(
      start: DateTime(0),
      end: DateTime(0),
      infiniteDate: false,
    );
    _updateFilter();
  }

  void _handleGenresFilterChipSelector(List<String> data) {
    _newFilterWatching = _newFilterWatching.copyWith(genresFilter: data);
    _updateFilter();
  }

  void _handleSourceFilterChipSelector(List<Source> data) {
    if (data.isNotEmpty) {
      _newFilterWatching = _newFilterWatching.copyWith(filterSources: data);
    } else {
      _newFilterWatching = _newFilterWatching.copyWith(filterSources: []);
    }
    _updateFilter();
  }

  void _updateFilter() {
    _appConfigController.setFilterWatching(_newFilterWatching);
    _newFilterWatching = _appConfigController.config.filterWatching;
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final shape = context.findAncestorWidgetOfExactType<Material>()?.shape;

    return DefaultTabController(
      length: 2,
      child: Material(
        shape: shape,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: TabBar(
                  tabs: [
                    Tab(height: 52, child: Text("Geral", style: titleStyle)),
                    Tab(height: 52, child: Text("test", style: titleStyle)),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _Page1(),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Page1 extends StatelessWidget {
  const _Page1();

  @override
  Widget build(BuildContext context) {
    final state = FiltroBottomSheet.of(context);
    final onlyFavorites = state._onlyFavorites;
    final handleFiltroDeDias = state._handleFiltroDeDias;
    final handleLimparFiltroDeDias = state._handleLimparFiltroDeDias;
    final newFilterWatching = state._newFilterWatching;
    final appConfigController = state._appConfigController;
    final handleSourceFilterChipSelector = state._handleSourceFilterChipSelector;
    final handleGenresFilterChipSelector = state._handleGenresFilterChipSelector;

    final libraryController = context.watch<LibraryController>();

    final libraRepo = libraryController.repo;
    final entities = onlyFavorites ? libraRepo.favorites : libraRepo.noFavorites;

    final genres = entities
        .map((content) => content.anilistMedia?.genres)
        .nonNulls
        .flattened
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        customLog(constraints);
        return Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FiltroDiasComInfinito(
                onChanged: handleFiltroDeDias,
                onClear: handleLimparFiltroDeDias,
                isInfinite: newFilterWatching.infiniteDate,
                current: newFilterWatching.end != null
                    ? DateTimeRange(
                        start:
                            newFilterWatching.start ??
                            DateTime(DateTime.now().year, DateTime.january, 1),
                        end: newFilterWatching.end ?? DateTime.now(),
                      )
                    : null,
              ),
              FilterChipSelector(
                limpar: RawChip(
                  onPressed: () {
                    appConfigController.setFilterWatching(
                      newFilterWatching.copyWith(
                        filterSources: newFilterWatching.filterSources.isEmpty
                            ? Source.values
                            : [],
                      ),
                    );
                  },
                  label: newFilterWatching.filterSources.isEmpty
                      ? const Text("Reset")
                      : const Text("Limpar"),
                  padding: EdgeInsets.zero,
                ),
                title: "Fonte",
                initialSelected: newFilterWatching.filterSources,
                filter: Source.list,
                filterToString: (data) => data.label,
                onChanged: handleSourceFilterChipSelector,
              ),
              if (genres.isNotEmpty)
                FilterChipSelector(
                  limpar: newFilterWatching.genresFilter.isEmpty
                      ? const SizedBox.shrink()
                      : RawChip(
                          isEnabled: newFilterWatching.genresFilter.isNotEmpty,
                          onPressed: () {
                            appConfigController.setFilterWatching(
                              newFilterWatching.copyWith(genresFilter: []),
                            );
                          },
                          label: const Text("Limpar"),
                          padding: EdgeInsets.zero,
                        ),
                  title: "Generos",
                  filterToString: (data) => data,
                  filter: genres.unique(),
                  initialSelected: newFilterWatching.genresFilter,
                  onChanged: handleGenresFilterChipSelector,
                ),
            ],
          ),
        );
      },
    );
  }
}

class FilterChipSelector<T> extends StatefulWidget {
  const FilterChipSelector({
    super.key,
    required this.filter,
    this.initialSelected,
    this.limpar,
    this.onChanged,
    required this.title,
    required this.filterToString,
  });
  final String title;
  final Widget? limpar;
  final List<T> filter;
  final List<T>? initialSelected;
  final String Function(T data) filterToString;
  final ValueChanged<List<T>>? onChanged;

  @override
  State<FilterChipSelector<T>> createState() => _FiltereChipSelectorState<T>();
}

class _FiltereChipSelectorState<T> extends State<FilterChipSelector<T>> {
  late List<T> _selected;

  @override
  void initState() {
    super.initState();
    if (widget.initialSelected != null) {
      _selected = List.from(widget.initialSelected!);
    } else {
      _selected = List.from(widget.filter);
    }
  }

  @override
  void didUpdateWidget(covariant FilterChipSelector<T> oldWidget) {
    if (widget.initialSelected != null) {
      _selected = List.from(widget.initialSelected!);
    } else {
      _selected = List.from(widget.filter);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onChipTapped(T genre) {
    setState(() {
      if (_selected.contains(genre)) {
        _selected.remove(genre);
      } else {
        _selected.add(genre);
      }
    });
    widget.onChanged?.call(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 0,
            children: [
              ...widget.filter.map((genre) {
                final selected = _selected.contains(genre);
                return ChoiceChip(
                  padding: EdgeInsets.zero,
                  label: Text(widget.filterToString(genre)),
                  selected: selected,
                  onSelected: (_) => _onChipTapped(genre),
                );
              }),
              if (widget.limpar != null) widget.limpar!,
            ],
          ),
        ],
      ),
    );
  }
}
