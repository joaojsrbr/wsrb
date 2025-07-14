import 'package:app_wsrb_jsr/app/ui/shared/widgets/filtro_dias_com_infinito.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';

class FiltroBottomSheetRoute extends PopupRoute<FilterWatching> {
  FiltroBottomSheetRoute({
    required this.appConfigController,
    required this.bottomSheetAnimationController,
    required this.genres,
  });
  final List<String> genres;
  final AnimationController bottomSheetAnimationController;
  final AppConfigController appConfigController;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  bool didPop(FilterWatching? result) {
    final result = newFilterWatching;

    if (result.genresFilter.isEmpty) result.genresFilter.addAll(genres);
    return super.didPop(result);
  }

  FilterWatching get _filterWatching =>
      appConfigController.config.filterWatching;

  void _handleFiltroDeDias(
    DateTime? start,
    DateTime? end,
    bool dataInfinita,
  ) {
    newFilterWatching = newFilterWatching.copyWith(
      start: start,
      end: end,
      infiniteDate: dataInfinita,
    );
  }

  void _handleLimparFiltroDeDias() {
    newFilterWatching = newFilterWatching.copyWith(
      start: DateTime(0),
      end: DateTime(0),
      infiniteDate: false,
    );
  }

  void _handleGenresFilterChipSelector(List<String> data) {
    newFilterWatching = newFilterWatching.copyWith(genresFilter: data);
  }

  void _handleSourceFilterChipSelector(List<String> data) {
    newFilterWatching = newFilterWatching.copyWith();
  }

  late FilterWatching newFilterWatching = _filterWatching;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return BottomSheet(
      animationController: bottomSheetAnimationController,
      onClosing: () {},
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
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
              isInfinite: _filterWatching.infiniteDate,
              current: _filterWatching.end != null
                  ? DateTimeRange(
                      start: _filterWatching.start ??
                          DateTime(DateTime.now().year, DateTime.january, 1),
                      end: _filterWatching.end ?? DateTime.now(),
                    )
                  : null,
            ),
            FilterChipSelector(
              title: "Generos",
              genres: genres.unique(),
              initialSelected: _filterWatching.genresFilter,
              onChanged: _handleGenresFilterChipSelector,
            ),
            FilterChipSelector(
              title: "Fonte",
              genres: Source.list.map((e) => e.label).toList(),
              onChanged: _handleSourceFilterChipSelector,
            ),
          ],
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
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      )),
      child: child,
    );
  }
}

class FilterChipSelector extends StatefulWidget {
  const FilterChipSelector({
    super.key,
    required this.genres,
    this.initialSelected = const [],
    this.onChanged,
    required this.title,
  });
  final String title;
  final List<String> genres;
  final List<String> initialSelected;
  final ValueChanged<List<String>>? onChanged;

  @override
  State<FilterChipSelector> createState() => FiltereChipSelectorState();
}

class FiltereChipSelectorState extends State<FilterChipSelector> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    if (widget.initialSelected.isNotEmpty) {
      _selected = List.from(widget.initialSelected);
    } else {
      _selected = List.from(widget.genres);
    }
  }

  void _onChipTapped(String genre) {
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
          Text(
            widget.title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 0,
            children: widget.genres.map((genre) {
              final selected = _selected.contains(genre);
              return ChoiceChip(
                padding: EdgeInsets.zero,
                label: Text(genre),
                selected: selected,
                onSelected: (_) => _onChipTapped(genre),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
