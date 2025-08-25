import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/utils/category_helper.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class LibraryButtons extends StatefulWidget {
  const LibraryButtons({super.key, required this.tabController, this.onAdd});
  final TabController tabController;
  final VoidCallback? onAdd;

  @override
  State<LibraryButtons> createState() => _LibraryButtonsState();
}

class _LibraryButtonsState extends State<LibraryButtons> {
  late final ValueNotifierList _valueNotifierList;

  @override
  void initState() {
    _valueNotifierList = context.read<ValueNotifierList>();

    super.initState();
  }

  @override
  void deactivate() {
    _valueNotifierList.clear(false);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final LibraryController libraryController = context.read<LibraryController>();
    final ContentRepository repository = context.read<ContentRepository>();
    final ValueNotifierList valueNotifierList = context.watch<ValueNotifierList>();
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
                final allSelected = repository
                    .where((element) => valueNotifierList.contains(element.stringID))
                    .toList()
                    .unique((content) => content.stringID);
                valueNotifierList.clear();

                final contentEntities =
                    (await Future.wait(
                          allSelected.map(
                            (content) => repository
                                .getData(content)
                                .then(
                                  (result) =>
                                      result.fold(onSuccess: (success) => success),
                                ),
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

                await libraryController.addAll(contentEntities: contentEntities);
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
                final CategoryController categoryController = context
                    .read<CategoryController>();
                final List<Entity> removeEntities = libraryRepo.entities
                    .where(
                      (element) =>
                          valueNotifierList.contains(libraryRepo.getStringID(element)),
                    )
                    .toList()
                    .unique((content) => content.id);

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
                  ...removeIDS.map((e) => categoryController.add(e)),
                  libraryController.removeAll(contentEntities: removeEntities.cast()),
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
              onPressed: libraryRepo.favoritesIDS.containsOneElement(valueNotifierList)
                  ? () {
                      CategoryHelper.openCategoryDialog(context);
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
