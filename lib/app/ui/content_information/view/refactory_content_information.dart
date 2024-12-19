// ignore_for_file: public_member_api_docs, sort_constructors_first, constant_identifier_names
import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/destinations/information_destination.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/destinations/release_destination.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/content_persistent_header.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';
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

class _RefContentkInformationViewState extends State<RefContentInformationView>
    with SubscriptionsMixin, SingleTickerProviderStateMixin {
  late final ContentRepository _repository;
  late final TabController _bottomTabController;
  // late final ConnectionChecker _connectionChecker;

  late final LibraryService _libraryService;
  late final BottomMenuController<Release> _bottomMenuController;
  late final LibraryController _libraryController;
  late final HistoricController _historicController;
  late final DownloadService _downloadService;
  late final HistoryService _historyService;

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
    _bottomTabController = TabController(length: 2, vsync: this);
    _historicController = context.read<HistoricController>();
    _historyService = HistoryService(_historicController);
    _libraryController = context.read<LibraryController>();
    _libraryService = context.read<LibraryService>();
    _downloadService = context.read<DownloadService>();
    _repository = context.read<ContentRepository>();
    scheduleMicrotask(_onInit);
  }

  void _onInit() async {
    if (!mounted) return;

    _initialRefresh = Completer();

    final args = ModalRoute.settingsOf(context)?.arguments;

    if (args is String) {
      _informationArgs = ContentInformationArgs.fromJson(args);
    } else {
      _informationArgs = args as ContentInformationArgs;
    }

    _content = _informationArgs!.content;

    final navigationState = Navigator.of(context);
    Result<Content> contentCache = Result.success(_informationArgs!.content);

    if (_informationArgs!.content.releases.isEmpty) {
      contentCache = const Result.empty();
    }

    if (_content?.cached == false &&
        !_libraryService.contains(content: _content)) {
      _refreshIndicatorKey.currentState?.show();
    }

    final resultCotent = (contentCache is Success && _content!.cached == true)
        ? contentCache
        : await _repository.getData(_informationArgs!.content).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              if (_informationArgs!.content.releases.length > 1 ||
                  _content!.cached) {
                return Result.success(_informationArgs!.content);
              }
              return Result.failure(
                TimeoutException("Tempo excedido"),
              );
            },
          );

    resultCotent.fold(
      onError: navigationState.pop,
      onSuccess: _onSuccess,
    );

    // if (contentCache is Success && _informationArgs.getData) {
    //   addPostFrameCallback((timer) {
    //     _repository.getData(_content).then((result) {
    //       result.fold(onSuccess: _onSuccess);
    //     });
    //   });
    // }
  }

  void _onSuccess(
    Content data, [
    bool refresh = false,
    bool forceSaveCache = false,
  ]) async {
    // if(data is Anime && data.totalOfPages != null) {
    //     List.generate(data.totalOfPages!, (index) => )
    // }

    _releases.clear();

    if (_releases.isEmpty && data is Anime) {
      for (var data in data.releases) {
        if (data.pageNumber != null) {
          customLog(data.pageNumber! - 1);

          if (_releases[data.pageNumber! - 1] == null) {
            _releases[data.pageNumber! - 1] = Releases()..add(data);
          } else {
            _releases[data.pageNumber! - 1]?.add(data);
          }
        }
      }
    } else {
      _releases[_index] = data.releases;
    }

    setState(() {
      _content = _content?.merge(data.copyWith(
        releases: _releases[_index],
        cached: true,
      ));
      _releasesIsLoading = false;
      _isLoading = false;
    });

    if ((await AutoCache.data.getJson(key: data.stringID)).data == null ||
        forceSaveCache ||
        _content!.cached == true) {
      AutoCache.data.saveJson(key: data.stringID, data: _content!.toJson());
    }
    _initialRefresh.complete();
  }

  void _handleSetListIndex(int index) async {
    if (index == _index) return;

    setStateIfMounted(() => _index = index);

    final releases = _releases[index];

    if (releases == null) {
      setStateIfMounted(() => _releasesIsLoading = true);
      await _getReleases(_content!.copyWith(releases: Releases()));
      setStateIfMounted(() => _releasesIsLoading = false);
    } else {
      setStateIfMounted(() {
        if (_releasesIsLoading) _releasesIsLoading = false;
        _content = _content!.copyWith(releases: releases);
      });
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

    switch (release) {
      case Episode data when mounted && _content is Anime:
        await _downloadService.downloadReleaseVideoByHLS(
          data,
          _content!,
          _repository,
          statisticsCallback: (statistics) async {},
          onResult: (result) async {
            if (result is Success) {
              AnimeEntity animeEntity = _content!.toEntity() as AnimeEntity;

              final bAnimeEntity =
                  _libraryService.getContentEntityByStringID(_content!.stringID)
                      as AnimeEntity?;

              if (bAnimeEntity != null) {
                animeEntity = bAnimeEntity.merge(animeEntity) as AnimeEntity;
              }

              final EpisodeEntity episodeEntity =
                  _historicController.entities.firstWhere(
                (entity2) => switch (entity2) {
                  EpisodeEntity data => data.stringID.contains(data.stringID),
                  _ => false,
                },
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
                customLog('Terminou');
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

    _bottomMenuController.open(
      onClose: () async {},
    );
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

  @override
  Widget build(BuildContext context) {
    final sizeOf = MediaQuery.sizeOf(context);

    customLog('$widget[build]');

    final libraryService = context.watch<LibraryService>();

    return ContentScope(
      bottomTabController: _bottomTabController,
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
            textDirection: Directionality.of(context),
            overflowAlignment: OverflowBarAlignment.center,
            children: const [],
          );
        },
        child: Scaffold(
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            notificationPredicate: (notification) {
              if (notification is OverscrollNotification) {
                return notification.depth == 2;
              }
              return notification.depth == 0;
            },
            onRefresh: () async {
              _initialRefresh = Completer();
              if (_content?.cached == false &&
                  !_libraryService.contains(content: _content)) {
                await _initialRefresh.future;
                return;
              }

              if (_content == null) return;
              final appSnackBar = context.appSnackBar;

              await _repository.getData(_content!).timeout(
                const Duration(seconds: 15),
                onTimeout: () {
                  if (_informationArgs!.content.releases.length > 1 ||
                      _content!.cached) {
                    return Result.success(_informationArgs!.content);
                  }
                  return Result.failure(
                    TimeoutException("Tempo excedido"),
                  );
                },
              ).then((result) {
                result.fold(
                  onSuccess: (result) => _onSuccess(result, false, true),
                  onError: appSnackBar.onError,
                );
              });
            },
            child: NestedScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              key: const PageStorageKey("content_pageStorageKey"),
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  expandedHeight: sizeOf.height * .40,
                  flexibleSpace: const FlexibleSpaceBar(
                    background: ContentHeader(),
                    collapseMode: CollapseMode.pin,
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        customLog(
                            'IconButton[MdiIcons.heart|MdiIcons.heartOutline] tapped title: ${_content!.title} - id: ${_content!.stringID}');
                        if (libraryService.favoritesIDS
                            .contains(_content!.stringID)) {
                          _libraryController.remove(
                              contentEntity: _content!.toEntity());
                        } else {
                          _libraryController.add(
                            contentEntity: _content!.toEntity(isFavorite: true),
                          );
                        }
                      },
                      icon: FadeThroughTransitionSwitcher(
                        enableSecondChild: libraryService.favoritesIDS.contains(
                          _content?.stringID,
                        ),
                        secondChild: Icon(MdiIcons.heart, color: Colors.red),
                        child: Icon(MdiIcons.heartOutline),
                      ),
                    ),
                  ],
                  bottom: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabAlignment: TabAlignment.fill,
                    controller: _bottomTabController,
                    tabs: ContentTabBar.values
                        .map(
                          (e) => Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(e.getIconData(_content!)),
                                const SizedBox(width: 8),
                                Center(child: Text(e.getTitle(_content!))),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: TabBarView(
                  physics: _isLoading
                      ? const NeverScrollableScrollPhysics()
                      : const PageScrollPhysics(),
                  controller: _bottomTabController,
                  children: const [
                    ReleaseDestination(),
                    InformationDestination(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bottomTabController.dispose();
    // _bottomMenuController.dispose();
    _changeTabBarIndex.cancel();
    _saveData();
    super.dispose();
  }

  void _saveData() {
    if (_libraryService.contains(content: _content)) {
      ContentEntity contentEntity = _content!.toEntity();

      final entity =
          _libraryService.getContentEntityByStringID(_content!.stringID);

      if (_libraryService.favoritesIDS.contains(_content!.stringID) &&
          !_informationArgs!.getData) {
        _historicController
            .addAll(
          historyEntities: _content!.releases
              .map(
                (e) => switch (e) {
                  Episode data => data.toEntity(anime: _content as Anime),
                  Chapter data => data.toEntity(0.0, null, null),
                  _ => null,
                },
              )
              .nonNulls
              .toList()
            ..removeWhere(_historyService.entities.contains),
          // ..removeWhere(
          //   (entity) {

          //     return _historicController.entities
          //             .firstWhereOrNull((entity2) => switch (entity2) {
          //                   EpisodeEntity data when entity is EpisodeEntity =>
          //                     data.stringID.contains(entity.stringID),
          //                   ChapterEntity data when entity is ChapterEntity =>
          //                     data.stringID.contains(entity.stringID),
          //                   _ => false,
          //                 }) !=
          //         null;
          //   },
          // ),
        )
            .whenComplete(() {
          if (entity != null) {
            contentEntity = contentEntity.merge(entity);
          }

          _libraryController.add(
            contentEntity: _content!.toEntity(
              updatedAt: DateTime.now(),
              isFavorite: true,
            ),
          );
        });
      } else {
        if (entity != null) {
          contentEntity = contentEntity.merge(entity);
        }

        _libraryController.add(
          contentEntity: _content!.toEntity(
            updatedAt: DateTime.now(),
            isFavorite: true,
          ),
        );
      }
    }
  }
}
