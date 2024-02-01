import 'package:app_wsrb_jsr/app/models/book.dart';
import 'package:app_wsrb_jsr/app/repositories/book_repository.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/book_item.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/indicator_build.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:provider/provider.dart';

class HomeDestination extends StatefulWidget {
  const HomeDestination({super.key});

  @override
  State<HomeDestination> createState() => _HomeDestinationState();
}

class _HomeDestinationState extends State<HomeDestination> {
  @override
  Widget build(BuildContext context) {
    final BookRepository bookRepository = context.read<BookRepository>();
    return RefreshIndicator(
      onRefresh: () async {
        bookRepository.refresh(true);
      },
      child: LoadingMoreList(
        ListConfig(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          indicatorBuilder: indicatorBuilder,
          physics: const NeverScrollableScrollPhysics(),
          // lastChildLayoutType: LastChildLayoutType.fullCrossAxisExtent,
          itemBuilder: _itemBuilder,

          sourceList: bookRepository,
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, Book item, int index) {
    return BookItem(item: item);
  }
}
