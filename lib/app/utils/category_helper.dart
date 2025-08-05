import 'dart:collection';

import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class CategoryHelper {
  CategoryHelper._();

  static Future<void> openCategoryDialog(BuildContext context) async {
    final ValueNotifierList selection = context.read<ValueNotifierList>();
    final CategoryController controller = context.read<CategoryController>();

    final filteredCategories = controller.categories.where(
      (item) => item.ids.containsOneElement(selection),
    );

    final _CategorySelection selectionState = _CategorySelection(
      filteredCategories,
    );

    final dialogResult = await showDialog(
      context: context,
      builder: (context) => MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => selectionState)],
        builder: (context, _) {
          final selectionNotifier = context.watch<_CategorySelection>();

          return AlertDialog(
            insetPadding: const EdgeInsets.all(12),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            title: const Text('Definir Categorias'),
            content: controller.categories.isEmpty
                ? const Text('Você não tem categorias ainda.')
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(controller.categories.length, (
                        i,
                      ) {
                        final category = controller.categories.elementAt(i);
                        return CheckboxListTile.adaptive(
                          value: selectionNotifier.contains(category),
                          title: Text(category.title),
                          onChanged: (isChecked) {
                            if (isChecked != null)
                              selectionNotifier.toggle(category);
                          },
                        );
                      }),
                    ),
                  ),
            actions: [
              TextButton(
                style: const ButtonStyle(
                  visualDensity: VisualDensity(horizontal: -4),
                ),
                onPressed: () => Navigator.of(context).pop("newCategory"),
                child: controller.categories.isEmpty
                    ? const Text('Editar Categorias')
                    : const Text('Editar'),
              ),
              if (controller.categories.isNotEmpty)
                OverflowBar(
                  children: [
                    TextButton(
                      style: const ButtonStyle(
                        visualDensity: VisualDensity(horizontal: -4),
                      ),
                      onPressed: Navigator.of(context).pop,
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      style: const ButtonStyle(
                        visualDensity: VisualDensity(horizontal: -4),
                      ),
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(('applyChanges', selectionNotifier)),
                      child: const Text('OK'),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );

    if (!context.mounted) return;

    switch (dialogResult) {
      case String tag when tag.contains("newCategory"):
        selection.clear();
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await openCategoryCreator(context);
        });
        break;
      case (String tag, List<CategoryEntity> selected)
          when tag.contains('applyChanges'):
        final List<Future<void>> operations = [];

        for (final category in controller.categories) {
          final shouldRetain =
              selected.contains(category) &&
              category.ids.containsOneElement(selection);
          if (!shouldRetain) {
            final newIds = List<String>.from(category.ids)
              ..removeWhere(selection.contains)
              ..unique();

            operations.add(
              controller.add(
                category.copyWith(ids: newIds, updatedAt: DateTime.now()),
              ),
            );
          }
        }

        for (final category in selected) {
          final newIds = List<String>.from(category.ids)
            ..addAll(selection)
            ..unique();

          operations.add(
            controller.add(
              category.copyWith(ids: newIds, updatedAt: DateTime.now()),
            ),
          );
        }

        await Future.wait(operations);
        selection.clear();
        break;
    }
  }

  static Future<void> openCategoryCreator(
    BuildContext context, [
    CategoryEntity? entity,
  ]) async {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final updateEntity = ValueNotifier<CategoryEntity?>(entity);
    final states = WidgetStatesController();
    final focus = FocusNode();
    final controller = context.read<CategoryController>();
    if (entity != null) {
      textController.text = entity.title.trim();
      textController.selection = TextSelection.collapsed(
        offset: textController.text.length,
      );
    }

    void persistCategory() async {
      if (formKey.currentState?.validate() ?? false) {
        final title = textController.text.trim();
        final newEntity = CategoryEntity(
          title: title,
          createdAt: DateTime.now(),
        );
        textController.clear();
        await controller.add(newEntity);
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: textController),
          ChangeNotifierProvider.value(value: updateEntity),
          ChangeNotifierProvider.value(value: states),
          ChangeNotifierProvider.value(value: focus),
        ],
        builder: (context, _) {
          final ctrl = context.watch<TextEditingController>();
          final currentEntity = context
              .watch<ValueNotifier<CategoryEntity?>>()
              .value;
          final widgetStates = context.watch<WidgetStatesController>();

          return Form(
            key: formKey,
            child: DraggableScrollableSheet(
              minChildSize: 0.45,
              initialChildSize: 0.60,
              maxChildSize: 1.0,
              expand: false,
              builder: (context, scrollController) => SingleChildScrollView(
                controller: scrollController,
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: InkWell(
                          onTap: () => focus.requestFocus(),
                          onLongPress: () => focus.requestFocus(),
                          overlayColor: _Defaults(context).overlayColor,
                          customBorder: _InputShape()
                              .resolve(states.value)
                              ?.copyWith(
                                side:
                                    _Defaults(
                                      context,
                                    ).side?.resolve(states.value) ??
                                    BorderSide.none,
                              ),
                          statesController: widgetStates,
                          child: TextFormField(
                            controller: ctrl,
                            focusNode: focus,
                            autocorrect: false,
                            validator: (text) {
                              final trimmed = text?.trim() ?? '';
                              if (trimmed.isEmpty) return 'campo obrigatório*';
                              if (trimmed.length < 3)
                                return 'mínimo de 3 caracteres.';
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              if (currentEntity != null) {
                                if (!(formKey.currentState?.validate() ??
                                    false))
                                  return;
                                context.read<CategoryController>().add(
                                  currentEntity.copyWith(
                                    title: ctrl.text.trim(),
                                    updatedAt: DateTime.now(),
                                  ),
                                );
                                ctrl.clear();
                                updateEntity.value = null;
                                context.unFocusKeyBoard();
                                return;
                              }
                              persistCategory();
                              context.unFocusKeyBoard();
                            },
                            decoration: InputDecoration(
                              labelText: 'Nome',
                              hintStyle: _Defaults(
                                context,
                              ).hintStyle?.resolve(states.value),
                              border: _inputBorder(context),
                              enabledBorder: _inputBorder(context),
                              focusedBorder: _inputBorder(context),
                              focusedErrorBorder: _inputBorder(
                                context,
                                error: true,
                              ),
                              errorBorder: _inputBorder(context, error: true),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  currentEntity != null
                                      ? MdiIcons.pencilBox
                                      : MdiIcons.plus,
                                ),
                                onPressed: () {
                                  if (currentEntity != null) {
                                    if (!(formKey.currentState?.validate() ??
                                        false))
                                      return;
                                    context.read<CategoryController>().add(
                                      currentEntity.copyWith(
                                        title: ctrl.text.trim(),
                                        updatedAt: DateTime.now(),
                                      ),
                                    );
                                    ctrl.clear();
                                    updateEntity.value = null;
                                    context.unFocusKeyBoard();
                                    return;
                                  }
                                  persistCategory();
                                },
                              ),
                              suffixIconColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              suffixIconConstraints: const BoxConstraints(
                                maxWidth: 50,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 12, left: 18),
                        child: Text('Categorias'),
                      ),
                      Expanded(
                        child: Consumer<CategoryController>(
                          builder: (_, provider, __) => ListView.builder(
                            controller: scrollController,
                            itemCount: provider.categories.length,
                            itemBuilder: (_, i) {
                              final cat = provider.categories[i];
                              return ListTile(
                                title: Text(cat.title),
                                onLongPress: () {
                                  ctrl.text = cat.title;
                                  ctrl.selection = TextSelection.collapsed(
                                    offset: ctrl.text.length,
                                  );
                                  updateEntity.value = cat;
                                  focus.requestFocus();
                                },
                                trailing: IconButton(
                                  icon: Icon(MdiIcons.minusBox),
                                  onPressed: () => provider.remove(cat),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InputShape extends WidgetStateProperty<RoundedRectangleBorder?> {
  @override
  RoundedRectangleBorder? resolve(Set<WidgetState> states) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
}

class _Defaults extends SearchBarThemeData {
  _Defaults(this.context);
  final BuildContext context;
  late final ColorScheme colors = Theme.of(context).colorScheme;
  late final TextTheme text = Theme.of(context).textTheme;

  @override
  WidgetStateProperty<TextStyle?>? get hintStyle => WidgetStatePropertyAll(
    text.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
  );

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed))
          return colors.onSurface.withAlpha(30);
        if (states.contains(WidgetState.hovered))
          return colors.onSurface.withAlpha(20);
        return Colors.transparent;
      });

  @override
  WidgetStateProperty<BorderSide?>? get side =>
      WidgetStatePropertyAll(BorderSide(color: colors.primary.withAlpha(26)));
}

OutlineInputBorder _inputBorder(BuildContext context, {bool error = false}) {
  final radius = BorderRadius.circular(12);
  return OutlineInputBorder(
    borderRadius: radius,
    borderSide: BorderSide(
      color: error
          ? Colors.red
          : Theme.of(context).colorScheme.primary.withAlpha(26),
    ),
  );
}

class _CategorySelection extends ChangeNotifier with ListBase<CategoryEntity> {
  _CategorySelection(Iterable<CategoryEntity> items) {
    _list.addAll(items);
  }

  final List<CategoryEntity> _list = [];

  @override
  int get length => _list.length;

  @override
  set length(int len) => _list.length = len;

  @override
  CategoryEntity operator [](int index) => _list[index];

  @override
  void operator []=(int index, CategoryEntity value) => _list[index] = value;

  @override
  void add(CategoryEntity value) => _list.add(value);

  @override
  bool remove(Object? value) => _list.remove(value);

  void toggle(CategoryEntity item) {
    if (contains(item)) {
      remove(item);
    } else {
      add(item);
    }
    notifyListeners();
  }
}
