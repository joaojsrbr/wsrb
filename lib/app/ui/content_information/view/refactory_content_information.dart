// ignore_for_file: public_member_api_docs, sort_constructors_first, constant_identifier_names
import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/content_page.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/global_overlay.dart';
import 'package:app_wsrb_jsr/app/utils/content_utils.dart';
import 'package:app_wsrb_jsr/app/utils/download_release_helper.dart';
import 'package:app_wsrb_jsr/app/utils/history_utils.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
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
  late final LibraryController _libraryController;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final Map<int, Releases> _releases = {};

  bool _isLoading = true;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) super.setState(fn);
    });
  }

  void _onSuccess(
    Content data, [
    bool refresh = false,
    bool forceSaveCache = false,
  ]) async {
    setState(() {
      _releases[_index] = data.releases;
      _content = data.copyWith(releases: _releases[_index], cached: true);
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
    final ValueNotifierList valueNotifierList = context.read<ValueNotifierList>();

    if (valueNotifierList.isEmpty) {
      valueNotifierList.toggle(release.stringID);
      context.showBottomNotification(
        _ContentInfoBottomButtons(context, _content, release),
        height: 52,
        showCountdown: true,
        duration: Duration(seconds: 20),
      );
    } else {
      valueNotifierList.toggle(release.stringID);
      context.maintainOverlap(duration: Duration(seconds: 20));
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
    final args = _parseArguments();
    if (args != null) {
      _informationArgs = args;
      _content = _informationArgs.content;
    }

    super.didChangeDependencies();
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
    setStateIfMounted(() {
      _index = 0;
      _isLoading = true;
    });

    await _repository
        .getData(_informationArgs.content)
        .timeout(const Duration(seconds: 30), onTimeout: _handleTimeout)
        .then(_handleResult);
  }

  @override
  Widget build(BuildContext context) {
    customLog('$widget[build]');
    _content.anilistMedia;
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: _content.anilistMedia?.coverImage?.color != null
            ? ColorScheme.fromSeed(
                seedColor: _content.anilistMedia!.coverImage!.color!.toColor(),
                brightness: Theme.of(context).brightness,
              )
            : null,
      ),
      child: ContentScope(
        onLongPressed: _handleLongPressed,
        setListIndex: _handleSetListIndex,
        downloadRelease: _downloadRelease,
        index: _index,
        noContent: noContent,
        informationArgs: _informationArgs,
        isLoading: _isLoading,
        releases: _releases,
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
              notificationPredicate: (notification) {
                return notification.depth == 0 || notification.depth == 2;
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
    setState(() {});
  }

  @override
  void deactivate() {
    _valueNotifierList
      ..removeListener(_listener)
      ..clear();
    super.deactivate();
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
