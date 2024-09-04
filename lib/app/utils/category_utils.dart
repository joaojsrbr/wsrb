import 'dart:collection';

import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class CategoryUtils {
  static Future<void> selectCategory(BuildContext context) async {
    final ValueNotifierList valueNotifierList =
        context.read<ValueNotifierList>();

    final CategoryController categoryController =
        context.read<CategoryController>();

    final categories = categoryController.categories.where(
        (category) => category.ids.containsOneElement(valueNotifierList));

    final _CheckBoxSelect checkBoxSelect = _CheckBoxSelect(categories);

    final result = await showDialog(
      context: context,
      builder: (context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => checkBoxSelect)
          ],
          builder: (context, child) {
            final checkBoxSelect = context.watch<_CheckBoxSelect>();
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 12.0,
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              title: const Text('Definir Categorias'),
              content: categoryController.categories.isEmpty
                  ? const Text('Você não tem categorias ainda.')
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                            categoryController.categories.length, (index) {
                          final item =
                              categoryController.categories.elementAt(index);
                          return CheckboxListTile.adaptive(
                            value: checkBoxSelect.contains(item),
                            title: Text(item.title),
                            onChanged: (value) {
                              if (value == null) return;
                              checkBoxSelect.toogle(item);
                            },
                          );
                        }),
                      ),
                    ),
              // actionsAlignment: MainAxisAlignment.start,
              actions: [
                TextButton(
                  style: const ButtonStyle(
                    visualDensity: VisualDensity(horizontal: -4),
                  ),
                  onPressed: () => Navigator.of(context).pop("createCategory"),
                  child: categoryController.categories.isEmpty
                      ? const Text('Editar Categorias')
                      : const Text('Editar'),
                ),
                if (categoryController.categories.isNotEmpty)
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
                        onPressed: () {
                          Navigator.of(context).pop((
                            'addOrRemove',
                            checkBoxSelect,
                          ));
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
              ],
            );
          },
        );
      },
    );

    if (!context.mounted) return;

    switch (result) {
      case String data when data.contains("createCategory"):
        valueNotifierList.clear();
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          await createCategory(context);
        });
        break;
      case (String data, List<CategoryEntity> lista)
          when data.contains('addOrRemove'):
        final List<Future> futures = [];

        for (final category in categoryController.categories) {
          if (!(lista.contains(category) &&
              category.ids.containsOneElement(valueNotifierList))) {
            final List<String> newIDS = List<String>.from(category.ids)
              ..removeWhere(valueNotifierList.contains)
              ..unique();
            category.updatedAt = DateTime.now();
            category.ids = newIDS;
            futures.add(categoryController.add(category));
          }
        }

        for (final category in lista) {
          final List<String> newIDS = List<String>.from(category.ids)
            ..addAll(valueNotifierList)
            ..unique();

          category.updatedAt = DateTime.now();
          category.ids = newIDS;
          futures.add(categoryController.add(category));
        }

        await Future.wait(futures);
        valueNotifierList.clear();
        break;
    }
  }

  static Future<void> createCategory(BuildContext context,
      [CategoryEntity? category]) async {
    final WidgetStatesController statesController = WidgetStatesController();
    final TextEditingController controller = TextEditingController();
    final GlobalKey<FormState> form = GlobalKey<FormState>();
    final ValueNotifier<CategoryEntity?> editEntity = ValueNotifier(null);
    final FocusNode focusNode = FocusNode();

    if (category != null) {
      controller.text = category.title.trim();
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
      editEntity.value = category;
    }

    T? resolve<T>(
      WidgetStateProperty<T>? widgetValue,
    ) {
      final Set<WidgetState> states = statesController.value;
      return widgetValue?.resolve(states);
    }

    void saveForm() async {
      CategoryController category = context.read<CategoryController>();
      final isValid = form.currentState?.validate();
      if (isValid == true) {
        final title = controller.text.trim();
        final entity = CategoryEntity(
          title: title,
          createdAt: DateTime.now(),
        );
        controller.clear();
        await category.add(entity);
      }
    }

    // showModalBottomSheet(context: context, builder: builder);

    showModalBottomSheet(
      // isDismissible: true,
      // useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      context: context,
      enableDrag: true,
      builder: (context) {
        final ThemeData themeData = Theme.of(context);
        final ColorScheme colorScheme = themeData.colorScheme;
        final TextTheme textTheme = themeData.textTheme;

        final CategoryController category = context.watch<CategoryController>();

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => controller),
            ChangeNotifierProvider(create: (context) => statesController),
            ChangeNotifierProvider(create: (context) => focusNode),
            ChangeNotifierProvider(create: (context) => editEntity),
          ],
          builder: (context, child) {
            final controller = context.watch<TextEditingController>();
            final editEntity = context.watch<ValueNotifier<CategoryEntity?>>();
            final internalStatesController =
                context.watch<WidgetStatesController>();
            final focusNode = context.watch<FocusNode>();
            return Form(
              key: form,
              child: DraggableScrollableSheet(
                minChildSize: 0.45,
                initialChildSize: 0.60,
                expand: false,
                maxChildSize: 1.0,
                builder: (context, scrollController) {
                  return SingleChildScrollView(
                    // physics: const NeverScrollableScrollPhysics(),
                    controller: scrollController,
                    child: SizedBox(
                      height: MediaQuery.sizeOf(context).height,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) {
                              final defaults = _SearchBarDefaultsM3(context);

                              final TextStyle? effectiveHintStyle = defaults
                                  .hintStyle
                                  .resolve(statesController.value);

                              final RoundedRectangleBorder? effectiveShape =
                                  _EffectiveShape()
                                      .resolve(statesController.value);

                              final BorderSide effectiveSide =
                                  resolve<BorderSide?>(defaults.side) ??
                                      const BorderSide(
                                          color: Colors.transparent);

                              final WidgetStateProperty<Color?>?
                                  effectiveOverlayColor = defaults.overlayColor;

                              return Padding(
                                padding: const EdgeInsets.only(
                                  right: 20,
                                  left: 20,
                                  top: 24,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    if (!focusNode.hasFocus) {
                                      focusNode.requestFocus();
                                    }
                                  },
                                  overlayColor: effectiveOverlayColor,
                                  customBorder: effectiveShape?.copyWith(
                                      side: effectiveSide),
                                  statesController: internalStatesController,
                                  child: TextFormField(
                                    autocorrect: false,
                                    validator: (value) {
                                      if (value == null) return null;
                                      final text = value.trim();
                                      if (text.isEmpty) {
                                        return 'campo obrigatório*';
                                      } else if (text.length < 3) {
                                        return 'campo precisar ter pelo menos 3 caracteres.';
                                      }
                                      return null;
                                    },
                                    onFieldSubmitted: (value) {
                                      if (editEntity.value != null) {
                                        final isValid =
                                            form.currentState?.validate();
                                        if (isValid == false) return;
                                        final entity = editEntity.value!;
                                        entity.updatedAt = DateTime.now();
                                        entity.title = controller.text.trim();
                                        category.add(entity);
                                        controller.clear();
                                        editEntity.value = null;
                                        context.unFocusKeyBoard();
                                        return;
                                      }
                                      saveForm();
                                      context.unFocusKeyBoard();
                                    },
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: InputDecoration(
                                      hintStyle: effectiveHintStyle,
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                        ),
                                        borderRadius: effectiveShape
                                            ?.copyWith(side: effectiveSide)
                                            .borderRadius as BorderRadius,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: effectiveShape
                                            ?.copyWith(side: effectiveSide)
                                            .borderRadius as BorderRadius,
                                        borderSide: effectiveSide,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: effectiveShape
                                            ?.copyWith(side: effectiveSide)
                                            .borderRadius as BorderRadius,
                                        borderSide: effectiveSide,
                                      ),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      labelText: 'Nome',
                                      suffixIcon: IconButton(
                                        onPressed: () async {
                                          if (editEntity.value != null) {
                                            final isValid =
                                                form.currentState?.validate();
                                            if (isValid == false) return;
                                            final entity = editEntity.value!;
                                            entity.updatedAt = DateTime.now();
                                            entity.title =
                                                controller.text.trim();
                                            category.add(entity);
                                            controller.clear();
                                            editEntity.value = null;
                                            context.unFocusKeyBoard();
                                            return;
                                          }
                                          saveForm();
                                        },
                                        icon: Icon(
                                          editEntity.value != null
                                              ? MdiIcons.pencilBox
                                              : MdiIcons.plus,
                                        ),
                                      ),
                                      suffixIconColor: colorScheme.primary,
                                      suffixIconConstraints:
                                          const BoxConstraints(maxWidth: 50),
                                      contentPadding: const EdgeInsets.only(
                                          left: 15.0, right: 15.0),
                                      errorBorder: OutlineInputBorder(
                                        borderSide:
                                            const BorderSide(color: Colors.red),
                                        borderRadius: effectiveShape
                                            ?.copyWith(side: effectiveSide)
                                            .borderRadius as BorderRadius,
                                      ),
                                      focusColor:
                                          colorScheme.surface.withAlpha(128),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: effectiveShape
                                            ?.copyWith(side: effectiveSide)
                                            .borderRadius as BorderRadius,
                                        borderSide: effectiveSide,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 20,
                              bottom: 12,
                              left: 18,
                            ),
                            child: Text(
                              'Categorias',
                              style: textTheme.titleMedium,
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              // physics: const NeverScrollableScrollPhysics(),
                              controller: scrollController,
                              itemCount: category.categories.length,
                              itemBuilder: (context, index) {
                                final item =
                                    category.categories.elementAt(index);
                                return ListTile(
                                  title: Text(item.title),
                                  onLongPress: () {
                                    controller.text = item.title.trim();
                                    controller.selection =
                                        TextSelection.collapsed(
                                            offset: controller.text.length);
                                    editEntity.value = item;
                                  },
                                  trailing: IconButton(
                                    onPressed: () {
                                      category.remove(item);
                                    },
                                    icon: Icon(MdiIcons.minusBox),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _EffectiveShape extends WidgetStateProperty<RoundedRectangleBorder?> {
  @override
  RoundedRectangleBorder? resolve(Set<WidgetState> states) {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
  }
}

class _SearchBarDefaultsM3 extends SearchBarThemeData {
  _SearchBarDefaultsM3(this.context);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateColor.resolveWith(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return _colors.onSurface.withAlpha(10);
          }
          return _colors.surfaceContainerHighest.withAlpha(41);
        },
      );

  @override
  WidgetStateProperty<double>? get elevation =>
      const WidgetStatePropertyAll<double>(6.0);

  @override
  WidgetStateProperty<Color>? get shadowColor =>
      WidgetStatePropertyAll<Color>(_colors.shadow);

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
      WidgetStatePropertyAll<Color>(_colors.surfaceTint);

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return _colors.onSurface.withAlpha(30);
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.onSurface.withAlpha(20);
        }
        if (states.contains(WidgetState.focused)) {
          return Colors.transparent;
        }
        return Colors.transparent;
      });

  // No default side

  @override
  WidgetStateProperty<OutlinedBorder>? get shape =>
      const WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder());

  @override
  WidgetStateProperty<EdgeInsetsGeometry>? get padding =>
      const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: 8.0));

  @override
  WidgetStateProperty<TextStyle?> get textStyle =>
      WidgetStatePropertyAll<TextStyle?>(
          _textTheme.bodyLarge?.copyWith(color: _colors.onSurface));

  @override
  WidgetStateProperty<TextStyle?> get hintStyle =>
      WidgetStatePropertyAll<TextStyle?>(
          _textTheme.bodyLarge?.copyWith(color: _colors.onSurfaceVariant));

  @override
  WidgetStateProperty<BorderSide?>? get side =>
      WidgetStatePropertyAll(BorderSide(color: _colors.primary.withAlpha(26)));

  @override
  BoxConstraints get constraints =>
      const BoxConstraints(minWidth: 360.0, maxWidth: 800.0, minHeight: 56.0);

  @override
  TextCapitalization get textCapitalization => TextCapitalization.none;
}

class _CheckBoxSelect extends ChangeNotifier with ListBase<CategoryEntity> {
  _CheckBoxSelect(Iterable<CategoryEntity> elements) {
    _array.addAll(elements);
  }

  final List<CategoryEntity> _array = <CategoryEntity>[];

  @override
  int get length => _array.length;

  @override
  set length(int newLength) => _array.length = newLength;

  @override
  CategoryEntity operator [](int index) => _array[index];

  @override
  void operator []=(int index, CategoryEntity value) => _array[index] = value;

  @override
  void add(CategoryEntity element) => _array.add(element);

  @override
  bool remove(Object? element) => _array.remove(element);

  void toogle(CategoryEntity category) {
    if (contains(category)) {
      remove(category);
    } else {
      add(category);
    }
    notifyListeners();
  }
}
