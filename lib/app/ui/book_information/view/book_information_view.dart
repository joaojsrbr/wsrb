import 'dart:async';

import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/state_extensions.dart';
import 'package:app_wsrb_jsr/app/core/services/hive/hive_controller.dart';
import 'package:app_wsrb_jsr/app/repositories/book_cache.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/utils/custom_log.dart';
import 'package:app_wsrb_jsr/app/models/book.dart';
import 'package:app_wsrb_jsr/app/models/chapter.dart';
import 'package:app_wsrb_jsr/app/repositories/book_repository.dart';
import 'package:app_wsrb_jsr/app/ui/book_information/arguments/book_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/book_information/widgets/build_contents.dart';
import 'package:app_wsrb_jsr/app/ui/book_information/widgets/chip_book_controller.dart';
import 'package:app_wsrb_jsr/app/ui/book_information/widgets/flexible.dart';
import 'package:app_wsrb_jsr/app/ui/book_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/book_information/widgets/sinopse.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer.dart';
import 'package:app_wsrb_jsr/app/utils/custom_states.dart';
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
    extends StateByArgument<BookInformationView, BookInformationArgs> {
  final List<StreamSubscription> _subs = [];

  @override
  void initState() {
    super.initState();
    _repository = context.read<BookRepository>();
    _hiveController = context.read<HiveController>();
    _cache = context.read<BookCache>();
    _chaptersOrders = _hiveController.chaptersOrders;
    _subs.addAll([
      _hiveController
          .watchBy('book_info_chapters_orders')
          .listen(_ordersListener),
    ]);
    addPostFrameCallback((data) => _onInit());
  }

  /// [BookCache] instance
  late final BookCache _cache;

  /// [HiveController] instance
  late final HiveController _hiveController;

  /// [HiveController.chaptersOrders]
  bool _chaptersOrders = false;

  /// [BookRepository] instance
  late final BookRepository _repository;

  /// variable that controls page loading
  bool _isLoading = true;

  /// list of object list
  List<List<Chapter>> _chapters = [];

  /// [Book] instance
  Book? _book;

  /// index relating to [_chapters]
  int _index = 0;

  /// Function that controls the value of [_index]
  void _handleSetListIndex(int index) {
    if (index == _index) return;

    setStateIfMounted(() => _index = index);
  }

  void _onInit() async {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is! BookInformationArgs) {
      customLog('O argumento precisa ser do tipo BookInformationArgs');
      Navigator.pop(context);
    } else {
      final book = args.book;

      final cacheBook = await _cache.getBook(book.id);

      if (cacheBook != null) {
        await Future.delayed(
          const Duration(milliseconds: 600),
          () => _onSucess(cacheBook),
        );
        return;
      }

      final resultBook = await _repository.bookData(book);

      await resultBook.when(
        onError: (error) {
          Navigator.pop(context, resultBook);
        },
        onSucess: _onSucess,
      );
    }
  }

  /// function that partitions the list [_chapters]
  void _setChapters(List<Chapter> chapters) {
    _chapters = partition(chapters.reversed, 20).toList();
    // _index = _chapters.length - 1;
    _reversedChapters(_chaptersOrders);
  }

  void _reversedChapters([bool? init]) {
    if (init == false) return;
    // _hiveController.chaptersOrders;
    _chapters.forEachIndexed((index, element) {
      _chapters[index] = _chapters[index].reversed.toList();
    });
  }

  /// asynchronous function referring to [RefreshIndicator]
  Future<void> _onRefresh() async {
    final resultBook = await _repository.bookData(_book!);

    return await resultBook.when<Future>(
      onError: (error) async {
        customLog(error.toString());
      },
      onSucess: (data) => _onSucess(data, false),
    );
  }

  Future<void> _onSucess(Book data, [bool onInit = true]) async {
    if (data == _book) return;
    ColorScheme? bookColorScheme;
    try {
      bookColorScheme = await ColorScheme.fromImageProvider(
        brightness: Theme.of(context).brightness,
        provider: CachedNetworkImageProvider(
          data.img,
          cacheKey: data.img,
          maxHeight: 330,
          maxWidth: 245,
        ),
      );
    } catch (_) {}
    _cache.saveBook(data);
    setStateIfMounted(() {
      _book = data.copyWith(bookColorScheme: bookColorScheme);
      _setChapters(data.chapters);
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
    if (_chaptersOrders == event.value) return;

    setStateIfMounted(() {
      _chaptersOrders = event.value as bool;
      _reversedChapters();
    });
  }

  ScrollPhysics get _physics {
    if (_isLoading) return const NeverScrollableScrollPhysics();
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  Widget buildByArgument(
    BuildContext context,
    BookInformationArgs argument,
  ) {
    final themeData = Theme.of(context);

    final size = MediaQuery.sizeOf(context);

    return Theme(
      data: themeData.copyWith(colorScheme: _book?.bookColorScheme),
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
          chaptersOrders: _chaptersOrders,
          chapters: _chapters,
          index: _index,
          setListIndex: _handleSetListIndex,
          book: _book ?? argument.book,
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
                  SinopseWidget(sinopse: _book?.sinopse ?? ''),
                  const ChipBookController(),
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
    for (final sub in _subs) {
      sub.cancel();
    }
    if (_book != null) _cache.registerTask(_book!.id);
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
