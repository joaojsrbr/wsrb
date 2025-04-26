import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_popup.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/utils/category_utils.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class BottomMenu extends ImplicitlyAnimatedWidget {
  const BottomMenu({
    super.key,
    required this.child,
    this.buttons,
    this.isDismissible = false,
    this.bottomMenuController,
  }) : super(duration: const Duration(milliseconds: 350));

  final BottomMenuController? bottomMenuController;
  final WidgetBuilder? buttons;
  final bool isDismissible;
  final Widget child;

  static BottomMenuController? menuControllerMaybeOf(BuildContext context) {
    return _BottomMenuControllerScope.maybeOf(context)?.notifier;
  }

  static BottomMenuController menuControllerOf(BuildContext context) {
    return _BottomMenuControllerScope.of(context).notifier!;
  }

  @override
  ImplicitlyAnimatedWidgetState<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends AnimatedWidgetBaseState<BottomMenu> {
  late final BottomMenuController _railMenuController;
  @override
  void initState() {
    _railMenuController =
        (widget.bottomMenuController ?? BottomMenuController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _BottomMenuControllerScope(
      notifier: _railMenuController,
      child: Builder(
        builder: (context) {
          final railMenuController = BottomMenu.menuControllerOf(context);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  fit: StackFit.expand,
                  children: [
                    widget.child,
                    if (widget.isDismissible && railMenuController.isOpen)
                      AnimatedModalBarrier(
                        barrierSemanticsDismissible: railMenuController.isOpen,
                        color: animation.drive(
                          ColorTween(
                            begin: Colors.black54,
                            end: Colors.black54,
                          ).chain(
                            CurveTween(curve: Curves.ease),
                          ),
                        ),
                        onDismiss: () {
                          final ValueNotifierList valueNotifierList =
                              context.read<ValueNotifierList>();
                          valueNotifierList.clear();
                          railMenuController.close();
                        },
                      ),
                  ],
                ),
              ),
              CustomPopup.builder(
                show: railMenuController.isOpen,
                width: MediaQuery.sizeOf(context).width,
                // color: Colors.transparent,
                shape: RoundedRectangleBorder(),
                startAnimatedAlignment: Alignment.bottomCenter,
                duration: const Duration(milliseconds: 450),
                height: railMenuController._menuSize.height,
                builder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child:
                      widget.buttons?.call(context) ?? const _LibraryButtons(),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _railMenuController
      ..close()
      ..dispose();

    super.dispose();
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {}
}

class _BottomMenuControllerScope
    extends InheritedNotifier<BottomMenuController> {
  const _BottomMenuControllerScope({
    required super.child,
    required super.notifier,
  });

  static _BottomMenuControllerScope of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_BottomMenuControllerScope>()!;
  }

  static _BottomMenuControllerScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_BottomMenuControllerScope>();
  }

  @override
  bool updateShouldNotify(_BottomMenuControllerScope oldWidget) {
    return notifier?.isOpen != oldWidget.notifier?.isOpen ||
        notifier?.menuSize != oldWidget.notifier?.menuSize;
  }
}

class BottomMenuController<T> extends ChangeNotifier {
  BottomMenuController({
    bool opened = false,
    double minHeight = 50,
  }) {
    _openMenu = opened;
    _menuSize = Size.fromHeight(minHeight);
  }

  late Size _menuSize;

  T? args;

  Size get menuSize => _menuSize;

  void Function()? _onClose;

  void open({void Function()? onClose}) {
    _openMenu = true;
    _onClose = onClose;
    notifyListeners();
  }

  void close() {
    _openMenu = false;
    _onClose?.call();
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
    final LibraryController libraryController =
        context.read<LibraryController>();
    final ContentRepository repository = context.read<ContentRepository>();
    final ValueNotifierList valueNotifierList =
        context.watch<ValueNotifierList>();
    final libraryRepo = libraryController.repo;

    final TabController tabController = HomeScope.of(context).tabController;

    return Row(
      spacing: 8,
      textDirection: Directionality.of(context),
      // overflowAlignment: OverflowBarAlignment.center,
      children: [
        if (tabController.index != 1)
          IconButton(
            onPressed: () async {
              final allSelected = repository
                  .where(
                      (element) => valueNotifierList.contains(element.stringID))
                  .toList()
                  .unique((content) => content.stringID);
              valueNotifierList.clear();

              final contentEntities = (await Future.wait(
                allSelected.map(
                  (content) => repository.getData(content).then(
                      (result) => result.fold(onSuccess: (success) => success)),
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
              final List<Entity> removeEntities = libraryRepo.entities
                  .where(
                    (element) => valueNotifierList.contains(
                      libraryRepo.getStringID(element),
                    ),
                  )
                  .toList()
                  .unique((content) => content.id);

              final removeIDS = <CategoryEntity>{};

              for (final category in categoryController.categories) {
                final id = libraryRepo.favoritesIDS
                    .firstWhereOrNull((id) => category.ids.contains(id));

                if (id != null) {
                  final newIDS = List<String>.from(category.ids);
                  newIDS.remove(id);

                  removeIDS.add(
                    category.copyWith(
                      ids: newIDS,
                      updatedAt: DateTime.now(),
                    ),
                  );
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
            onPressed:
                libraryRepo.favoritesIDS.containsOneElement(valueNotifierList)
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
    );
  }
}
