import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/utils/category_utils.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class RailMenu extends StatefulWidget {
  const RailMenu({
    super.key,
    required this.child,
    this.buttons,
    this.railMenuController,
  });

  final RailMenuController? railMenuController;
  final WidgetBuilder? buttons;
  final Widget child;

  static RailMenuController? menuControllerMaybeOf(BuildContext context) {
    return _RailMenuControllerScope.maybeOf(context)?.notifier;
  }

  static RailMenuController menuControllerOf(BuildContext context) {
    return _RailMenuControllerScope.of(context).notifier!;
  }

  @override
  State<RailMenu> createState() => _RailMenuState();
}

class _RailMenuState extends State<RailMenu> {
  late final RailMenuController _railMenuController;

  @override
  void initState() {
    _railMenuController = (widget.railMenuController ?? RailMenuController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _RailMenuControllerScope(
      notifier: _railMenuController,
      child: Builder(builder: (context) {
        final railMenuController = RailMenu.menuControllerOf(context);
        return Stack(
          children: [
            Positioned.fill(child: widget.child),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              right: 0,
              width: railMenuController.isOpen
                  ? railMenuController.menuSize.width
                  : 0,
              child: widget.buttons?.call(context) ?? const _LibraryButtons(),
            )
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _railMenuController
      ..close()
      ..dispose();

    super.dispose();
  }
}

class _RailMenuControllerScope extends InheritedNotifier<RailMenuController> {
  const _RailMenuControllerScope({
    required super.child,
    required super.notifier,
  });

  static _RailMenuControllerScope of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_RailMenuControllerScope>()!;
  }

  static _RailMenuControllerScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_RailMenuControllerScope>();
  }

  @override
  bool updateShouldNotify(_RailMenuControllerScope oldWidget) {
    return notifier?.isOpen != oldWidget.notifier?.isOpen ||
        notifier?.menuSize != oldWidget.notifier?.menuSize;
  }
}

class RailMenuController extends ChangeNotifier {
  RailMenuController({bool? opened, double minWidth = 50}) {
    _openMenu = opened ?? false;
    _menuSize = Size.fromWidth(minWidth);
  }

  late Size _menuSize;

  Size get menuSize => _menuSize;

  void open() {
    _openMenu = true;
    notifyListeners();
  }

  void close() {
    _openMenu = false;
    notifyListeners();
  }

  void toogle() {
    _openMenu = !_openMenu;
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
    final LibraryService libraryService =
        LibraryService(libraryController, context.watch());

    final ScrollableState scrollable = Scrollable.of(
      context,
      axis: Axis.vertical,
    );
    final TabController tabController = HomeScope.of(context).tabController;

    return AnimatedBuilder(
      animation: scrollable.position,
      builder: (context, child) {
        double paddingPercent = 0.0;

        switch (tabController.index) {
          case 0:
            paddingPercent = ((scrollable.position.pixels -
                        ((libraryService.favorites.isEmpty ||
                                libraryService.favorites.isEmpty)
                            ? 150
                            : 330))
                    .clamp(0.0, 100) /
                100);
            break;
          case 1:
            paddingPercent = ((scrollable.position.pixels -
                        ((libraryService.favorites.isEmpty ||
                                libraryService.favorites.isEmpty)
                            ? 150
                            : 200))
                    .clamp(0.0, 100) /
                100);
            break;
        }

        if (tabController.index == 0) {}

        final padding = (100 * paddingPercent).clamp(10.0, 50.0);

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
                      valueNotifierList.clear();

                      final contentEntities = (await Future.wait(
                        allSelected.map(
                          (content) => repository.getData(content).then(
                              (result) =>
                                  result.fold(onSuccess: (success) => success)),
                        ),
                      ))
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
                    },
                    icon: FadeThroughTransitionSwitcher(
                      enableSecondChild: valueNotifierList.length > 1,
                      duration: const Duration(milliseconds: 250),
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
                                  libraryService.getStringID(element),
                                ),
                              )
                              .toList()
                              .unique((content) => content.id);

                      final removeIDS = <CategoryEntity>{};

                      for (final category in categoryController.categories) {
                        final id = libraryService.favoritesIDS.firstWhereOrNull(
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
                      enableSecondChild: valueNotifierList.length > 1,
                      duration: const Duration(milliseconds: 250),
                      secondChild: Icon(MdiIcons.minusBoxMultiple),
                      child: Icon(MdiIcons.minusBox),
                    ),
                  ),
                  IconButton(
                    onPressed: libraryService.favoritesIDS
                            .any((id) => valueNotifierList.contains(id))
                        ? () {
                            CategoryUtils.selectCategory(context);
                          }
                        : null,
                    icon: FadeThroughTransitionSwitcher(
                      enableSecondChild: valueNotifierList.length > 1,
                      duration: const Duration(milliseconds: 250),
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
