import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/content_indicator_build.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/item_content.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ContentDestination extends StatefulWidget {
  const ContentDestination({super.key});

  @override
  State<ContentDestination> createState() => _ContentDestinationState();
}

class _ContentDestinationState extends State<ContentDestination> with AutomaticKeepAliveClientMixin {
  late final ContentRepository _contentRepository;

  @override
  void initState() {
    super.initState();
    _contentRepository = context.read<ContentRepository>();
    _contentRepository.refresh(true);
    _contentRepository.contentChallenge.addListener(_contentChallengeListener);
  }

  void _contentChallengeListener() async {
    final value = _contentRepository.contentChallenge.value;
    switch (value) {
      case BetterAnimeChallenge data:
        await context.push(RouteName.WEBVIEW, extra: data);
      default:
    }
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
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 6),
        indicatorBuilder: contentIndicatorBuilder,
        itemBuilder: _itemBuilder,
        sourceList: _contentRepository,
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, Content content, int index) {
    final lastOrNull = _contentRepository.totalPerPage.lastOrNull;

    final isNewPageHeader = lastOrNull != null && lastOrNull == index;

    if (isNewPageHeader) {
      final style = Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[400]);
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
          ContentTile.list(content: content, padding: const EdgeInsets.only(bottom: 4)),
        ],
      );
    }

    return ContentTile.list(
      content: content,
      padding: isNewPageHeader ? EdgeInsets.zero : const EdgeInsets.only(bottom: 4),
    );
  }

  @override
  void dispose() {
    _contentRepository.contentChallenge.removeListener(_contentChallengeListener);
    super.dispose();
  }
}
