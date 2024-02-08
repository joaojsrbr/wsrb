import 'dart:async';

import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/state_extensions.dart';
import 'package:app_wsrb_jsr/app/core/services/hive/hive_controller.dart';
import 'package:app_wsrb_jsr/app/models/content.dart';
import 'package:app_wsrb_jsr/app/models/data_content.dart';
import 'package:app_wsrb_jsr/app/repositories/content_cache.dart';
import 'package:app_wsrb_jsr/app/utils/custom_log.dart';

import 'package:app_wsrb_jsr/app/repositories/content_repository.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/build_contents.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/chip_content_controller.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/flexible.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/sinopse.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer.dart';
import 'package:app_wsrb_jsr/app/utils/custom_states.dart';
import 'package:app_wsrb_jsr/app/utils/subscriptions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';

class BookInformationView extends StatefulWidget {
  const BookInformationView({super.key});

  @override
  State<BookInformationView> createState() => _BookInformationStateView();
}

class _BookInformationStateView
    extends StateByArgument<BookInformationView, ContentInformationArgs> {
  late final Subscriptions _subscriptions;

  @override
  void initState() {
    super.initState();
    _repository = context.read<ContentRepository>();
    _hiveController = context.read<HiveController>();
    _cache = context.read<ContentCache>();
    _subscriptions = Subscriptions()
      ..add(
        _hiveController
            .watchBy('book_info_content_orders')
            .listen(_ordersListener),
      );
    addPostFrameCallback((data) => _onInit());
  }

  /// [BookCache] instance
  late final ContentCache _cache;

  /// [HiveController] instance
  late final HiveController _hiveController;

  /// [ContentRepository] instance
  late final ContentRepository _repository;

  /// variable that controls page loading
  bool _isLoading = true;

  /// list of object list
  List<List<DataContent>> _dataContents = [];

  /// [Content] instance
  Content? _content;

  /// index relating to [_chapters]
  int _index = 0;

  /// Function that controls the value of [_index]
  void _handleSetListIndex(int index) {
    if (index == _index) return;

    setStateIfMounted(() => _index = index);
  }

  void _onInit() async {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is! ContentInformationArgs) {
      customLog('O argumento precisa ser do tipo BookInformationArgs');
      Navigator.pop(context);
    } else {
      final content = args.content;

      final cacheContent = await _cache.getContent(content.id);

      if (cacheContent != null) {
        await Future.delayed(
          const Duration(milliseconds: 600),
          () => _onSucess(cacheContent),
        );
        return;
      }

      final resultCotent = await _repository.getData(content);

      await resultCotent.when(
        onError: (error) {
          Navigator.pop(context, resultCotent);
        },
        onSucess: _onSucess,
      );
    }
  }

  /// function that partitions the list [_chapters]
  void _setAllContents(DataContents dataContents) {
    _dataContents = partition(dataContents.reversed, 20).toList();
    // _index = _chapters.length - 1;
    _reversedAllContents(_hiveController.contentOrders);
  }

  void _reversedAllContents([bool? init]) {
    if (init == false) return;
    // _hiveController.chaptersOrders;
    _dataContents.forEachIndexed((index, element) {
      _dataContents[index] = _dataContents[index].reversed.toList();
    });
  }

  /// asynchronous function referring to [RefreshIndicator]
  Future<void> _onRefresh() async {
    final resultBook = await _repository.getData(_content!);

    return await resultBook.when<Future>(
      onError: (error) async {
        customLog(error.toString());
      },
      onSucess: (data) => _onSucess(data, false),
    );
  }

  Future<void> _onSucess(Content data, [bool onInit = true]) async {
    if (data == _content) return;
    ColorScheme? contentColorScheme;
    try {
      contentColorScheme = await ColorScheme.fromImageProvider(
        brightness: Theme.of(context).brightness,
        provider: CachedNetworkImageProvider(
          data.imageUrl,
          cacheKey: data.imageUrl,
          maxHeight: 330,
          maxWidth: 245,
        ),
      );
    } catch (_) {}
    _cache.saveContent(data);
    setStateIfMounted(() {
      _content = data.copyWith(contentColorScheme: contentColorScheme);
      _setAllContents(data.dataContents);
      if (onInit) _isLoading = false;
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

  void _ordersListener(BoxEvent event) {
    setStateIfMounted(_reversedAllContents);
  }

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

    final size = MediaQuery.sizeOf(context);

    return Theme(
      data: themeData.copyWith(colorScheme: _content?.contentColorScheme),
      child: Shimmer(
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            themeData.highlightColor,
            themeData.highlightColor,
            Colors.grey.shade100,
            themeData.highlightColor,
            themeData.highlightColor,
          ],
          stops: const <double>[
            0.0,
            0.35,
            0.5,
            0.65,
            1.0,
          ],
        ),
        child: BookInformationScope(
          contentOrders: context.watch<HiveController>().contentOrders,
          dataContents: _dataContents,
          index: _index,
          setListIndex: _handleSetListIndex,
          content: _content ?? argument.content,
          isLoading: _isLoading,
          child: Scaffold(
            body: RefreshIndicator(
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
      ),
    );
  }

  @override
  void dispose() {
    _subscriptions.cancellAll();
    ifMounted(() {
      _cache.registerTask(_content!.id);
    });
    super.dispose();
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
