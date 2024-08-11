// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:async';

// import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
// import 'package:app_wsrb_jsr/app/ui/content_information/destinations/build_contents.dart';
// import 'package:app_wsrb_jsr/app/ui/content_information/widgets/chip_content_controller.dart';
// import 'package:app_wsrb_jsr/app/ui/content_information/widgets/content_persistent_header.dart';
// import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
// import 'package:app_wsrb_jsr/app/ui/content_information/widgets/sinopse.dart';
// import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';
// import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
// import 'package:app_wsrb_jsr/app/utils/custom_states.dart';
// import 'package:content_library/content_library.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_auto_cache/flutter_auto_cache.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';

// class BookInformationView extends StatefulWidget {
//   const BookInformationView({super.key});

//   @override
//   State<BookInformationView> createState() => _BookInformationStateView();
// }

// class _BookInformationStateView
//     extends StateByArgument<BookInformationView, ContentInformationArgs>
//     with SubscriptionsMixin {
//   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();

//   late final ContentRepository _repository;
//   late final ConnectionChecker _connectionChecker;
//   late final DownloadService _downloadService;
//   bool _isLoading = true;
//   bool _releasesIsLoading = false;
//   final Map<int, Releases> _releases = {};
//   Content? _content;
//   int _index = 0;

//   @override
//   void initState() {
//     super.initState();
//     _connectionChecker = context.read<ConnectionChecker>();
//     _downloadService = context.read<DownloadService>();
//     _repository = context.read<ContentRepository>();
//     Future.microtask(_onInit);
//   }

//   void _handleSetListIndex(int index) async {
//     if (index == _index) return;

//     setStateIfMounted(() => _index = index);

//     final releases = _releases[index];

//     if (releases == null) {
//       setStateIfMounted(() => _releasesIsLoading = true);
//       await _getReleases(_content!.copyWith(releases: Releases()));
//       setStateIfMounted(() => _releasesIsLoading = false);
//     } else {
//       setStateIfMounted(() {
//         if (_releasesIsLoading) _releasesIsLoading = false;
//         _content = _content!.copyWith(releases: releases);
//       });
//     }
//   }

//   Future<void> _downloadRelease(Release release) async {
//     final localContext =
//         GoRouter.of(context).routerDelegate.navigatorKey.currentContext;
//     final LibraryController libraryController =
//         context.read<LibraryController>();
//     final HistoricController historicController =
//         context.read<HistoricController>();

//     final LibraryService libraryService =
//         LibraryService(libraryController, context.read());

//     switch (release) {
//       case Episode data when mounted && _content is Anime:
//         await _downloadService.downloadReleaseVideoByHLS(
//           data,
//           _content!,
//           _repository,
//           statisticsCallback: (statistics) async {},
//           onResult: (result) async {
//             if (result is Success) {
//               AnimeEntity animeEntity = _content!.toEntity() as AnimeEntity;

//               final bAnimeEntity =
//                   libraryService.getContentEntityByStringID(_content!.stringID)
//                       as AnimeEntity?;

//               if (bAnimeEntity != null) {
//                 animeEntity = animeEntity.merge(bAnimeEntity) as AnimeEntity;
//               }

//               animeEntity.episodes.add(data.toEntity(anime: _content as Anime));

//               await libraryController.add(contentEntity: animeEntity);
//               await historicController.add(
//                 historyEntity: data.toEntity(anime: _content as Anime),
//               );
//             }

//             switch (result) {
//               case Cancel _:
//                 break;
//               case Failure error when localContext?.mounted == true:
//                 localContext?.appSnackBar.onError(error);
//                 break;
//               case Failure _:
//                 break;
//               case Success _:
//                 customLog('Terminou');
//                 break;
//               case Empty _:
//                 break;
//             }
//           },
//         );

//         break;
//     }
//   }

//   void _onInit() async {
//     final args = argument();
//     final navigationState = Navigator.of(context);

//     final cache = await AutoCache.data.getJson(
//       key: args.content.stringID,
//     );

//     final contentCache = switch (args.content) {
//       Anime _ when cache.data != null =>
//         Result.success(Anime.fromMap(cache.data!)),
//       Book _ when cache.data != null =>
//         Result.success(Book.fromMap(cache.data!)),
//       _ => const Result<Content>.cancel(),
//     };

//     final resultCotent = (contentCache is Success)
//         ? contentCache
//         : await _repository.getData(args.content).timeout(
//               const Duration(seconds: 5),
//               onTimeout: () => Result.failure(
//                 TimeoutException("Tempo excedido"),
//               ),
//             );

//     resultCotent.fold(
//       onError: navigationState.pop,
//       onSuccess: _onSucess,
//     );

//     if (contentCache is Success &&
//         _connectionChecker.connectivityResult.isNotEmpty) {
//       setStateIfMounted(() => _releasesIsLoading = true);
//       await _repository.getReleases(_content!, -1).whenComplete(() {
//         setStateIfMounted(() => _releasesIsLoading = false);
//       });
//     }
//   }

//   Future<void> _onRefresh() async {
//     setStateIfMounted(() => _releasesIsLoading = true);
//     final appSnackBar = context.appSnackBar;
//     final resultBook = await _repository.getData(_content!);

//     return await resultBook.fold<Future>(
//       onError: appSnackBar.onError,
//       onSuccess: (data) => _onSucess(data, true),
//     );
//   }

//   Future<void> _getReleases(Content content, [bool onRefresh = false]) async {
//     final releases = _releases[_index];

//     if (releases == null || onRefresh) {
//       final result = await _repository.getReleases(content, _index + 1);

//       result.fold(
//         onSuccess: (data) {
//           // final stringID = data.releases.first.stringID;

//           _releases[_index] = data.releases;

//           setStateIfMounted(() => _content = data);
//         },
//       );
//     } else {
//       _releases[_index] = content.releases;
//     }
//   }

//   Future<void> _onSucess(Content data, [bool onRefresh = false]) async {
//     if (!mounted) return;
//     final libraryController = context.read<LibraryController>();

//     final LibraryService libraryService =
//         LibraryService(libraryController, context.read());

//     if (data.releases.isEmpty) {
//       await _getReleases(data, onRefresh);
//     } else {
//       _releases[_index] = data.releases;
//     }

//     if (libraryService.contains(content: data)) {
//       ContentEntity contentEntity = data.toEntity();
//       final entity =
//           libraryService.getContentEntityByStringID(_content!.stringID);

//       if (entity != null) {
//         contentEntity = contentEntity.merge(entity);
//       }

//       libraryController.add(
//         contentEntity: data.toEntity(
//           updatedAt: DateTime.now(),
//           isFavorite: true,
//         ),
//       );
//     }

//     setStateIfMounted(() {
//       if (data is Anime && _content != null) {
//         _content = (_content as Anime).merge(data);
//       } else {
//         _content = data;
//       }

//       _releasesIsLoading = false;
//       _isLoading = false;
//     });
//     AutoCache.data.saveJson(key: data.stringID, data: data.map);
//   }

//   ScrollPhysics get _physics {
//     if (_isLoading) return const NeverScrollableScrollPhysics();
//     return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
//   }

//   @override
//   Widget buildByArgument(
//     BuildContext context,
//     ContentInformationArgs argument,
//   ) {
//     final size = MediaQuery.sizeOf(context);

//     return BookInformationScope(
//       downloadRelease: _downloadRelease,
//       index: _index,
//       releasesIsLoading: _releasesIsLoading,
//       setListIndex: _handleSetListIndex,
//       content: _content ?? argument.content,
//       isLoading: _isLoading,
//       builder: (context) => Scaffold(
//         body: RefreshIndicator(
//           key: _refreshIndicatorKey,
//           onRefresh: _onRefresh,
//           child: CustomScrollView(
//             physics: _physics,
//             slivers: [
//               SliverPersistentHeader(
//                 pinned: true,
//                 floating: true,
//                 delegate: ContentPersistentHeaderDelegate(
//                   content: _content ?? argument.content,
//                   isLoading: _isLoading,
//                   maxExtent: size.height * .42,
//                   minExtent: 100,
//                 ),
//               ),
//               const SinopseWidget(),
//               const ChipContentController(),
//               const BuildContents(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _downloadService.clearDownloadList();
//     super.dispose();
//   }
// }
