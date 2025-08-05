// ignore_for_file: public_member_api_docs, sort_constructors_first, constant_identifier_names
import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/content_page.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/bottom_menu.dart';
import 'package:app_wsrb_jsr/app/utils/content_utils.dart';
import 'package:app_wsrb_jsr/app/utils/download_release_helper.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_plus/share_plus.dart';

class RefContentInformationView extends StatefulWidget {
  const RefContentInformationView({super.key});

  @override
  State<RefContentInformationView> createState() => _RefContentkInformationViewState();
}

class _RefContentkInformationViewState extends State<RefContentInformationView> {
  late Content _content;
  late Completer _initialRefresh;
  late ContentInformationArgs _informationArgs;

  late final ContentRepository _repository;
  late final BottomMenuController<List<String>> _bottomMenuController;
  late final LibraryController _libraryController;
  late final HistoricController _historicController;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final Map<int, Releases> _releases = {};

  bool _isLoading = true;
  bool _releasesIsLoading = false;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _bottomMenuController = BottomMenuController(minHeight: 60, initialArgs: []);
    _historicController = read<HistoricController>();
    _libraryController = read<LibraryController>();
    _repository = read<ContentRepository>();
    scheduleMicrotask(_onInit);
  }

  void _onInit() async {
    if (!mounted) return;
    _initialRefresh = Completer();
    await Future.delayed(const Duration(milliseconds: 850), _loadContentData);
  }

  Future<void> _loadContentData() async {
    if (_informationArgs.isLibrary) {
      setState(() {
        _isLoading = false;
        _releasesIsLoading = false;
      });
      final data = _informationArgs.content;
      _releases[_index] = data.releases;
      return;
    }
    _refreshIndicatorKey.currentState?.show();
  }

  void _handleResult(Result<Content> result) {
    final navigationState = Navigator.of(context);
    result.fold(onError: navigationState.pop, onSuccess: _onSuccess);
  }

  Result<Content> _handleTimeout() {
    if (_informationArgs.content.releases.length > 1 || _content.cached) {
      return Result.success(_informationArgs.content);
    }
    return Result.failure(TimeoutException("Tempo excedido"));
  }

  void _handleSetListIndex(int index) async {
    if (index == _index) return;

    setState(() {
      _index = index;
    });

    await _getReleases(_content.copyWith(releases: Releases()));
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void _onSuccess(
    Content data, [
    bool refresh = false,
    bool forceSaveCache = false,
  ]) async {
    setState(() {
      _content = data.copyWith(releases: _releases[_index], cached: true);
      _releases[_index] = data.releases;
      _releasesIsLoading = false;
      _isLoading = false;
    });

    if (_content.releases.length == data.releases.length && !refresh) {
      if (!_initialRefresh.isCompleted) _initialRefresh.complete();
      _isLoading = false;
      return;
    }

    if (!_initialRefresh.isCompleted) _initialRefresh.complete();
  }

  Future<void> _getReleases(Content content, [bool onRefresh = false]) async {
    final releases = _releases[_index];

    if (releases == null || onRefresh) {
      setState(() {
        _releasesIsLoading = true;
      });
      final result = await _repository.getReleases(content, _index + 1);

      result.fold(onSuccess: _onSuccess);
    } else {
      setState(() {
        _content = _content.copyWith(releases: _releases[_index]);
      });
    }
  }

  Future<void> _downloadRelease(Release release) async {
    if (mounted) {
      await DownloadReleaseHelper.download(context, release, _content);
    }
  }

  void _handleLongPressed(Release release) {
    final data = _bottomMenuController.args;
    if (data.contains(release.stringID)) {
      data.remove(release.stringID);
      _bottomMenuController.update();
    } else {
      data.add(release.stringID);
      _bottomMenuController.update();
    }

    if (data.isEmpty) {
      data.clear();
      _bottomMenuController.close();
    }

    // if (_bottomMenuController.args case List<String> data) {
    //   if (data.contains(release.stringID)) {
    //     data.remove(release.stringID);
    //     _bottomMenuController.update();
    //   } else {
    //     data.add(release.stringID);
    //     _bottomMenuController.update();
    //   }

    //   if (data.isEmpty) {
    //     _bottomMenuController.args = null;
    //     _bottomMenuController.close();
    //   }
    // } else {
    //   _bottomMenuController.args = [release.stringID];
    //   _bottomMenuController.open();
    // }
  }

  @override
  void didChangeDependencies() {
    _informationArgs = _parseArguments();
    _content = _informationArgs.content;
    super.didChangeDependencies();
  }

  bool _assertCheckArgs(args) {
    assert(args != null);
    assert(args is ContentInformationArgs);
    return true;
  }

  ContentInformationArgs _parseArguments() {
    final args = ModalRoute.settingsOf(context)?.arguments;
    assert(_assertCheckArgs(args));
    return args as ContentInformationArgs;
    // if (args is String) {
    //   return ContentInformationArgs.fromJson(args);
    // } else {
    //   return args as ContentInformationArgs;
    // }
  }

  bool get noContent =>
      (_content.sinopse ?? "").isEmpty &&
      _content.anilistMedia == null &&
      (_content.anilistMedia?.genres == null || _content.genres.isEmpty) &&
      _content.anilistMedia?.characters == null &&
      _content.anilistMedia?.staff == null;

  Future<void> _onRefresh() async {
    if (!mounted) return;
    setStateIfMounted(() {
      _index = 0;
      _isLoading = true;
    });

    await _repository
        .getData(_informationArgs.content)
        .timeout(const Duration(seconds: 30), onTimeout: _handleTimeout)
        .then(_handleResult);
  }

  void _shareButton() async {
    final args = _bottomMenuController.args;
    final releases = _content.releases.where(
      (release) => args.contains(release.stringID),
    );
    final release = releases.single;
    final uri = Uri.parse(release.url);
    _bottomMenuController.args.clear();
    _bottomMenuController.close();
    final result = await SharePlus.instance.share(ShareParams(uri: uri));

    if (result.status == ShareResultStatus.success) {
      customLog('Thank you for sharing my website!');
    }
  }

  void _saveSelectEpisodeEntity() async {
    if (_content case Anime data) {
      final animeEntity = _libraryController.repo.getContentEntityByStringID(
        data.stringID,
        orElse: () => data.toEntity(createdAt: DateTime.now()),
      );
      if (animeEntity == null) return;
      final args = _bottomMenuController.args;

      final toEntities = data.releases.where((test) => args.contains(test.stringID)).map((
        map,
      ) {
        final entity = _historicController.repo.getHistoric<EpisodeEntity>(
          release: map,
          orElse: () => map.toEntity(anime: data, createdAt: DateTime.now()),
        );

        return entity?.copyWith(isComplete: true, updatedAt: DateTime.now());
      }).toList();

      animeEntity.episodes.addAll(toEntities.nonNulls);

      await _libraryController.add(contentEntity: animeEntity);
      await _historicController.addAll(historyEntities: toEntities.nonNulls.toList());
      _bottomMenuController.args.clear();
      _bottomMenuController.close();
    }
  }

  void _deleteSelectEpisodeEntity() async {
    final args = _bottomMenuController.args;
    if (_content case Anime _) {
      final historicEntities = _historicController.repo.getAllHistoricEntityByID(args);
      await _historicController.removeAll(historyEntities: historicEntities);
      _bottomMenuController.args.clear();
      _bottomMenuController.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    customLog('$widget[build]');

    return ContentScope(
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
      child: Scaffold(
        body: DefaultTabController(
          length: 2,
          child: BottomMenu(
            isDismissible: false,
            bottomMenuController: _bottomMenuController,
            buttons: (context) {
              final args = _bottomMenuController.args;
              final releases = _content.releases.where(
                (release) => args.contains(release.stringID),
              );

              final historicEntities = _historicController.repo.getAllHistoricEntityByID(
                args,
              );

              return Align(
                alignment: Alignment.centerLeft,
                child: OverflowBar(
                  spacing: 8,
                  overflowAlignment: OverflowBarAlignment.center,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: releases.length > 1 ? null : _shareButton,
                      icon: Icon(MdiIcons.share),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: historicEntities.isNotEmpty
                          ? null
                          : _saveSelectEpisodeEntity,
                      icon: Icon(MdiIcons.eyeCheck),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: historicEntities.isEmpty
                          ? null
                          : _deleteSelectEpisodeEntity,
                      icon: Icon(MdiIcons.eyeMinus),
                    ),
                  ],
                ),
              );
            },
            child: RefreshIndicator.adaptive(
              notificationPredicate: (notification) {
                if (notification is OverscrollNotification) {
                  return notification.depth == 2;
                }
                return notification.depth == 0;
              },
              onRefresh: _onRefresh,
              key: _refreshIndicatorKey,
              child: const ContentPage(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void deactivate() {
    if (_libraryController.repo.containsFav(content: _content)) {
      ContentUtils.saveOrUpdate(context, _content);
    }

    super.deactivate();
  }
}
