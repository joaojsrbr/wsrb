// ignore_for_file: public_member_api_docs, sort_constructors_first, constant_identifier_names
import 'dart:async';

import '../arguments/content_information_args.dart';
import '../widgets/content_page.dart';
import '../widgets/scope.dart';
import '../../shared/widgets/global_overlay.dart';
import '../../../utils/content_utils.dart';
import '../../../utils/download_release_helper.dart';
import '../../../utils/history_utils.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class RefContentInformationView extends StatefulWidget {
  const RefContentInformationView({super.key});

  @override
  State<RefContentInformationView> createState() => _RefContentkInformationViewState();
}

class _RefContentkInformationViewState extends State<RefContentInformationView>
    with RestorationMixin {
  late Completer _initialRefresh;
  ColorScheme? _colorScheme;

  late final ContentRepository _repository;
  late final LibraryController _libraryController;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final Map<int, Releases> _releases = {};

  final RestorableContentInformationArgs _informationArgs =
      RestorableContentInformationArgs();
  final RestorableContent _content = RestorableContent(Anime.empty());
  final RestorableBool _isLoading = RestorableBool(true);
  final RestorableBool _releasesIsLoading = RestorableBool(false);
  final RestorableInt _index = RestorableInt(0);

  @override
  void dispose() {
    _content.dispose();
    _isLoading.dispose();
    _releasesIsLoading.dispose();
    _index.dispose();
    _informationArgs.dispose();
    super.dispose();
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_content, "content");
    registerForRestoration(_isLoading, "isLoading");
    registerForRestoration(_releasesIsLoading, "releasesIsLoading");
    registerForRestoration(_index, "index");
    registerForRestoration(_informationArgs, "informationArgs");
  }

  @override
  String? get restorationId => 'ref_content_information_view';

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

  Future<void> _loadContentData() async {
    if (_informationArgs.value.isLibrary) {
      setState(() {
        _isLoading.value = false;
        _releasesIsLoading.value = false;
      });
      final data = _informationArgs.value.content;
      _releases[_index.value] = data.releases;
      return;
    }
    _refreshIndicatorKey.currentState?.show();
  }

  void _handleResult(Result<Content> result) {
    final go = GoRouter.of(context);
    result.fold(onError: go.pop, onSuccess: _onSuccess);
  }

  Result<Content> _handleTimeout() {
    if (_informationArgs.value.content.releases.length > 1) {
      return Result.success(_informationArgs.value.content);
    }
    return Result.failure(TimeoutException("Tempo excedido"));
  }

  void _handleSetListIndex(int index) async {
    if (index == _index.value) return;

    setState(() {
      _index.value = index;
    });

    await _getReleases(_content.value.copyWith(releases: Releases()));
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
      _releases[_index.value] = data.releases;
      _content.value = data.copyWith(releases: _releases[_index.value]);
      _releasesIsLoading.value = false;
      _isLoading.value = false;
      _colorScheme = _content.value.anilistMedia?.coverImage?.color != null
          ? ColorScheme.fromSeed(
              seedColor: _content.value.anilistMedia!.coverImage!.color!.toColor(),
              brightness: Theme.of(context).brightness,
            )
          : null;
    });

    if (_content.value.releases.length == data.releases.length && !refresh) {
      if (!_initialRefresh.isCompleted) _initialRefresh.complete();
      _isLoading.value = false;
      return;
    }

    if (!_initialRefresh.isCompleted) _initialRefresh.complete();
  }

  Future<void> _getReleases(Content content, [bool onRefresh = false]) async {
    final releases = _releases[_index.value];

    if (releases == null || onRefresh) {
      setState(() {
        _releasesIsLoading.value = true;
      });
      final result = await _repository.getReleases(content, _index.value + 1);

      result.fold(onSuccess: _onSuccess);
    } else {
      setState(() {
        _content.value = _content.value.copyWith(releases: _releases[_index.value]);
      });
    }
  }

  Future<void> _downloadRelease(Release release) async {
    if (mounted) {
      await DownloadReleaseHelper.download(context, release, _content.value);
    }
  }

  void _handleLongPressed(Release release) {
    final ValueNotifierList valueNotifierList = context.read<ValueNotifierList>();

    if (valueNotifierList.isEmpty) {
      valueNotifierList.toggle(release.stringID);
      context.showBottomNotification(
        _ContentInfoBottomButtons(context, _content.value, release),
        height: 52,
        showCountdown: true,
        duration: const Duration(seconds: 20),
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
    if (args != null && _informationArgs.enabled) {
      _informationArgs.value = args;
      _content.value = _informationArgs.value.content;
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
      _content.value.sinopse.isEmpty &&
      _content.value.anilistMedia == null &&
      (_content.value.anilistMedia?.genres == null || _content.value.genres.isEmpty) &&
      _content.value.anilistMedia?.characters == null &&
      _content.value.anilistMedia?.staff == null;

  Future<void> _onRefresh() async {
    if (!mounted) return;
    setStateIfMounted(() {
      _index.value = 0;
      if (!_informationArgs.value.isLibrary) _isLoading.value = true;
    });

    await _repository
        .getData(_informationArgs.value.content)
        .timeout(const Duration(seconds: 30), onTimeout: _handleTimeout)
        .then(_handleResult);
  }

  @override
  Widget build(BuildContext context) {
    customLog('$widget[build]');

    return Theme(
      data: Theme.of(context).copyWith(colorScheme: _colorScheme),
      child: ContentScope(
        onLongPressed: _handleLongPressed,
        setListIndex: _handleSetListIndex,
        downloadRelease: _downloadRelease,
        index: _index.value,
        noContent: noContent,
        informationArgs: _informationArgs.value,
        isLoading: _isLoading.value,
        releases: _releases,
        content: _content.value,
        releasesIsLoading: _releasesIsLoading.value,
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
  void deactivate() {
    if (_libraryController.repo.containsFav(content: _content.value)) {
      ContentUtils.saveOrUpdate(context, _content.value);
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
