// ignore_for_file: public_member_api_docs, sort_constructors_first, constant_identifier_names
import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/destinations/information_destination.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/destinations/release_destination.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/content_persistent_header.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
import 'package:app_wsrb_jsr/app/utils/custom_states.dart';
import 'package:content_library/content_library.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
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
    extends StateByArgument<RefContentInformationView, ContentInformationArgs>
    with SubscriptionsMixin, SingleTickerProviderStateMixin {
  late final ContentRepository _repository;
  late final TabController _bottomTabController;
  // late final ConnectionChecker _connectionChecker;
  late final LibraryService _libraryService;
  late final LibraryController _libraryController;
  late final HistoricController _historicController;
  late final DownloadService _downloadService;
  late final PageController _pageController;

  final Debouncer _changeTabBarIndex = Debouncer(
    duration: Duration.zero,
  );

  late Content _content = _informationArgs.content;
  bool _isLoading = true;
  bool _releasesIsLoading = false;
  int _index = 0;

  final Map<int, Releases> _releases = {};

  late final ContentInformationArgs _informationArgs = argument();

  @override
  void initState() {
    super.initState();
    _bottomTabController = TabController(length: 2, vsync: this)
      ..addListener(_bottomTabControllerListener);
    _pageController = PageController();
    _historicController = context.read<HistoricController>();
    _libraryController = context.read<LibraryController>();
    _libraryService = LibraryService(_libraryController, context.read());
    // _connectionChecker = context.read<ConnectionChecker>();
    _downloadService = context.read<DownloadService>();
    _repository = context.read<ContentRepository>();
    scheduleMicrotask(_onInit);
  }

  void _bottomTabControllerListener() {
    _pageController.animateToPage(
      _bottomTabController.index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.ease,
    );
  }

  void _onInit() async {
    if (!mounted) return;
    final navigationState = Navigator.of(context);
    Result<Content> contentCache = Result.success(_informationArgs.content);

    if (_informationArgs.getData) {
      final cache = await AutoCache.data.getJson(
        key: _informationArgs.content.stringID,
      );
      contentCache = switch (_informationArgs.content) {
        Anime _ when cache.data != null =>
          Result.success(Anime.fromMap(cache.data!)),
        Book _ when cache.data != null =>
          Result.success(Book.fromMap(cache.data!)),
        _ => const Result<Content>.cancel(),
      };
    }

    if (_informationArgs.content.releases.isEmpty) {
      contentCache = const Result.empty();
    }

    final resultCotent = (contentCache is Success)
        ? contentCache
        : await _repository.getData(_informationArgs.content).timeout(
              const Duration(seconds: 5),
              onTimeout: () => Result.failure(
                TimeoutException("Tempo excedido"),
              ),
            );

    resultCotent.fold(
      onError: navigationState.pop,
      onSuccess: _onSuccess,
    );

    if (contentCache is Success && _informationArgs.getData) {
      addPostFrameCallback((timer) {
        _repository.getData(_informationArgs.content).then((result) {
          result.fold(onSuccess: _onSuccess);
        });
      });
    }
  }

  void _onSuccess(Content data, [bool refresh = false]) {
    // if(data is Anime && data.totalOfPages != null) {
    //     List.generate(data.totalOfPages!, (index) => )
    // }

    if (_releases.isEmpty && data is Anime) {
      for (var data in _content.releases) {
        if (data is Episode && data.pageNumber != null) {
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

    setStateIfMounted(() {
      _content = data.copyWith(releases: _releases[_index]);

      _isLoading = false;
    });

    ifMounted(() async {
      if (_informationArgs.getData) {
        AutoCache.data.saveJson(key: data.stringID, data: data.map);
      }
    });
  }

  void _handleSetListIndex(int index) async {
    if (index == _index) return;

    setStateIfMounted(() => _index = index);

    final releases = _releases[index];

    if (releases == null) {
      setStateIfMounted(() => _releasesIsLoading = true);
      await _getReleases(_content.copyWith(releases: Releases()));
      setStateIfMounted(() => _releasesIsLoading = false);
    } else {
      setStateIfMounted(() {
        if (_releasesIsLoading) _releasesIsLoading = false;
        _content = _content.copyWith(releases: releases);
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

    final LibraryService libraryService =
        LibraryService(libraryController, context.read());

    switch (release) {
      case Episode data when mounted && _content is Anime:
        await _downloadService.downloadReleaseVideoByHLS(
          data,
          _content,
          _repository,
          statisticsCallback: (statistics) async {},
          onResult: (result) async {
            if (result is Success) {
              AnimeEntity animeEntity = _content.toEntity() as AnimeEntity;

              final bAnimeEntity =
                  libraryService.getContentEntityByStringID(_content.stringID)
                      as AnimeEntity?;

              if (bAnimeEntity != null) {
                animeEntity = animeEntity.merge(bAnimeEntity) as AnimeEntity;
              }

              animeEntity.episodes.add(data.toEntity(anime: _content as Anime));

              await libraryController.add(contentEntity: animeEntity);
              await historicController.add(
                historyEntity: data.toEntity(anime: _content as Anime),
              );
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

  @override
  Widget buildByArgument(
    BuildContext context,
    ContentInformationArgs argument,
  ) {
    return ContentScope(
      bottomTabController: _bottomTabController,
      index: _index,
      informationArgs: _informationArgs,
      isLoading: _isLoading,
      setListIndex: _handleSetListIndex,
      downloadRelease: _downloadRelease,
      releases: _releases,
      content: !_isLoading ? _content : argument.content,
      releasesIsLoading: _releasesIsLoading,
      builder: (context) {
        final sizeOf = MediaQuery.sizeOf(context);
        final content = ContentScope.contentOf(context);

        return Scaffold(
          body: ExtendedNestedScrollView(
            onlyOneScrollInBody: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: sizeOf.height * .40,
                flexibleSpace: const FlexibleSpaceBar(
                  background: ContentHeader(),
                  stretchModes: [],
                  collapseMode: CollapseMode.pin,
                ),
                actions: [
                  Builder(builder: (context) {
                    final libraryService = LibraryService(
                      context.watch(),
                      context.watch(),
                    );
                    return IconButton(
                      onPressed: () {
                        customLog(
                            'IconButton[MdiIcons.heart|MdiIcons.heartOutline] tapped title: ${content.title} - id: ${content.stringID}');
                        if (libraryService.favoritesIDS
                            .contains(content.stringID)) {
                          _libraryController.remove(
                              contentEntity: content.toEntity());
                        } else {
                          _libraryController.add(
                            contentEntity: content.toEntity(isFavorite: true),
                          );
                        }
                      },
                      icon: FadeThroughTransitionSwitcher(
                        enableSecondChild: libraryService.favoritesIDS.contains(
                          content.stringID,
                        ),
                        secondChild: Icon(MdiIcons.heart, color: Colors.red),
                        child: Icon(MdiIcons.heartOutline),
                      ),
                    );
                  }),
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
                              Icon(e.getIconData(content)),
                              const SizedBox(width: 8),
                              Center(child: Text(e.getTitle(content))),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PageView(
                      physics: _isLoading
                          ? const NeverScrollableScrollPhysics()
                          : const PageScrollPhysics(),
                      onPageChanged: _bottomTabController.animateTo,
                      controller: _pageController,
                      children: const [
                        InformationDestination(),
                        ReleaseDestination(),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _bottomTabController
      ..removeListener(_bottomTabControllerListener)
      ..dispose();
    _changeTabBarIndex.cancel();
    _saveData();
    super.dispose();
  }

  void _saveData() {
    if (_libraryService.contains(content: _content)) {
      ContentEntity contentEntity = _content.toEntity();

      final entity =
          _libraryService.getContentEntityByStringID(_content.stringID);

      if (_libraryService.favoritesIDS.contains(_content.stringID) &&
          !_informationArgs.getData) {
        _historicController
            .addAll(
          historyEntities: _content.releases
              .map(
                (e) => switch (e) {
                  Episode data => data.toEntity(anime: _content as Anime),
                  Chapter data => data.toEntity(0.0, null, null),
                  _ => null,
                },
              )
              .nonNulls
              .toList(),
        )
            .whenComplete(() {
          if (entity != null) {
            contentEntity = contentEntity.merge(entity);
          }

          _libraryController.add(
            contentEntity: _content.toEntity(
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
          contentEntity: _content.toEntity(
            updatedAt: DateTime.now(),
            isFavorite: true,
          ),
        );
      }
    }
  }
}
