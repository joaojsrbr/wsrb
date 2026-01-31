// ignore_for_file: public_member_api_docs, sort_constructors_first, constant_identifier_names
import 'dart:async';

import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../utils/download_release_helper.dart';
import '../../../utils/history_utils.dart';
import '../../shared/widgets/global_overlay.dart';
import '../arguments/content_information_args.dart';
import '../widgets/content_page.dart';
import '../widgets/scope.dart';

class RefContentInformationView extends StatefulWidget {
  const RefContentInformationView({super.key});

  @override
  State<RefContentInformationView> createState() => _RefContentkInformationViewState();
}

class _RefContentkInformationViewState extends State<RefContentInformationView> {
  late Completer<dynamic> _initialRefresh;
  late ContentInformationArgs _informationArgs;
  final Map<int, Releases> _releases = {};
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late final ContentRepository _repository;
  late final LibraryController _libraryController;

  Debouncer? _updateReleasesByEntity;
  ColorScheme? _colorScheme;
  Key _forceUpdate = UniqueKey();
  Content _content = Anime.empty();
  bool _isLoading = true;
  bool _firstLoading = true;
  bool _releasesIsLoading = false;
  int _index = 0;

  @override
  void initState() {
    super.initState();

    _libraryController = read<LibraryController>();
    _repository = read<ContentRepository>();
    scheduleMicrotask(_onInit);
  }

  void _onInit() async {
    if (!mounted) return;
    _initialRefresh = Completer();
    await _loadContentData();
    // await Future.delayed(const Duration(milliseconds: 850), _loadContentData);
  }

  void _setReleases(Content data) {
    if (data.releases.length > 25) {
      data.releases.partition(25).forEachIndexed((index, releases) {
        _releases[index] = releases;
      });
    } else {
      _releases[_index] = data.releases;
    }
  }

  Future<void> _loadContentData() async {
    final entity = _libraryController.repo.getContentEntityByStringID(
      _informationArgs.content.stringID,
    );

    if (_informationArgs.isLibrary || entity != null) {
      final data = (!_informationArgs.isLibrary
          ? entity?.toContent() ?? _informationArgs.content
          : _informationArgs.content);

      // data.releases.clear();
      // data.releases.removeLast();

      setState(() {
        _setReleases(data);
        // _content = data
        //   ..releases.clear()
        //   ..releases.addAll(_releases[_index] ?? []);
        _content = data.copyWith(releases: _releases[_index]);
        _colorScheme = _getColorScheme();
        _isLoading = data.releases.length == 1;
        _releasesIsLoading = false;
      });
      if (_content.isMovie) return;
      _updateReleasesByEntity = Debouncer(
        duration: !_informationArgs.isLibrary
            ? Duration.zero
            : const Duration(seconds: 5),
      );
      _updateReleasesByEntity?.call(() async {
        if (!mounted) return;
        // await _getReleases(_content);
        final result = await _repository.getReleases(data, -1);
        if (!mounted) return;
        _forceUpdate = UniqueKey();
        result.fold(onSuccess: _onSuccess);
      });
      return;
    }

    // if (entity != null) {
    //   final toContent = entity.toContent();
    //   toContent.releases.removeLast();
    //   _handleResult(Success(toContent));
    //   Future.delayed(const Duration(seconds: 2), () async {
    //     if (!mounted) return;
    //     // await _getReleases(_content);
    //     final result = await _repository.getReleases(toContent, -1);
    //     result.fold(onSuccess: _onSuccess);
    //   });
    //   return;
    // }
    _refreshIndicatorKey.currentState?.show();
  }

  ColorScheme? _getColorScheme() {
    return _content.anilistMedia?.coverImage?.color != null
        ? ColorScheme.fromSeed(
            seedColor: _content.anilistMedia!.coverImage!.color!.toColor(),
            brightness: Theme.of(context).brightness,
          )
        : null;
  }

  void _handleResult(Result<Content> result) {
    final go = GoRouter.of(context);
    result.fold(onError: go.pop, onSuccess: _onSuccess);
  }

  Result<Content> _handleTimeout() {
    if (_informationArgs.content.releases.length > 1) {
      return Result.success(_informationArgs.content);
    }
    return Result.failure(TimeoutException("Tempo excedido"));
  }

  void _handleSetListIndex(int index) async {
    if (index == _index) return;

    setState(() {
      _index = index;
    });

    await _getReleases(_content);
  }

  // final int _setStateIndex = 1;
  @override
  void setState(VoidCallback fn) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {});
    // setStateIfMounted(fn);
    if (mounted) super.setState(fn);
    // customLog(_setStateIndex++);
  }

  void _onSuccess(
    Content data, [
    bool refresh = false,
    bool forceSaveCache = false,
  ]) async {
    if (data.releases.length > 25) {
      data.releases.partition(25).forEachIndexed((index, releases) {
        _releases[index] = releases;
      });
    } else {
      _releases[_index] = data.releases;
    }

    setState(() {
      _content = data.copyWith(releases: _releases[_index]);
      _releasesIsLoading = false;
      _isLoading = false;
      if (_firstLoading) _firstLoading = false;
      _colorScheme = _getColorScheme();
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
    final ValueNotifierList valueNotifierList = context.read<ValueNotifierList>();

    if (valueNotifierList.isEmpty) {
      valueNotifierList.toggle(release.stringID);
      context.showBottomNotification(
        _ContentInfoBottomButtons(context, _content, release),
        height: 52,
        persistent: true,
        showCountdown: false,
        // showCountdown: true,
        // duration: const Duration(seconds: 20),
      );
    } else {
      valueNotifierList.toggle(release.stringID);
      context.maintainOverlap(duration: const Duration(seconds: 20));
      if (valueNotifierList.isEmpty) {
        context.closeNotification();
      }
    }

    // if (data.isNotEmpty) {
    //   if (data.contains(release.stringID)) {
    //     data.remove(release.stringID);
    //     _bottomMenuController.update();
    //   } else {
    //     data.add(release.stringID);
    //     _bottomMenuController.update();
    //   }

    //   if (data.isEmpty) {
    //     data.clear();
    //     _bottomMenuController.close();
    //   }
    // } else {
    //   _bottomMenuController.args.add(release.stringID);
    //   _bottomMenuController.open();
    // }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = _parseArguments();
    if (args != null) {
      _informationArgs = args;
      _content = _informationArgs.content;
    }
  }

  // bool _assertCheckArgs(args) {
  //   assert(args != null);
  //   assert(args is ContentInformationArgs);
  //   return true;
  // }

  ContentInformationArgs? _parseArguments() {
    final args = ModalRoute.settingsOf(context)?.arguments;

    return args as ContentInformationArgs?;
    // if (args is String) {
    //   return ContentInformationArgs.fromJson(args);
    // } else {
    //   return args as ContentInformationArgs;
    // }
  }

  bool get noContent =>
      _content.sinopse.isEmpty &&
      _content.anilistMedia == null &&
      (_content.anilistMedia?.genres == null || _content.genres.isEmpty) &&
      _content.anilistMedia?.characters == null &&
      _content.anilistMedia?.staff == null;

  Future<void> _onRefresh() async {
    if (!mounted) return;
    _updateReleasesByEntity?.cancel();
    setStateIfMounted(() {
      _index = 0;
      if (!_informationArgs.isLibrary) _isLoading = true;
    });

    await _repository
        .getData(_informationArgs.content)
        .timeout(const Duration(seconds: 30), onTimeout: _handleTimeout)
        .then(_handleResult);

    // await Future.delayed(const Duration(milliseconds: 600));
    // _handleResult(Success(_informationArgs.content));
  }

  Future<bool> _handleWillPop() async {
    if (!mounted) return true;
    final navigator = Navigator.of(context);
    if (!_isLoading && !_informationArgs.isHistoric) {
      // _content.releases.clear();
      for (var value in _releases.values.flattened) {
        _content.releases.addIfNoContains(value);
      }
      navigator.pop(_content);
      return false;
    } else {
      navigator.pop();
      return false;
    }
  }

  @override
  void dispose() {
    _updateReleasesByEntity?.cancel();
    super.dispose();
  }

  bool _notificationPredicate(ScrollNotification notification) {
    return notification.depth == 0 || notification.depth == 2;
  }

  @override
  Widget build(BuildContext context) {
    customLog('$widget[build]');

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Theme(
        data: Theme.of(context).copyWith(colorScheme: _colorScheme),
        child: PopScope(
          child: ContentScope(
            firstLoading: _firstLoading,
            onLongPressed: _handleLongPressed,
            handleWillPop: _handleWillPop,
            setListIndex: _handleSetListIndex,
            downloadRelease: _downloadRelease,
            index: _index,
            forceUpdate: _forceUpdate,
            noContent: noContent,
            informationArgs: _informationArgs,
            isLoading: _isLoading,
            content: _content,
            releasesIsLoading: _releasesIsLoading,
            child: Scaffold(
              // extendBodyBehindAppBar: true,
              // extendBody: true,
              // primary: false,
              extendBodyBehindAppBar: true,
              body: DefaultTabController(
                length: 2,
                child: RefreshIndicator.adaptive(
                  notificationPredicate: _notificationPredicate,
                  onRefresh: _onRefresh,
                  key: _refreshIndicatorKey,
                  child: const ContentPage(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContentInfoBottomButtons extends StatefulWidget {
  const _ContentInfoBottomButtons(this.context, this.content, this.release);
  final Content content;
  final Release release;
  final BuildContext context;

  @override
  State<_ContentInfoBottomButtons> createState() => _ContentInfoBottomButtonsState();
}

class _ContentInfoBottomButtonsState extends State<_ContentInfoBottomButtons> {
  late final ValueNotifierList _valueNotifierList;

  @override
  void initState() {
    _valueNotifierList = context.read<ValueNotifierList>()..addListener(_listener);
    super.initState();
  }

  void _listener() {
    setStateIfMounted(() {});
  }

  @override
  void dispose() {
    _valueNotifierList.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ids = widget.content.releases
        .map((release) => release.stringID)
        .where(_valueNotifierList.contains);

    final historicController = context.watch<HistoricController>();

    final isComplete = historicController.repo
        .getAllByIDs(_valueNotifierList)
        .any((entity) => entity.isComplete);

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: OverflowBar(
        spacing: 8,
        alignment: MainAxisAlignment.start,
        overflowAlignment: OverflowBarAlignment.center,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: ids.length > 1 ? null : () => _shareButton(widget.context),
            icon: Icon(MdiIcons.share),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: isComplete ? null : () => _saveSelectEpisodeEntity(widget.context),
            icon: Icon(MdiIcons.eyeCheck),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: !isComplete
                ? null
                : () => _deleteSelectEpisodeEntity(widget.context),
            icon: Icon(MdiIcons.eyeMinus),
          ),
        ],
      ),
    );
  }

  void _shareButton(BuildContext context) async {
    final ValueNotifierList valueNotifierList = context.read<ValueNotifierList>();

    final releases = widget.content.releases.where(
      (release) => valueNotifierList.contains(release.stringID),
    );

    final release = releases.single;
    final uri = Uri.parse(release.url);
    valueNotifierList.clear();
    context.closeNotification();
    final result = await SharePlus.instance.share(ShareParams(uri: uri));

    if (result.status == ShareResultStatus.success) {
      customLog('Thank you for sharing my website!');
    }
  }

  void _saveSelectEpisodeEntity(BuildContext context) async {
    final ValueNotifierList valueNotifierList = context.read<ValueNotifierList>();

    final historicController = context.read<HistoricController>();

    final libraryController = context.read<LibraryController>();
    if (widget.content case Anime data) {
      final animeEntity = libraryController.repo.getContentEntityByStringID(
        data.stringID,
        orElse: () => data.toEntity(createdAt: DateTime.now()),
      );
      if (animeEntity == null) return;
      final args = valueNotifierList;

      final toEntities = data.releases.where((test) => args.contains(test.stringID)).map((
        map,
      ) {
        final entity = historicController.repo.getHistoric<EpisodeEntity>(
          release: map,
          orElse: () => map.toEntity(anime: data, createdAt: DateTime.now()),
        );

        return entity?.copyWith(isComplete: true, updatedAt: DateTime.now());
      }).toList();

      animeEntity.episodes.addAll(toEntities.nonNulls);

      await libraryController.add(contentEntity: animeEntity);
      await historicController.addAll(historyEntities: toEntities.nonNulls.toList());
      if (context.mounted) {
        valueNotifierList.clear();
        context.closeNotification();
      }
    }
  }

  void _deleteSelectEpisodeEntity(BuildContext context) async {
    final ValueNotifierList valueNotifierList = context.read<ValueNotifierList>();

    final historicController = context.read<HistoricController>();

    final args = valueNotifierList;
    if (widget.content case Anime _) {
      final historicEntities = historicController.repo.getAllByIDs(args);
      // await _historicController.removeAll(historyEntities: historicEntities);
      HistoryUtils.questionDelete(
        context,
        historicEntities,
        onConfirmDelete: () {
          historicController.addAll(
            historyEntities: historicEntities
                .map(
                  (entity) => entity.copyWith(
                    position: null,
                    updatedAt: DateTime.now(),
                    isComplete: false,
                  ),
                )
                .toList(),
          );
        },
        onUndoDelete: (oldHistoric) {
          historicController.addAll(historyEntities: oldHistoric);
        },
      );
      if (context.mounted) {
        valueNotifierList.clear();
        context.closeNotification();
      }
    }
  }
}
