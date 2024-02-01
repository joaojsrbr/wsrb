import 'package:app_wsrb_jsr/app/models/content.dart';
import 'package:app_wsrb_jsr/app/repositories/book_repository.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/item_content.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/indicator_build.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:provider/provider.dart';

class HomeDestination extends StatefulWidget {
  const HomeDestination({super.key});

  @override
  State<HomeDestination> createState() => _HomeDestinationState();
}

class _HomeDestinationState extends State<HomeDestination>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final BookRepository bookRepository = context.read<BookRepository>();

    Future<void> onRefresh() async {
      bookRepository.refresh(true);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LoadingMoreList(
        ListConfig<Content>(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          indicatorBuilder: indicatorBuilder,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: _itemBuilder,
          sourceList: bookRepository,
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, Content content, int index) {
    return ItemContent(content: content);
  }
}
