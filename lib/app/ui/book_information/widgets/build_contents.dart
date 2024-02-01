import 'package:app_wsrb_jsr/app/utils/custom_log.dart';
import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/book_information/widgets/dismissible.dart';
import 'package:app_wsrb_jsr/app/ui/book_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/reading/view/reading.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BuildContents extends StatelessWidget {
  const BuildContents({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = BookInformationScope.isLoadingOf(context);

    if (isLoading) {
      return SliverFillRemaining(
        child: ShimmerLoading(
          isLoading: isLoading,
          child: const Material(child: SizedBox.expand()),
          // child: ListView.builder(
          //   itemCount: 6,
          //   physics: const NeverScrollableScrollPhysics(),
          //   padding: EdgeInsets.zero,
          //   itemBuilder: (context, index) {
          //     return const Material(
          //       child: IgnorePointer(
          //         child: ListTile(
          //           contentPadding: EdgeInsets.zero,
          //         ),
          //       ),
          //     );
          //   },
          // ),
        ),
      );
    }

    final index = BookInformationScope.indexOf(context);
    final chapters =
        BookInformationScope.chaptersOf(context).reversed.elementAt(index);
    final book = BookInformationScope.bookOf(context);

    return SliverList.builder(
      itemBuilder: (context, index) {
        final chapter = chapters[index];

        return CustomDismissible(
          onUpdate: (details) {},
          dismissThresholds: const {
            DismissDirection.endToStart: 0.5,
            DismissDirection.startToEnd: 0.5
          },
          resizeDuration: const Duration(milliseconds: 600),
          background: Container(
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(color: Colors.blueAccent),
            padding: const EdgeInsets.only(left: 20.0),
            child: const Icon(Icons.check, color: Colors.white),
          ),
          radius: 20,
          secondaryBackground: Container(
            decoration: const BoxDecoration(color: Colors.redAccent),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          key: ValueKey(chapter.id),
          onTap: () async {
            customLog(
              'tapped name: ${chapter.chapterName} - id: ${chapter.id}',
            );
            await context.push(
              RouteName.READ,
              extra: ReadingView.args(
                bookThemeData: Theme.of(context),
                chapter: chapter,
                chapters: chapters,
                currentIndex: index,
                book: book,
              ),
            );
          },
          child: ListTile(
            titleTextStyle: Theme.of(context).textTheme.labelLarge,
            title: Text(chapter.chapterName),
          ),
        );
      },
      itemCount: chapters.length,
    );
  }
}
