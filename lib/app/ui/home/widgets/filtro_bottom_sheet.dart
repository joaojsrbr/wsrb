import 'package:app_wsrb_jsr/app/ui/shared/widgets/filtro_dias_com_infinito.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FiltroBottomSheetRoute extends PopupRoute<FilterWatching> {
  FiltroBottomSheetRoute({
    required this.appConfigController,
    required this.bottomSheetAnimationController,
    this.onlyFavorites = false,
  });

  final bool onlyFavorites;
  final AnimationController bottomSheetAnimationController;
  final AppConfigController appConfigController;

  @override
  Color? get barrierColor => Colors.black26;
  // @override
  // Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  bool get opaque => false;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  bool didPop(FilterWatching? result) => super.didPop(newFilterWatching);

  void _handleFiltroDeDias(DateTime? start, DateTime? end, bool dataInfinita) {
    newFilterWatching = newFilterWatching.copyWith(start: start, end: end, infiniteDate: dataInfinita);
    _updateFilter();
  }

  void _handleLimparFiltroDeDias() {
    newFilterWatching = newFilterWatching.copyWith(start: DateTime(0), end: DateTime(0), infiniteDate: false);
    _updateFilter();
  }

  void _handleGenresFilterChipSelector(List<String> data) {
    newFilterWatching = newFilterWatching.copyWith(genresFilter: data);
    _updateFilter();
  }

  void _handleSourceFilterChipSelector(List<Source> data) {
    if (data.isNotEmpty) {
      newFilterWatching = newFilterWatching.copyWith(filterSources: data);
    } else {
      newFilterWatching = newFilterWatching.copyWith(filterSources: []);
    }
    _updateFilter();
  }

  void _updateFilter() {
    appConfigController.setFilterWatching(newFilterWatching);
    newFilterWatching = appConfigController.config.filterWatching;
  }

  late FilterWatching newFilterWatching = appConfigController.config.filterWatching;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final appConfigController = context.watch<AppConfigController>();
    final libraryController = context.watch<LibraryController>();

    final libraRepo = libraryController.repo;
    final entities = onlyFavorites ? libraRepo.favorites : libraRepo.noFavorites;

    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final genres = entities.map((content) => content.anilistMedia?.genres).nonNulls.flattened.toList();
    final filterWatching = appConfigController.config.filterWatching;
    return StatefulBuilder(
      builder: (context, setState) {
        return DraggableScrollableSheet(
          // showDragHandle: true,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          initialChildSize: 0.6,
          // animationController: bottomSheetAnimationController,
          // onClosing: () => Navigator.pop(context),
          builder: (context, controller) {
            return Material(
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        BackButton(),
                        Center(child: Text("Filtro", style: titleStyle)),
                      ],
                    ),
                    Divider(),
                    FiltroDiasComInfinito(
                      onChanged: _handleFiltroDeDias,
                      onClear: _handleLimparFiltroDeDias,
                      isInfinite: filterWatching.infiniteDate,
                      current: filterWatching.end != null
                          ? DateTimeRange(
                              start: filterWatching.start ?? DateTime(DateTime.now().year, DateTime.january, 1),
                              end: filterWatching.end ?? DateTime.now(),
                            )
                          : null,
                    ),
                    FilterChipSelector(
                      limpar: RawChip(
                        onPressed: () {
                          appConfigController.setFilterWatching(
                            filterWatching.copyWith(
                              filterSources: filterWatching.filterSources.isEmpty ? Source.values : [],
                            ),
                          );
                        },
                        label: filterWatching.filterSources.isEmpty ? const Text("Reset") : const Text("Limpar"),
                        padding: EdgeInsets.zero,
                      ),
                      title: "Fonte",
                      initialSelected: filterWatching.filterSources,
                      filter: Source.list,
                      filterToString: (data) => data.label,
                      onChanged: _handleSourceFilterChipSelector,
                    ),
                    if (genres.isNotEmpty)
                      FilterChipSelector(
                        limpar: filterWatching.genresFilter.isEmpty
                            ? const SizedBox.shrink()
                            : RawChip(
                                isEnabled: filterWatching.genresFilter.isNotEmpty,
                                onPressed: () {
                                  // newFilterWatching = newFilterWatching.copyWith(genresFilter: );
                                  appConfigController.setFilterWatching(
                                    // filterWatching.copyWith(
                                    //   genresFilter: filterWatching.genresFilter.isEmpty ? genres.unique() : [],
                                    // ),
                                    filterWatching.copyWith(genresFilter: []),
                                  );
                                },
                                label: const Text("Limpar"),
                                padding: EdgeInsets.zero,
                              ),
                        title: "Generos",
                        filterToString: (data) => data,
                        filter: genres.unique(),
                        initialSelected: filterWatching.genresFilter,
                        onChanged: _handleGenresFilterChipSelector,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Animação de deslizar de baixo para cima
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: child,
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
  State<FilterChipSelector<T>> createState() => FiltereChipSelectorState<T>();
}

class FiltereChipSelectorState<T> extends State<FilterChipSelector<T>> {
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
