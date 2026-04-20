import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/widgets/highlight.dart';
import '../../shared/widgets/item_content.dart';
import '../widgets/content_indicator_build.dart';

class ContentDestination extends StatefulWidget {
  const ContentDestination({super.key});

  @override
  State<ContentDestination> createState() => _ContentDestinationState();
}

class _ContentDestinationState extends State<ContentDestination>
    with AutomaticKeepAliveClientMixin {
  late final ContentRepository _contentRepository;

  late final TextEditingController _editingController;
  final Debouncer cookieDebouncer = Debouncer(
    duration: const Duration(seconds: 1),
  );

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController();
    _contentRepository = context.read<ContentRepository>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contentRepository.refresh(true);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    customLog('$widget[build]');

    return LoadingMoreList(
      ListConfig<Content>(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        indicatorBuilder: contentIndicatorBuilder,
        itemBuilder: _itemBuilder,
        sourceList: _contentRepository,
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, Content content, int index) {
    final totalPerPage = _contentRepository.totalPerPage;

    final isNewPageHeader = totalPerPage != null && totalPerPage == index;

    final contentWidget = CustomValueChangeHighlight(
      value: content.stringID,
      child: ContentTile.list(
        content: content,
        padding: isNewPageHeader
            ? EdgeInsets.zero
            : const EdgeInsets.only(bottom: 4),
      ),
    );

    if (isNewPageHeader) {
      final style = Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.grey[400],
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Expanded(child: Divider(thickness: 1)),
                const SizedBox(width: 8),
                Text("Página ${_contentRepository.index}", style: style),
                const SizedBox(width: 8),
                const Expanded(child: Divider(thickness: 1)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          contentWidget,
        ],
      );
    }

    return contentWidget;
  }

  @override
  void dispose() {
    _editingController.dispose();
    cookieDebouncer.cancel();
    super.dispose();
  }
}
