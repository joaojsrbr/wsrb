import 'dart:async';

import 'package:app_wsrb_jsr/app/core/services/theme_controller.dart';
import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
import 'package:content_library/content_library.dart';

import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/build_contents.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/chip_content_controller.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/flexible.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/sinopse.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer.dart';
import 'package:app_wsrb_jsr/app/utils/custom_states.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class BookInformationView extends StatefulWidget {
  const BookInformationView({super.key});

  @override
  State<BookInformationView> createState() => _BookInformationStateView();
}

class _BookInformationStateView
    extends StateByArgument<BookInformationView, ContentInformationArgs> {
  late final Subscriptions _subscriptions;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();

  late final ThemeController _themeController;

  /// [BookCache] instance
  late final ContentCache _cache;

  /// [ContentRepository] instance
  late final ContentRepository _repository;

  /// variable that controls page loading
  bool _isLoading = true;

  /// list of object list
  List<Releases> _releases = [];

  /// [Content] instance
  Content? _content;

  /// index relating to [_chapters]
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _repository = context.read<ContentRepository>();
    _cache = context.read<ContentCache>();
    _themeController = context.read<ThemeController>();
    _subscriptions = Subscriptions();
    Future.microtask(_onInit);
  }

  /// Function that controls the value of [_index]
  void _handleSetListIndex(int index) {
    if (index == _index) return;

    setStateIfMounted(() => _index = index);
  }

  void _onInit() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    final navigationState = Navigator.of(context);
    if (args is! ContentInformationArgs) {
      navigationState.pop(
        'O argumento precisa ser do tipo BookInformationArgs',
      );
    } else {
      final content = args.content;

      final cacheContent = await _cache.getContent(content.id);

      if (cacheContent != null) {
        _onSucess(cacheContent);
        return;
      }

      final resultCotent = await _repository.getData(content);

      resultCotent.when(
        onError: navigationState.pop,
        onSucess: _onSucess,
      );
    }
  }

  /// function that partitions the list [_chapters]
  void _setAllContents(Releases releases) {
    _releases = releases.partition(20);
  }

  // void _reversedAllContents(bool reverse) {
  //   _releases.forEachIndexed((index, element) {
  //     _releases[index] = Releases.fromList(_releases[index].reverse(reverse));
  //   });
  // }

  /// asynchronous function referring to [RefreshIndicator]
  Future<void> _onRefresh() async {
    final appSnackBar = context.appSnackBar;
    final resultBook = await _repository.getData(_content!);

    return await resultBook.when<Future>(
      onError: appSnackBar.onError,
      onSucess: (data) => _onSucess(data, true),
    );
  }

  // Future<ColorScheme?> _getContentColorScheme(Content data) async {
  //   if (_content?.contentColorScheme != null) return null;

  //   ColorScheme? contentColorScheme;

  //   try {
  //     contentColorScheme = await ColorScheme.fromImageProvider(
  //       brightness: Theme.of(context).brightness,
  //       provider: CachedNetworkImageProvider(
  //         data.imageUrl,
  //         cacheKey: data.imageUrl,
  //         maxHeight: 330,
  //         maxWidth: 245,
  //       ),
  //     );
  //   } catch (_) {}

  //   _themeController.setTransitionPageFillColor(contentColorScheme?.background);
  //   return contentColorScheme;
  // }

  Future<void> _onSucess(Content data, [bool onRefresh = false]) async {
    // ColorScheme? contentColorScheme = await _getContentColorScheme(data);
    final libraryController = context.read<LibraryController>();
    await _cache.saveContent(data);

    if (libraryController.contains(content: data)) {
      Entity? entity;
      switch (data) {
        case Anime data:
          entity = data.toEntity(updatedAt: DateTime.now());
          break;
        case Book data:
          entity = data.toEntity(updatedAt: DateTime.now());
          break;
      }
      libraryController.add(entity: entity);
    }

    setStateIfMounted(() {
      _content = data.copyWith();
      _setAllContents(data.releases);
      if (!onRefresh) _isLoading = false;
    });
  }

  // void _chaptersConfig(BuildContext context) {
  //   showModalBottomSheet(
  //     // isScrollControlled: true,
  //     showDragHandle: true,
  //     context: context,
  //     builder: (context) => const _BottomSheetWidget(),
  //   );
  // }

  // void _ordersListener(BoxEvent event) {
  //   // setStateIfMounted(_reversedAllContents);
  // }

  ScrollPhysics get _physics {
    if (_isLoading) return const NeverScrollableScrollPhysics();
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  Widget buildByArgument(
    BuildContext context,
    ContentInformationArgs argument,
  ) {
    final themeData = Theme.of(context);

    // final hiveController = context.watch<HiveController>();

    final size = MediaQuery.sizeOf(context);

    final linearGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.centerRight,
      colors: <Color>[
        themeData.colorScheme.primary.withOpacity(0.12),
        themeData.colorScheme.primary.withOpacity(0.12),
        const Color(0xffE6E8EB),
        themeData.colorScheme.primary.withOpacity(0.12),
        themeData.colorScheme.primary.withOpacity(0.12),
      ],
      stops: const <double>[0.0, 0.3, 0.5, 0.65, 1.0],
    );

    return Shimmer(
      linearGradient: linearGradient,
      child: BookInformationScope(
        releases: _releases,
        index: _index,
        setListIndex: _handleSetListIndex,
        content: _content ?? argument.content,
        isLoading: _isLoading,
        child: Scaffold(
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _onRefresh,
            child: CustomScrollView(
              physics: _physics,
              slivers: [
                SliverAppBar(
                  snap: false,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  expandedHeight: size.height * .45,
                  floating: false,
                  pinned: true,
                  stretch: false,
                  flexibleSpace: const FlexibleSpaceBarWidget(),
                ),
                SinopseWidget(sinopse: _content?.sinopse ?? ''),
                const ChipContentController(),
                const BuildContents(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscriptions.cancellAll();
    super.dispose();
  }

  @override
  void deactivate() {
    if (_content != null) _cache.registerTask(_content!.id);
    _themeController.setTransitionPageFillColor(
      Theme.of(context).cardColor,
    );
    super.deactivate();
  }
}

// class _BottomSheetWidget extends StatefulWidget {
//   const _BottomSheetWidget();

//   @override
//   State<_BottomSheetWidget> createState() => __BottomSheetWidgetState();
// }

// class __BottomSheetWidgetState extends State<_BottomSheetWidget> {
//   @override
//   Widget build(BuildContext context) {
//     final themeData = Theme.of(context);

//     final hiveController = context.watch<HiveController>();

//     final textTheme = themeData.textTheme;

//     final viewInsets = MediaQuery.viewInsetsOf(context);

//     final colorScheme = themeData.colorScheme;

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(top: 18, bottom: 12, left: 12),
//           child: Tooltip(
//             message: 'Configurações',
//             preferBelow: false,
//             child: Text(
//               'Configurações',
//               style: textTheme.titleLarge?.copyWith(
//                 fontSize: 30,
//                 color: colorScheme.primary,
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: EdgeInsets.only(bottom: viewInsets.bottom + 20),
//           child: Column(
//             children: [
//               ListTile(
//                 // dense: true,
//                 leading: FadeThroughTransitionSwitcher(
//                   replace: hiveController.chaptersOrders,
//                   secondChild:
//                       Icon(Icons.arrow_downward, color: colorScheme.primary),
//                   child: Icon(Icons.arrow_upward, color: colorScheme.primary),
//                 ),
//                 style: ListTileStyle.list,
//                 titleTextStyle: textTheme.titleLarge
//                     ?.copyWith(fontSize: 14, color: colorScheme.primary),
//                 onTap: () => hiveController
//                     .setChaptersOrders(!hiveController.chaptersOrders),
//                 title: const Text('Ordem dos capítulos'),
//               ),
//               ListTile(
//                 // dense: true,
//                 leading: FadeThroughTransitionSwitcher(
//                   replace: hiveController.pageOrders,
//                   secondChild:
//                       Icon(Icons.arrow_downward, color: colorScheme.primary),
//                   child: Icon(Icons.arrow_upward, color: colorScheme.primary),
//                 ),
//                 style: ListTileStyle.list,
//                 titleTextStyle: textTheme.titleLarge
//                     ?.copyWith(fontSize: 14, color: colorScheme.primary),
//                 onTap: () =>
//                     hiveController.setPageOrders(!hiveController.pageOrders),
//                 title: const Text('Ordem da paginação'),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
