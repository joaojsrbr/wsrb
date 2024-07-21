import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/utils/category_utils.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class HomeBottomOverlay extends StatelessWidget {
  const HomeBottomOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final LibraryController libraryController =
        context.read<LibraryController>();
    final ContentRepository repository = context.read<ContentRepository>();
    final ValueNotifierList valueNotifierList =
        context.watch<ValueNotifierList>();
    final LibraryService libraryService = LibraryService(libraryController);

    if (valueNotifierList.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      child: IntrinsicHeight(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: Divider.createBorderSide(context, width: 1.0),
            ),
          ),
          alignment: AlignmentDirectional.centerStart,
          padding: const EdgeInsets.all(8),
          child: OverflowBar(
            spacing: 8,
            textDirection: Directionality.of(context),
            overflowAlignment: OverflowBarAlignment.end,
            children: [
              IconButton(
                onPressed: libraryService.favoritesIDS
                        .any((id) => valueNotifierList.contains(id))
                    ? null
                    : () async {
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
                  duration: const Duration(seconds: 1),
                  secondChild: Icon(MdiIcons.plusBoxMultiple),
                  child: Icon(MdiIcons.plusBox),
                ),
              ),
              IconButton(
                onPressed: libraryService.favoritesIDS
                        .any((element) => valueNotifierList.contains(element))
                    ? () async {
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
                          final id = libraryService.favoritesIDS
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
                      }
                    : null,
                icon: FadeThroughTransitionSwitcher(
                  enableSecondChild: valueNotifierList.length != 1,
                  duration: const Duration(seconds: 1),
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
                  enableSecondChild: valueNotifierList.length != 1,
                  duration: const Duration(seconds: 1),
                  secondChild: Icon(MdiIcons.tagMultiple),
                  child: Icon(MdiIcons.tag),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
