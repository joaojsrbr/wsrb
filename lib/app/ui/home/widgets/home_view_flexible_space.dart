import 'dart:async';

import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/home/view/home_view.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_search_anchor.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      if (query.isEmpty) _unFocus(context);
      setStateIfMounted(_contents.clear);
    }

    _searchDebouncer.cancel();
    if (query.length > 4) {
      _searchDebouncer.call(() {
        _searchContents(query);
      });
    }
  }

  @override
  void dispose() {
    _searchDebouncer.cancel();
    _isLoading.dispose();
    _searchController?.removeListener(_searchControllerListener);
    super.dispose();
  }

  Future<void> _searchContents(String query) async {
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

  FutureOr<Widget> _suggestionsBuilder(
    BuildContext context,
    CustomSearchController controller,
  ) async {
    final ThemeData themeData = Theme.of(context);

    final TextTheme textTheme = themeData.textTheme;
    final borderRadius = BorderRadius.circular(12);
    return ValueListenableBuilder(
      valueListenable: _isLoading,
      builder: (context, loading, child) {
        if (!loading && _contents.isNotEmpty) {
          return ListView.builder(
            itemCount: _contents.entries.length,
            itemBuilder: (context, index) {
              final entry = _contents.entries.elementAt(index);
              return ExpansionTile(
                title: Text(entry.key.name),
                initiallyExpanded: true,
                maintainState: true,
                controlAffinity: ListTileControlAffinity.leading,
                children: <Widget>[
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      itemCount: entry.value.length,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(8.0),
                      itemBuilder: (context, index) {
                        final content = entry.value[index];
                        return Padding(
                          padding: EdgeInsets.only(left: index > 0 ? 6 : 0),
                          child: SizedBox(
                            width: 160,
                            height: 220,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: borderRadius,
                                  child: ShaderMask(
                                    blendMode: BlendMode.srcOver,
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        begin: Alignment.center,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black38.withOpacity(0.75),
                                        ],
                                        stops: const [0.0, .94],
                                      ).createShader(bounds);
                                    },
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      maxHeightDiskCache: 612,
                                      maxWidthDiskCache: 480,
                                      errorWidget: (context, url, error) {
                                        return const Card.filled(
                                          shape: RoundedRectangleBorder(),
                                        );
                                      },
                                      imageUrl: content.imageUrl,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  left: 0,
                                  child: Container(
                                    alignment: Alignment.topLeft,
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                      top: 12,
                                      right: 8,
                                    ),
                                    child: AnimatedDefaultTextStyle(
                                      duration:
                                          const Duration(milliseconds: 350),
                                      style: (textTheme.titleMedium ??
                                              const TextStyle())
                                          .copyWith(fontSize: 16),
                                      child: Text(
                                        content.title,
                                        maxLines: 2,
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  borderRadius: borderRadius,
                                  child: InkWell(
                                    borderRadius: borderRadius,
                                    overlayColor: _OverlayColor(content),
                                    onTap: () {
                                      customLog(
                                        'InkWell tapped title: ${content.title} - id: ${content.stringID}',
                                      );
                                      context.push(
                                        RouteName.CONTENTINFO,
                                        extra: ContentInformationArgs(
                                          content: content,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
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
        }

        return const SizedBox.shrink();
      },
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
          duration: const Duration(milliseconds: 350),
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

class _OverlayColor extends WidgetStateProperty<Color?> {
  _OverlayColor(this.content) {
    if (content is Anime) {
      _color = ((content as Anime).isDublado ||
              content.title.toLowerCase().contains('dublado'))
          ? Colors.blue
          : Colors.red;
    }
  }

  Color? _color;

  final Content content;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) {
      return _color?.withOpacity(0.12);
    } else if (states.contains(WidgetState.hovered)) {
      return _color?.withOpacity(0.08);
    } else if (states.contains(WidgetState.focused)) {
      return Colors.transparent;
    }
    return Colors.transparent;
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
