import 'package:app_wsrb_jsr/app/utils/value_notifier_list.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class _CheckBoxSelect extends ValueNotifier<List<CategoryEntity>> {
  _CheckBoxSelect(super.value);

  void toogle(CategoryEntity object) {
    if (value.contains(object)) {
      value.remove(object);
    } else {
      value.add(object);
    }
    notifyListeners();
  }
}

class CategoryUtils {
  Future<void> selectCategory(BuildContext context) async {
    final ValueNotifierList valueNotifierList =
        context.read<ValueNotifierList>();

    final CategoryController categoryController =
        context.read<CategoryController>();

    final categories = categoryController.categories.where((category) =>
        category.ids.any((element) => valueNotifierList.contains(element)));

    final _CheckBoxSelect checkBoxSelect = _CheckBoxSelect(categories.toList());

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
                            value: checkBoxSelect.value.contains(item),
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
                          // if (categories.isNotEmpty) {
                          //   Navigator.of(context).pop(
                          //     ('remove', checkBoxSelect.value),
                          //   );
                          // } else {
                          // }
                          Navigator.of(context).pop((
                            'addOrRemove',
                            checkBoxSelect.value,
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
        List<Future> futures = [];
        final cacheRemove = List<CategoryEntity>.from(
          categoryController.categories,
        )..removeWhere(
            (category) =>
                lista.contains(category) &&
                category.ids
                    .containsOneElement(valueNotifierList.value.toList()),
          );

        for (final category in cacheRemove) {
          final newIDS = List<String>.from(category.ids)
            ..removeWhere((id) => valueNotifierList.contains(id));

          category.updatedAt = DateTime.now();
          category.ids = newIDS;
          futures.add(categoryController.add(category));
        }

        final cacheAdd = List<String>.from(valueNotifierList.value);

        for (final category in lista) {
          final newIDS = List<String>.from(category.ids)..addAll(cacheAdd);

          category.updatedAt = DateTime.now();
          category.ids = newIDS;
          futures.add(categoryController.add(category));
        }

        await Future.wait(futures);
        valueNotifierList.clear();
        break;
    }
  }

  Future<void> createCategory(BuildContext context) async {
    final MaterialStatesController statesController =
        MaterialStatesController();
    final TextEditingController controller = TextEditingController();
    final GlobalKey<FormState> form = GlobalKey<FormState>();
    final ValueNotifier<CategoryEntity?> editEntity = ValueNotifier(null);
    final FocusNode focusNode = FocusNode();

    T? resolve<T>(
      MaterialStateProperty<T>? widgetValue,
    ) {
      final Set<MaterialState> states = statesController.value;
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

    await showModalBottomSheet(
      isDismissible: true,
      useSafeArea: true,
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
                context.watch<MaterialStatesController>();
            final focusNode = context.watch<FocusNode>();
            return Form(
              key: form,
              child: DraggableScrollableSheet(
                minChildSize: 0.45,
                initialChildSize: 0.60,
                expand: false,
                maxChildSize: 0.75,
                builder: (context, scrollController) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) {
                          final defaults = _SearchBarDefaultsM3(context);

                          final TextStyle? effectiveHintStyle = defaults
                              .hintStyle
                              .resolve(statesController.value);

                          final RoundedRectangleBorder? effectiveShape =
                              _EffectiveShape().resolve(statesController.value);

                          final BorderSide effectiveSide =
                              resolve<BorderSide?>(defaults.side) ??
                                  const BorderSide(color: Colors.transparent);

                          final MaterialStateProperty<Color?>?
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
                              customBorder:
                                  effectiveShape?.copyWith(side: effectiveSide),
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
                                    final entity = editEntity.value!;
                                    entity.updatedAt = DateTime.now();
                                    entity.title = controller.text.trim();
                                    category.add(entity);
                                    controller.clear();
                                    editEntity.value = null;
                                    return;
                                  }
                                  saveForm();
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
                                        final entity = editEntity.value!;
                                        entity.updatedAt = DateTime.now();
                                        entity.title = controller.text.trim();
                                        category.add(entity);
                                        controller.clear();
                                        editEntity.value = null;
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
                                      colorScheme.background.withOpacity(0.5),
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
                          controller: scrollController,
                          itemCount: category.categories.length,
                          itemBuilder: (context, index) {
                            final item = category.categories.elementAt(index);
                            return ListTile(
                              title: Text(item.title),
                              onLongPress: () {
                                controller.text = item.title.trim();
                                controller.selection = TextSelection.collapsed(
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

class _EffectiveShape extends MaterialStateProperty<RoundedRectangleBorder?> {
  @override
  RoundedRectangleBorder? resolve(Set<MaterialState> states) {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
  }
}

class _SearchBarDefaultsM3 extends SearchBarThemeData {
  _SearchBarDefaultsM3(this.context);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  MaterialStateProperty<Color?>? get backgroundColor =>
      MaterialStateColor.resolveWith(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return _colors.onSurface.withOpacity(0.04);
          }
          return _colors.surfaceVariant.withOpacity(0.16);
        },
      );

  @override
  MaterialStateProperty<double>? get elevation =>
      const MaterialStatePropertyAll<double>(6.0);

  @override
  MaterialStateProperty<Color>? get shadowColor =>
      MaterialStatePropertyAll<Color>(_colors.shadow);

  @override
  MaterialStateProperty<Color>? get surfaceTintColor =>
      MaterialStatePropertyAll<Color>(_colors.surfaceTint);

  @override
  MaterialStateProperty<Color?>? get overlayColor =>
      MaterialStateProperty.resolveWith((Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return _colors.onSurface.withOpacity(0.12);
        }
        if (states.contains(MaterialState.hovered)) {
          return _colors.onSurface.withOpacity(0.08);
        }
        if (states.contains(MaterialState.focused)) {
          return Colors.transparent;
        }
        return Colors.transparent;
      });

  // No default side

  @override
  MaterialStateProperty<OutlinedBorder>? get shape =>
      const MaterialStatePropertyAll<OutlinedBorder>(StadiumBorder());

  @override
  MaterialStateProperty<EdgeInsetsGeometry>? get padding =>
      const MaterialStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: 8.0));

  @override
  MaterialStateProperty<TextStyle?> get textStyle =>
      MaterialStatePropertyAll<TextStyle?>(
          _textTheme.bodyLarge?.copyWith(color: _colors.onSurface));

  @override
  MaterialStateProperty<TextStyle?> get hintStyle =>
      MaterialStatePropertyAll<TextStyle?>(
          _textTheme.bodyLarge?.copyWith(color: _colors.onSurfaceVariant));

  @override
  MaterialStateProperty<BorderSide?>? get side => MaterialStatePropertyAll(
      BorderSide(color: _colors.primary.withOpacity(0.10)));

  @override
  BoxConstraints get constraints =>
      const BoxConstraints(minWidth: 360.0, maxWidth: 800.0, minHeight: 56.0);

  @override
  TextCapitalization get textCapitalization => TextCapitalization.none;
}
