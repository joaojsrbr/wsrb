import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/utils/category_helper.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class LibraryButtons extends StatefulWidget {
  const LibraryButtons({
    super.key,
    required this.tabController,
    this.onAdd,
    required this.context,
  });
  final TabController tabController;
  final BuildContext context;
  final VoidCallback? onAdd;

  @override
  State<LibraryButtons> createState() => _LibraryButtonsState();
}

class _LibraryButtonsState extends State<LibraryButtons> {
  late final ValueNotifierList _valueNotifierList;

  @override
  void initState() {
    _valueNotifierList = context.read<ValueNotifierList>()..addListener(_listener);
    super.initState();
  }

  void _listener() {
    setState(() {});
  }

  @override
  void dispose() {
    _valueNotifierList.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LibraryController libraryController = context.read<LibraryController>();
    final ContentRepository repository = context.read<ContentRepository>();
    final ValueNotifierList valueNotifierList = context.watch<ValueNotifierList>();
    final CategoryController categoryController = context.read<CategoryController>();
    final libraryRepo = libraryController.repo;

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        spacing: 8,
        textDirection: Directionality.of(context),
        mainAxisAlignment: MainAxisAlignment.start,
        // overflowAlignment: OverflowBarAlignment.center,
        children: [
          if (widget.tabController.index != 2)
            IconButton(
              onPressed: () async {
                final allSelected = repository.where(valueNotifierList.contains).toSet();
                valueNotifierList.clear();

                final contents = await Future.wait(
                  allSelected.map((content) => repository.getData(content)),
                );

                final contentEntities = contents
                    .map((result) => result.fold(onSuccess: (success) => success))
                    .nonNulls
                    .map((e) => e.toEntity(isFavorite: true));

                await libraryController.addAll(
                  contentEntities: contentEntities.nonNulls.toList(),
                );
                widget.onAdd?.call();
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
                final Set<Entity> removeEntities = libraryRepo.entities
                    .where(valueNotifierList.contains)
                    .toSet();
                valueNotifierList.clear();
                final removeIDS = <CategoryEntity>{};

                for (final category in categoryController.categories) {
                  final id = libraryRepo.favoritesIDS.firstWhereOrNull(
                    category.ids.contains,
                  );

                  if (id != null) {
                    final newIDS = List<String>.from(category.ids);
                    newIDS.remove(id);

                    removeIDS.add(
                      category.copyWith(ids: newIDS, updatedAt: DateTime.now()),
                    );
                  }
                }

                final futures = [
                  ...removeIDS.map(categoryController.add),
                  libraryController.removeAll(
                    contentEntities: removeEntities.toList().cast(),
                  ),
                ];

                await Future.wait(futures);
              },
              icon: FadeThroughTransitionSwitcher(
                enableSecondChild: valueNotifierList.length > 1,
                duration: const Duration(milliseconds: 250),
                secondChild: Icon(MdiIcons.minusBoxMultiple),
                child: Icon(MdiIcons.minusBox),
              ),
            ),
            IconButton(
              onPressed: libraryRepo.favoritesIDS.containsOneElement(valueNotifierList)
                  ? () {
                      CategoryHelper.openCategoryDialog(widget.context);
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
    );
  }
}
