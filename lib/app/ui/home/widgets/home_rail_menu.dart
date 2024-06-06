import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/home/view/home_view.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/utils/category_utils.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class HomeRailMenu extends StatefulWidget {
  const HomeRailMenu({
    super.key,
    required this.child,
    this.railMenuController,
  });

  final RailMenuController? railMenuController;
  final Widget child;

  // static RailMenuController? menuControllerMaybeOf(BuildContext context) {
  //   return context
  //       .findAncestorStateOfType<_HomeRailMenuState>()
  //       ?._railMenuController;
  // }

  static RailMenuController menuControllerOf(BuildContext context) {
    return _RailMenuControllerScope.of(context).railMenuController;
  }

  @override
  State<HomeRailMenu> createState() => _HomeRailMenuState();
}

class _HomeRailMenuState extends State<HomeRailMenu> {
  late final RailMenuController _railMenuController;

  @override
  void initState() {
    _railMenuController = (widget.railMenuController ?? RailMenuController())
      ..addListener(_listener);
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void _listener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // final sizeOf = MediaQuery.sizeOf(context);

    return _RailMenuControllerScope(
      railMenuController: _railMenuController,
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            right: 0,
            width: _railMenuController.isOpen ? 50 : 0,
            child: const _LibraryButtons(),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _railMenuController.removeListener(_listener);

    super.dispose();
  }
}

class _RailMenuControllerScope extends InheritedWidget {
  const _RailMenuControllerScope({
    required super.child,
    required this.railMenuController,
  });

  final RailMenuController railMenuController;

  static _RailMenuControllerScope of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_RailMenuControllerScope>()!;
  }

  @override
  bool updateShouldNotify(_RailMenuControllerScope oldWidget) {
    return true;
  }
}

class RailMenuController extends ChangeNotifier {
  RailMenuController({bool? opened}) {
    _openMenu = opened ?? false;
  }

  Size? _menuSize;

  Size get menuSize => _menuSize ?? Size.zero;

  void _setMenuSize([double? width]) {
    _menuSize = Size.fromWidth(width ?? 50);
  }

  // final GlobalKey _container = GlobalKey();

  void open() {
    _openMenu = true;
    _setMenuSize();
    notifyListeners();
  }

  void close() {
    _openMenu = false;
    _setMenuSize();
    notifyListeners();
  }

  void toogle() {
    _openMenu = !_openMenu;
    _setMenuSize();
    notifyListeners();
  }

  bool get isOpen => _openMenu;

  bool _openMenu = false;
}

class _LibraryButtons extends StatelessWidget {
  const _LibraryButtons();

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final LibraryController libraryController =
        context.read<LibraryController>();
    final ContentRepository repository = context.read<ContentRepository>();
    final ValueNotifierList valueNotifierList =
        context.watch<ValueNotifierList>();

    final ScrollableState scrollable = Scrollable.of(context);
    final TabController tabController = HomeScope.of(context).tabController;
    return AnimatedBuilder(
      animation: scrollable.position,
      builder: (context, child) {
        final paddingPercent =
            ((scrollable.position.pixels).clamp(0.0, 100) / 100);

        final padding = (100 * paddingPercent).clamp(10.0, 100.0);
        // ((tabController.index == 1 ? 100 : 100) * paddingPercent)
        //     .clamp(10.0, tabController.index == 1 ? 100.0 : 100.0);
        return Padding(
          padding: EdgeInsets.only(top: padding),
          child: Card.filled(
            color: themeData.colorScheme.primary.withOpacity(0.04),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: OverflowBar(
              spacing: 8,
              textDirection: Directionality.of(context),
              overflowAlignment: OverflowBarAlignment.center,
              children: [
                if (tabController.index != 1)
                  IconButton(
                    onPressed: () async {
                      final allSelected = repository
                          .where((element) =>
                              valueNotifierList.contains(element.stringID))
                          .toList()
                          .unique((content) => content.stringID);
                      final contentEntities = allSelected
                          .map(
                            (e) => switch (e) {
                              Anime data => data.toEntity(isFavorite: true),
                              Book data => data.toEntity(isFavorite: true),
                              _ => null,
                            },
                          )
                          .nonNulls
                          .toList();

                      await libraryController.addAll(
                        contentEntities: contentEntities,
                      );
                      valueNotifierList.clear();
                    },
                    icon: FadeThroughTransitionSwitcher(
                      enableSecondChild: valueNotifierList.length != 1,
                      duration: const Duration(milliseconds: 450),
                      secondChild: Icon(MdiIcons.plusBoxMultiple),
                      child: Icon(MdiIcons.plusBox),
                    ),
                  )
                else ...[
                  IconButton(
                    onPressed: () async {
                      final CategoryController categoryController =
                          context.read<CategoryController>();
                      final List<Entity> removeEntities =
                          libraryController.entities
                              .where(
                                (element) => valueNotifierList.contains(
                                  libraryController.getStringID(element),
                                ),
                              )
                              .toList()
                              .unique((content) => content.id);

                      final removeIDS = <CategoryEntity>{};

                      for (final category in categoryController.categories) {
                        final id = libraryController.favoritesIDS
                            .firstWhereOrNull(
                                (id) => category.ids.contains(id));

                        if (id != null) {
                          final newIDS = List<String>.from(category.ids);
                          newIDS.remove(id);
                          category.ids = newIDS;
                          category.updatedAt = DateTime.now();
                          removeIDS.add(category);
                        }
                      }

                      final futures = [
                        ...removeIDS.map((e) => categoryController.add(e)),
                        libraryController.removeAll(
                          contentEntities: removeEntities.cast(),
                        ),
                      ];

                      await Future.wait(futures);

                      valueNotifierList.clear();
                    },
                    icon: FadeThroughTransitionSwitcher(
                      enableSecondChild: valueNotifierList.length != 1,
                      duration: const Duration(milliseconds: 450),
                      secondChild: Icon(MdiIcons.minusBoxMultiple),
                      child: Icon(MdiIcons.minusBox),
                    ),
                  ),
                  IconButton(
                    onPressed: libraryController.favoritesIDS
                            .any((id) => valueNotifierList.contains(id))
                        ? () {
                            final CategoryUtils utils = CategoryUtils();
                            utils.selectCategory(context);
                          }
                        : null,
                    icon: FadeThroughTransitionSwitcher(
                      enableSecondChild: valueNotifierList.length != 1,
                      duration: const Duration(milliseconds: 450),
                      secondChild: Icon(MdiIcons.tagMultiple),
                      child: Icon(MdiIcons.tag),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
