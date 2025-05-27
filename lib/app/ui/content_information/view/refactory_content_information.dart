// ignore_for_file: public_member_api_docs, sort_constructors_first, constant_identifier_names
import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/content_scaffold.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/bottom_menu.dart';
import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  late final BottomMenuController<Release> _bottomMenuController;
  late final LibraryController _libraryController;
  late final HistoricController _historicController;
  late final DownloadService _downloadService;

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

    _libraryController = context.read<LibraryController>();
    _animeSkipController = context.read<AnimeSkipController>();
    _downloadService = context.read<DownloadService>();
    _repository = context.read<ContentRepository>();
    scheduleMicrotask(_onInit);
  }

  void _onInit() async {
    if (!mounted) return;

    _initialRefresh = Completer();

    _informationArgs = _parseArguments();

    _content = _informationArgs!.content;

    // if (_content?.cached == false &&
    //     !_libraryService.contains(content: _content)) {
    // }

    _loadContentData();
  }

  Future<void> _loadContentData() async {
    if (_informationArgs?.isLibrary == true) {
      setStateIfMounted(() {
        _isLoading = false;
        _releasesIsLoading = false;
      });
      final data = _informationArgs!.content;
      if (data is Anime) {
        _processAnimeReleases(data);
      } else {
        _releases[_index] = data.releases;
      }
      return;
    }
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

    if (data is Anime) _processAnimeReleases(data);

    setState(() {
      _content = data.copyWith(
        releases: _releases[_index],
        cached: true,
      );
      _releasesIsLoading = false;
      _isLoading = false;
    });

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

    // if (!_informationArgs!.isLibrary) {
    //   AutoCache.data.saveJson(key: data.stringID, data: _content!.toJson());
    // }
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
          _releases[pageIndex] = Releases()
            ..addIfNoContains(release, release.isEqualStringID);
        } else {
          _releases[pageIndex]
              ?.addIfNoContains(release, release.isEqualStringID);
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

    final historicRepo = historicController.repo;

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
                  _libraryController.repo.getContentEntityByStringID(
                _content!.stringID,
                orElse: () => (_content! as Anime).toEntity(
                  createdAt: DateTime.now(),
                ),
              );

              final EpisodeEntity episodeEntity = historicRepo.getHistoric(
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
    _content ??= _parseArguments().content;

    super.didChangeDependencies();
  }

  ContentInformationArgs _parseArguments() {
    final args = ModalRoute.settingsOf(context)?.arguments;
    if (args is String) {
      return ContentInformationArgs.fromJson(args);
    } else {
      return args as ContentInformationArgs;
    }
  }

  bool get noContent =>
      (_content?.sinopse ?? "").isEmpty &&
      _content?.anilistMedia == null &&
      (_content?.anilistMedia?.genres == null ||
          (_content?.genres.isEmpty ?? false)) &&
      _content?.anilistMedia?.characters == null &&
      _content?.anilistMedia?.staff == null;

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    Future<void> getData() async {
      await _repository
          .getData(_informationArgs!.content)
          .timeout(const Duration(minutes: 1), onTimeout: _handleTimeout)
          .then(_handleResult);
    }

    await getData();
  }

  @override
  Widget build(BuildContext context) {
    customLog('$widget[build]');

    return DefaultTabController(
      length: 2,
      child: ContentScope(
        saveData: _saveData,
        index: _index,
        noContent: noContent,
        onLongPressed: _handleLongPressed,
        informationArgs: _informationArgs,
        isLoading: _isLoading,
        setListIndex: _handleSetListIndex,
        downloadRelease: _downloadRelease,
        releases: _releases,
        content: _content,
        releasesIsLoading: _releasesIsLoading,
        builder: (context) => BottomMenu(
          isDismissible: false,
          bottomMenuController: _bottomMenuController,
          buttons: (context) {
            return OverflowBar(
              spacing: 8,
              overflowAlignment: OverflowBarAlignment.center,
              children: const [],
            );
          },
          child: RefreshIndicator(
            notificationPredicate: (notification) {
              if (notification is OverscrollNotification) {
                return notification.depth == 2;
              }
              return notification.depth == 0;
            },
            onRefresh: _onRefresh,
            key: _refreshIndicatorKey,
            child: const ContentScaffold(),
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

  void _saveData() async {
    if (_content == null) return;
    final Content content = _content!;

    // Obtém ou cria a ContentEntity
    ContentEntity? contentEntity =
        await _libraryController.repo.getContentEntityByStringIDAll(
      content.stringID,
      orElse: () => content.toEntity(
        createdAt: DateTime.now(),
        isFavorite: true,
      ),
    );

    // final bool shouldSave = _libraryController.repo.contains(content: content);

    if (contentEntity == null) return;

    // Garante que os dados do Anilist estejam presentes
    if (contentEntity.anilistMedia == null) {
      contentEntity = contentEntity.copyWith(
        isFavorite: true,
        anilistMedia: content.anilistMedia,
      );
    }

    final List<HistoryEntity> historyEntities = [];

    final entries = content.releases.map(
      (release) {
        final entity = _historicController.repo.getHistoric<HistoryEntity>(
          release: release,
          orElse: () {
            return switch ((release, content)) {
              (Episode episode, Anime anime) => episode.toEntity(anime: anime),
              (Chapter chapter, Book _) => chapter.toEntity(0.0, null, null),
              _ => null,
            };
          },
        );
        if (entity == null) return null;
        return MapEntry(release, entity);
      },
    );

    for (var entry in entries.nonNulls) {
      final value = entry.value;
      final release = entry.key;

      switch (contentEntity) {
        case AnimeEntity anime when value is EpisodeEntity:
          final saveEpisode = EpisodeEntity.save(
            episode: release as Episode,
            anime: content as Anime,
            entity: value,
          );
          anime.episodes.add(saveEpisode);
          historyEntities.add(saveEpisode);

        case BookEntity book when value is ChapterEntity:
          book.chapters.add(value);
          historyEntities.add(value);
      }
    }

    // Salva configurações de pulo de anime se existirem
    if (contentEntity case AnimeEntity anime
        when anime.animeSkip.value != null) {
      await _animeSkipController.save(anime.animeSkip.value!);
    }

    // Salva os dados principais e históricos
    await _libraryController.add(contentEntity: contentEntity);
    await _historicController.addAll(historyEntities: historyEntities);
  }
}

// Widget de texto expansível
class _ExpandableText extends StatefulWidget {
  final String text;
  const _ExpandableText(this.text);

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final span = TextSpan(
      text: widget.text,
      style: TextStyle(color: Colors.white),
    );
    return LayoutBuilder(builder: (context, size) {
      // calcula altura de duas linhas
      final tp = TextPainter(
        maxLines: 2,
        text: span,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.maxWidth);

      final needsTrim = tp.didExceedMaxLines;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            maxLines: _expanded ? null : 2,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          if (needsTrim)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? "Show less" : "Show more",
                style: TextStyle(color: Colors.blueAccent, fontSize: 12),
              ),
            ),
        ],
      );
    });
  }
}
