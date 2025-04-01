// ignore_for_file: public_member_api_docs, sort_constructors_first, constant_identifier_names
import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/destinations/information_destination.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/destinations/release_destination.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/content_persistent_header.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/bottom_menu.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auto_cache/flutter_auto_cache.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class RefContentInformationView extends StatefulWidget {
  const RefContentInformationView({super.key});

  @override
  State<RefContentInformationView> createState() =>
      _RefContentkInformationViewState();
}

class _RefContentkInformationViewState
    extends State<RefContentInformationView> {
  late final ContentRepository _repository;
  // late final ConnectionChecker _connectionChecker;

  late final LibraryService _libraryService;
  late final BottomMenuController<Release> _bottomMenuController;
  late final LibraryController _libraryController;
  late final HistoricController _historicController;
  late final DownloadService _downloadService;
  late final HistoryService _historyService;
  late final AnimeSkipController _animeSkipController;

  final Debouncer _changeTabBarIndex = Debouncer(
    duration: Duration.zero,
  );

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Content? _content;

  bool _isLoading = true;
  bool _releasesIsLoading = false;
  int _index = 0;
  late Completer _initialRefresh;
  final Map<int, Releases> _releases = {};

  ContentInformationArgs? _informationArgs;

  @override
  void initState() {
    super.initState();
    _bottomMenuController = BottomMenuController(minHeight: 70);
    _historicController = context.read<HistoricController>();
    _historyService = HistoryService(_historicController);
    _libraryController = context.read<LibraryController>();
    _animeSkipController = context.read<AnimeSkipController>();
    _libraryService = context.read<LibraryService>();
    _downloadService = context.read<DownloadService>();
    _repository = context.read<ContentRepository>();
    scheduleMicrotask(_onInit);
  }

  void _onInit() async {
    if (!mounted) return;

    _initialRefresh = Completer();

    _informationArgs = await _parseArguments();

    _content = _informationArgs!.content;

    // if (_content?.cached == false &&
    //     !_libraryService.contains(content: _content)) {
    // }

    _loadContentData();
  }

  Future<ContentInformationArgs> _parseArguments() async {
    final args = ModalRoute.settingsOf(context)?.arguments;
    if (args is String) {
      return ContentInformationArgs.fromJson(args);
    } else {
      return args as ContentInformationArgs;
    }
  }

  Future<void> _loadContentData() async {
    _refreshIndicatorKey.currentState?.show();

    // Result<Content> contentCache = Result.success(_informationArgs!.content);

    // Future<void> getData() async {
    //   await _repository
    //       .getData(_informationArgs!.content)
    //       .timeout(const Duration(minutes: 1), onTimeout: _handleTimeout)
    //       .then(_handleResult);
    // }

    // if (_informationArgs!.content.releases.isEmpty) {
    //   contentCache = const Result.empty();
    // }

    // _refreshIndicatorKey.currentState?.show();

    // if (_content?.cached == true ||
    //     _informationArgs?.isLibrary == true &&
    //         _informationArgs?.content.releases.isNotEmpty == true) {
    //   _handleResult(contentCache);
    //   await Future.delayed(const Duration(seconds: 5));
    //   if (mounted) await getData();
    // } else {
    //   await getData();
    // }
  }

  void _handleResult(Result<Content> result) {
    final navigationState = Navigator.of(context);

    result.fold(
      onError: navigationState.pop,
      onSuccess: _onSuccess,
    );
  }

  Result<Content> _handleTimeout() {
    if (_informationArgs!.content.releases.length > 1 || _content!.cached) {
      return Result.success(_informationArgs!.content);
    }
    return Result.failure(TimeoutException("Tempo excedido"));
  }

  void _handleSetListIndex(int index) async {
    if (index == _index) return;

    setState(() {
      _index = index;
      _releasesIsLoading = _releases[index] == null;
    });

    if (_releasesIsLoading) {
      await _getReleases(_content!.copyWith(releases: Releases()));
    } else {
      setState(() {
        _content = _content!.copyWith(releases: _releases[index]);
      });
    }
  }

  void _onSuccess(Content data,
      [bool refresh = false, bool forceSaveCache = false]) async {
    _releases.clear();

    if (_content?.releases.length == data.releases.length && !refresh) {
      if (!_initialRefresh.isCompleted) _initialRefresh.complete();
      _isLoading = false;
      return;
    }

    if (data is Anime) {
      _processAnimeReleases(data);
    } else {
      _releases[_index] = data.releases;
    }

    setState(() {
      _content = data.copyWith(
        releases: _releases[_index],
        cached: true,
      );
      _releasesIsLoading = false;
      _isLoading = false;
    });

    if (!_informationArgs!.isLibrary) {
      AutoCache.data.saveJson(key: data.stringID, data: _content!.toJson());
    }
    if (!_initialRefresh.isCompleted) _initialRefresh.complete();
  }

  // Future<bool> _shouldSaveCache(Content data, bool forceSaveCache) async {
  //   return ((await AutoCache.data.getJson(key: data.stringID)).data == null ||
  //       forceSaveCache ||
  //       _content!.cached == true);
  // }

  void _processAnimeReleases(Anime data) {
    for (var release in data.releases) {
      if (release.pageNumber != null) {
        final pageIndex = release.pageNumber! - 1;
        if (_releases[pageIndex] == null) {
          _releases[pageIndex] = Releases()..add(release);
        } else {
          _releases[pageIndex]?.add(release);
        }
      }
    }
  }

  Future<void> _getReleases(Content content, [bool onRefresh = false]) async {
    final releases = _releases[_index];

    if (releases == null || onRefresh) {
      final result = await _repository.getReleases(content, _index + 1);

      result.fold(
        onSuccess: (data) {
          _releases[_index] = data.releases;

          _onSuccess(data);
        },
      );
    } else {
      _releases[_index] = content.releases;
    }
  }

  Future<void> _downloadRelease(Release release) async {
    final localContext =
        GoRouter.of(context).routerDelegate.navigatorKey.currentContext;
    final LibraryController libraryController =
        context.read<LibraryController>();
    final HistoricController historicController =
        context.read<HistoricController>();

    final HistoryService historyService = HistoryService(historicController);

    switch (release) {
      case Episode data when mounted && _content is Anime:
        await _downloadService.downloadReleaseVideoByHLS(
          data,
          _content!,
          _repository,
          statisticsCallback: (statistics) async {},
          onResult: (result) async {
            if (result is Success) {
              final AnimeEntity animeEntity =
                  _libraryService.getContentEntityByStringID(
                _content!.stringID,
                orElse: () => (_content! as Anime).toEntity(
                  createdAt: DateTime.now(),
                ),
              );

              final EpisodeEntity episodeEntity = historyService.getHistoric(
                release: data,
                content: _content,
                orElse: () => data.toEntity(anime: _content as Anime),
              ) as EpisodeEntity;

              animeEntity.episodes.add(episodeEntity);

              await libraryController.add(contentEntity: animeEntity);
              await historicController.add(historyEntity: episodeEntity);
            }

            switch (result) {
              case Cancel _:
                break;
              case Failure error when localContext?.mounted == true:
                localContext?.appSnackBar.onError(error);
                break;
              case Failure _:
                break;
              case Success _:
                localContext?.appSnackBar.show(
                  Text('Baixado com sucesso: ${data.title}'),
                  duration: Duration(seconds: 5),
                );

                break;
              case Empty _:
                break;
            }
          },
        );

        break;
    }
  }

  void _handleLongPressed(Release release) {
    if (_content == null) return;
    final indexOf = _content!.releases.indexOf(release);
    customLog(indexOf);
    _bottomMenuController.args = release;

    _bottomMenuController.open();
  }

  @override
  void didChangeDependencies() {
    if (_content == null) {
      final argsContent =
          ModalRoute.settingsOf(context)?.arguments as ContentInformationArgs;
      _content = argsContent.content;
    }

    super.didChangeDependencies();
  }

  bool get noContent =>
      (_content?.sinopse ?? "").isEmpty &&
      _content?.anilistMedia == null &&
      (_content?.anilistMedia?.genres == null ||
          (_content?.genres.isEmpty ?? false)) &&
      _content?.anilistMedia?.characters == null &&
      _content?.anilistMedia?.staff == null;

  @override
  Widget build(BuildContext context) {
    final sizeOf = MediaQuery.sizeOf(context);

    final themeData = Theme.of(context);

    final libraryService = context.watch<LibraryService>();

    // final appSnackBar = context.appSnackBar;

    customLog('$widget[build]');
    // FlexThemeData.dark(colors: FlexSchemeColor.from(primary: _content!.anilistMedia!.coverImage!.color!.fromHex));

    return Theme(
      data: themeData,
      // data: FlexThemeData.dark(
      //   darkIsTrueBlack: false,
      //   colors: FlexSchemeColor.from(
      //     primary: _content!.anilistMedia!.coverImage!.color!.fromHex,
      //   ),
      //   tones: FlexTones.material(themeData.brightness),
      // colorScheme: _content?.anilistMedia?.coverImage?.color != null
      //     ? ColorScheme.fromSeed(
      //         seedColor: _content!.anilistMedia!.coverImage!.color!.fromHex,
      //         brightness: themeData.brightness,
      //       )
      //     : null,
      // ),
      child: DefaultTabController(
        length: 2,
        child: ContentScope(
          index: _index,
          onLongPressed: _handleLongPressed,
          informationArgs: _informationArgs,
          isLoading: _isLoading,
          setListIndex: _handleSetListIndex,
          downloadRelease: _downloadRelease,
          releases: _releases,
          content: _content,
          releasesIsLoading: _releasesIsLoading,
          builder: (context) => BottomMenu(
            isDismissible: true,
            bottomMenuController: _bottomMenuController,
            buttons: (context) {
              return OverflowBar(
                spacing: 8,
                overflowAlignment: OverflowBarAlignment.center,
                children: const [],
              );
            },
            child: Builder(builder: (context) {
              return Scaffold(
                body: RefreshIndicator(
                  key: _refreshIndicatorKey,
                  notificationPredicate: (notification) {
                    if (notification is OverscrollNotification) {
                      return notification.depth == 2;
                    }
                    return notification.depth == 0;
                  },
                  onRefresh: () async {
                    // if (!_enableRefreshIndicator) return;
                    setState(() {
                      _isLoading = true;
                    });

                    Result<Content> contentCache =
                        Result.success(_informationArgs!.content);

                    Future<void> getData() async {
                      await _repository
                          .getData(_informationArgs!.content)
                          .timeout(const Duration(minutes: 1),
                              onTimeout: _handleTimeout)
                          .then(_handleResult);
                    }

                    if (_informationArgs!.content.releases.isEmpty) {
                      contentCache = const Result.empty();
                    }

                    if (_content?.cached == true ||
                        _informationArgs?.isLibrary == true &&
                            _informationArgs?.content.releases.isNotEmpty ==
                                true) {
                      _handleResult(contentCache);
                      await Future.delayed(const Duration(seconds: 3));
                      if (mounted) await getData();
                    } else {
                      await getData();
                    }

                    // customLog(_content?.cached == true);
                    // _initialRefresh = Completer();
                    // if (_content?.cached == false &&
                    //     !_libraryService.contains(content: _content)) {
                    //   await _initialRefresh.future;
                    //   return;
                    // }

                    // if (_content == null) return;

                    // await _repository.getData(_content!).timeout(
                    //   const Duration(seconds: 15),
                    //   onTimeout: () {
                    //     if (_informationArgs!.content.releases.length > 1 ||
                    //         _content!.cached) {
                    //       return Result.success(_informationArgs!.content);
                    //     }
                    //     return Result.failure(
                    //       TimeoutException("Tempo excedido"),
                    //     );
                    //   },
                    // ).then((result) {
                    //   result.fold(
                    //     onSuccess: (result) => _onSuccess(result, false, true),
                    //     onError: appSnackBar.onError,
                    //   );
                    // });
                  },
                  child: NestedScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverAppBar(
                        expandedHeight: sizeOf.height * .40,
                        flexibleSpace: const FlexibleSpaceBar(
                          background: ContentHeader(),
                          collapseMode: CollapseMode.pin,
                        ),
                        actions: [
                          IconButton(
                            onPressed: () async {
                              customLog(
                                  'IconButton[MdiIcons.heart|MdiIcons.heartOutline] tapped title: ${_content!.title} - id: ${_content!.stringID}');
                              if (libraryService.favoritesIDS
                                  .contains(_content!.stringID)) {
                                _libraryController.remove(
                                  contentEntity: _content!.toEntity(),
                                );
                              } else {
                                _saveData(_content);
                              }
                            },
                            icon: FadeThroughTransitionSwitcher(
                              enableSecondChild:
                                  libraryService.favoritesIDS.contains(
                                _content?.stringID,
                              ),
                              secondChild: Icon(
                                MdiIcons.heart,
                                color: Colors.red,
                              ),
                              child: Icon(MdiIcons.heartOutline),
                            ),
                          ),
                        ],
                        bottom: TabBar(
                          indicatorSize: TabBarIndicatorSize.tab,
                          tabAlignment: TabAlignment.fill,
                          enableFeedback: true,
                          onTap: (index) {
                            final data = ContentTabBar.values.elementAt(index);
                            final disable =
                                noContent && data == ContentTabBar.INFORMATION;
                            if (disable) {
                              DefaultTabController.maybeOf(context)
                                  ?.animateTo(0);
                            }
                          },
                          tabs: ContentTabBar.values.map(
                            (data) {
                              final disable = noContent &&
                                  data == ContentTabBar.INFORMATION;
                              return Tab(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      data.getIconData(_content!),
                                      color: disable
                                          ? themeData.disabledColor
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Center(
                                      child: Text(
                                        data.getTitle(_content!),
                                        style: TextStyle(
                                          color: disable
                                              ? themeData.disabledColor
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ],
                    body: TabBarView(
                      physics: _isLoading || noContent
                          ? const NeverScrollableScrollPhysics()
                          : const PageScrollPhysics(),
                      children: const [
                        ReleaseDestination(),
                        InformationDestination(),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // _bottomMenuController.dispose();
    _changeTabBarIndex.cancel();
    _saveData();
    super.dispose();
  }

  void _saveData([Content? otherData]) async {
    if (otherData != null ||
        _libraryService.contains(content: otherData ?? _content)) {
      ContentEntity? contentEntity =
          await _libraryService.getContentEntityByStringIDAll(
        otherData?.stringID ?? _content!.stringID,
      );

      contentEntity ??= otherData?.toEntity(
        createdAt: DateTime.now(),
        isFavorite: true,
      );

      contentEntity = switch (contentEntity) {
        AnimeEntity data => data..isFavorite = true,
        BookEntity data => data..isFavorite = true,
        _ => throw UnimplementedError(),
      };

      final List<HistoryEntity> historyEntities = [];

      // final HistoryService historyService = HistoryService(_historicController);

      for (final episode in (otherData ?? _content)!.releases) {
        final entity = _historyService.getHistoric<HistoryEntity>(
          release: episode,
          orElse: () {
            return switch (episode) {
              Episode data => data.toEntity(
                  anime: (otherData ?? _content) as Anime,
                ),
              Chapter data => data.toEntity(0.0, null, null),
              _ => throw UnimplementedError(),
            };
          },
        );

        if (entity != null) {
          historyEntities.add(entity);
          switch (contentEntity) {
            case AnimeEntity data when entity is EpisodeEntity:
              data.episodes.add(entity);
            case BookEntity data when entity is ChapterEntity:
              data.chapters.add(entity);
          }
        }
      }

      if (contentEntity case AnimeEntity data
          when data.animeSkip.value != null) {
        await _animeSkipController.save(data.animeSkip.value!);
      }
      await _libraryController.add(contentEntity: contentEntity);

      await _historicController.addAll(historyEntities: historyEntities);
    }
  }
}
