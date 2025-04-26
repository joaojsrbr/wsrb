// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:collection';

import 'package:android_pip/actions/pip_actions_layout.dart';
import 'package:android_pip/android_pip.dart';
import 'package:android_pip/pip_widget.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_audio_handler.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_audio_session.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_controller.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_pip.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_screenshot.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_status.dart';
import 'package:app_wsrb_jsr/app/ui/player/widgets/material_video_controls.dart';
import 'package:app_wsrb_jsr/app/ui/player/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_popup.dart';
import 'package:app_wsrb_jsr/app/utils/custom_states.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:provider/provider.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  static final GlobalKey<VideoState> videoStateKey = GlobalKey<VideoState>();

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends StateByArgument<PlayerView, PlayerArgs>
    with
        WidgetsBindingObserver,
        SubscriptionsByStateArgumentMixin<PlayerView, PlayerArgs>,
        PlayerControllerMixin,
        PlayerPipMixin,
        PlayerAudioHandlerMixin,
        PlayerAudioSessionMixin,
        PlayerScreenshotMixin,
        SingleTickerProviderStateMixin,
        PlayerStatusMixin {
  final ValueNotifier<String?> _overlayBoxFit = ValueNotifier(null);
  final ValueNotifier<bool> _showAnimeSkip = ValueNotifier(false);
  final ValueNotifier<String?> _overlayNextEpisode = ValueNotifier(null);
  final ValueNotifier<String> _topTitle = ValueNotifier('');
  final ValueNotifier<bool> _lockPlayer = ValueNotifier(false);
  final ValueNotifier<bool> _openMenuInFullScreen = ValueNotifier(false);
  final ValueNotifier<bool> _reversedCurrentDuration = ValueNotifier(false);
  final ValueNotifier<Duration?> _seekInVideoPosition = ValueNotifier(null);
  final ValueNotifier<AnimeTimeStamp?> _selectedAnimeTimeStamp =
      ValueNotifier(null);

  Data? _mainVideoData;
  VideoController? _videoController;
  bool _isLoading = true;
  BoxFit _activeFit = BoxFit.contain;
  int _currentValueCircularAnimation = 0;

  final List<Data> data = [];
  final Debouncer _nextEpisodeDebouncer =
      Debouncer(duration: Duration(milliseconds: 200));
  final Queue<BoxFit> _queueBoxFits = Queue<BoxFit>();
  final int _maxValueCircularAnimation = 2;

  late PlayerArgs _playerArgs = argument();
  late final AnimationController _animationController;
  late final ContentRepository _repository;
  late final HiveController _hiveController;
  late final LibraryController _libraryController;
  late final AnimeSkipController _animeSkipController;
  late final HistoricController _historicController;
  late final Timer _systemUIModeTimer;

  Timer? _setContinueVideoTimer;

  bool get _hasNextEpisode {
    if (!_playerArgs.getAnimeData || _playerArgs.anime.releases.isEmpty) {
      return false;
    }

    return _playerArgs.anime.releases.last.stringID !=
        _playerArgs.episode.stringID;
  }

  bool get _playing => player?.state.playing ?? false;

  bool get isFullscreen =>
      PlayerView.videoStateKey.currentState?.isFullscreen() ?? false;

  double get _videoPercent {
    if (player != null) {
      final Duration position = player!.state.position;
      final Duration duration = player!.state.duration;

      if (duration.inMicroseconds > 0) {
        return (position.inMicroseconds / duration.inMicroseconds)
            .clamp(0.0, 1.0);
      }
    }
    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _hiveController = context.read<HiveController>();
    _animeSkipController = context.read<AnimeSkipController>();
    _repository = context.read<ContentRepository>();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    BoxFit.values
        .where((fit) => !(fit == BoxFit.none || fit == _activeFit))
        .forEach(_queueBoxFits.add);
    _historicController = context.read<HistoricController>();
    _libraryController = context.read<LibraryController>();

    _systemUIModeTimer = Timer.periodic(
      const Duration(seconds: 1),
      _setEnabledSystemUIMode,
    );

    addPostFrameCallback(_onInit);
  }

  void _setEnabledSystemUIMode(Timer timer) {
    if (player == null && !mounted) return;

    if (_playing && !player!.state.completed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Future<void> _incrementCurrentCircularAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    setStateIfMounted(() => _currentValueCircularAnimation += 1);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    customLog('[$runtimeType][didChangeAppLifecycleState()][$state]');

    switch (state) {
      case AppLifecycleState.hidden:
        _saveVideoPosition();
      case AppLifecycleState.paused:
        _saveVideoPosition();
      case AppLifecycleState.inactive:
      case AppLifecycleState.resumed:
        _resumed();
      case AppLifecycleState.detached:
    }

    super.didChangeAppLifecycleState(state);
  }

  void _resumed() async {
    isPipActivated = await AndroidPIP.isPipActivated;
    setStateIfMounted(() {});
  }

  Future<void> _getInitMainVideoData() async {
    _topTitle.value = 'Episódio ${_playerArgs.episode.number}';

    final state = Navigator.of(context);

    final file =
        AppStorage.getReleaseFile(_playerArgs.anime, _playerArgs.episode);

    final result = file != null
        ? Result.success([FileVideoData(file: file)])
        : await _repository.getContent(_playerArgs.episode);

    result.fold(
      onSuccess: (data) {
        if (![VideoData, FileVideoData].contains(data.first.runtimeType)) {
          state.pop();
          return;
        }

        setStateIfMounted(() {
          data.forEach(this.data.cast().addIfNoContains);
          _mainVideoData = data.first;
          _playerArgs = _playerArgs.copyWith(data: _mainVideoData);
        });
      },
      onError: state.pop,
    );
  }

  Future<void> _getAllEpisodes() async {
    if (_playerArgs.anime.releases.length <= 1 || _playerArgs.getAnimeData) {
      await _repository.getReleases(_playerArgs.anime, -1).then(
            (result) => result.fold(
              onSuccess: (data) {
                _playerArgs = _playerArgs.copyWith(
                  anime: data as Anime,
                );
              },
            ),
          );
    }
  }

  void _onInit(Duration time) async {
    await pipStart();

    await _getAllEpisodes().whenComplete(_incrementCurrentCircularAnimation);

    await _getInitMainVideoData()
        .whenComplete(_incrementCurrentCircularAnimation);

    await _startPlayerController(true, _playerArgs.startPossition)
        .whenComplete(_incrementCurrentCircularAnimation);

    _topTitle.value = 'Episódio ${_playerArgs.episode.number}';

    setStateIfMounted(() => _isLoading = false);

    if (player?.state.playing == true && _playerArgs.startPossition == null) {
      await _continueVideoByHistoricPosition();
    }
  }

  Future<void> _startPlayerController([
    bool onInit = false,
    Duration? initPossition,
  ]) async {
    await _registerListeners(true);
    final playbackState = playerAudioHandler.playbackState;
    playerAudioHandler.setPlayerController = this;

    if (onInit) {
      setPlayer = Player();
      _videoController = VideoController(
        player!,
        configuration: const VideoControllerConfiguration(),
      );
    }

    List<Future> futures = [
      player!.setAudioDevice(AudioDevice.auto()),
      _registerListeners(false),
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive)
    ];

    switch (_mainVideoData) {
      case VideoData data:
        futures.add(
          player!.open(
            Media(
              data.videoContent,
              start: initPossition,
              httpHeaders: data.httpHeaders,
            ),
          ),
        );
      case FileVideoData data:
        futures.add(
          player!.open(
            Media(
              data.file.path,
              start: initPossition,
            ),
          ),
        );
      default:
    }

    await Future.wait(futures);
    // _videoController!.player.platform.waitForPlayerInitialization;
    await player?.platform?.waitForPlayerInitialization.whenComplete(
      () {
        if (_playerArgs.forceEnterFullScreen) {
          Future.delayed(const Duration(milliseconds: 500),
              () => PlayerView.videoStateKey.currentState?.enterFullscreen());
        }
      },
    );

    playbackState.add(playbackState.value.copyWith
        .call(processingState: AudioProcessingState.ready));
  }

  void _completedListener(bool completed) {
    status.setValue(completed: completed);
    if (completed) {
      _saveVideoPosition();
      final playbackState = playerAudioHandler.playbackState;

      playbackState.add(playbackState.value.copyWith
          .call(processingState: AudioProcessingState.idle));
    }
  }

  Future<void> _registerListeners(bool clearListeners) async {
    if (clearListeners) {
      await subscriptions.cancelAll();
    } else {
      subscriptions.addAll([
        player!.stream.playing.listen(_playingListener),
        player!.stream.position.listen(_positionListener),
        player!.stream.duration.listen(_durationListener),
        player!.stream.buffer.listen(_bufferListener),
        player!.stream.completed.listen(_completedListener),
      ]);
    }
  }

  void _bufferListener(Duration buffer) {
    status.setValue(buffer: buffer);
  }

  void _playingListener(bool playing) async {
    setSessionActive(playing);
    status.setValue(playing: playing);
    await AndroidPIP().setIsPlaying(playing);
  }

  void _durationListener(Duration duration) {
    status.setValue(duration: duration);
    if (duration != Duration.zero) setPlayerMedia(_playerArgs);
  }

  void _positionListener(Duration position) {
    status.setValue(position: position);
    playerAudioHandler.setPlaybackState(player!.state);

    if (_seekInVideoPosition.value != null) {
      playerAudioHandler.seek(_seekInVideoPosition.value!);
      _seekInVideoPosition.value = null;
    }

    if (_hasNextEpisode) _nextEpisode(position);
    _animeSkipPosition(position);
  }

  void _animeSkipPosition(Duration position) {
    final times = _playerArgs.times.reversed.toList();

    final firstIndex = times.indexWhere(
      (time) => position > time.atDuration,
    );
    if (firstIndex != -1) {
      final first = times[firstIndex];
      // final last = times.elementAtOrNull(firstIndex + 1);
      if (_selectedAnimeTimeStamp.value != first) {
        _selectedAnimeTimeStamp.value = first;

        customLog(first.timeStampType);
      }
    }
  }

  Future<void> _handleSetFits() async {
    final videoState = PlayerView.videoStateKey.currentState;
    if (videoState == null) return;

    final nextBoxFit = _queueBoxFits.removeFirst();
    _queueBoxFits.addLast(_activeFit);

    _overlayBoxFit.value = nextBoxFit.name;

    customLog("[$runtimeType][_handleSetFits()][$nextBoxFit]");

    setStateIfMounted(() {
      _activeFit = nextBoxFit;
      videoState.update(fit: nextBoxFit);
    });
  }

  void _nextEpisode(Duration position) async {
    final maxPosition = player!.state.duration;
    final positionActiveOverlay = maxPosition - const Duration(seconds: 120);
    final diff = maxPosition - position;

    if (position >= positionActiveOverlay &&
        !diff.inSeconds.isNegative &&
        _hasNextEpisode &&
        maxPosition.inSeconds > 0) {
      final indexOf =
          _playerArgs.anime.releases.indexOf(_playerArgs.episode) + 1;
      final nextEpisode = _playerArgs.anime.releases[indexOf];

      _overlayNextEpisode.value =
          'Episódio ${nextEpisode.number} - ${diff.inSeconds}';
    } else if (_overlayNextEpisode.value != null) {
      _nextEpisodeDebouncer.call(() {
        _overlayNextEpisode.value = null;
      });
    }
  }

  Future<void> _continueVideoByHistoricPosition() async {
    final entity = _historicController.repo.getHistoric<EpisodeEntity>(
      release: _playerArgs.episode,
      content: _playerArgs.anime,
    );

    if (entity == null) return;

    customLog(
        '[$runtimeType][_continueVideoByHistoricPosition()][${entity.animeStringID}]');

    if (entity.currentDuration == 0) return;

    final GlobalKey dialogAnchor = GlobalKey();

    _setContinueVideoTimer = Timer(const Duration(seconds: 5), () {
      if (dialogAnchor.currentContext != null) {
        Navigator.of(dialogAnchor.currentContext!).pop();
      }
    });

    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          key: dialogAnchor,
          title: const Text('Continuar de onde parou?'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'NÃO',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('SIM'),
            ),
          ],
        );
      },
    );

    _setContinueVideoTimer?.cancel();

    if (result == true && mounted) {
      _setContinueVideoTimer = null;
      _seekInVideoPosition.value = entity.cdToDuration;
    }
  }

  Future<void> _handleOnTapEpisodeInOverlay() async {
    _overlayNextEpisode.value = null;

    final indexOf = _playerArgs.anime.releases.indexOf(_playerArgs.episode);

    final nexEpisode = _playerArgs.anime.releases[indexOf + 1];

    await _handleOnTapEpisode(nexEpisode);

    _overlayNextEpisode.value = null;
  }

  Future<void> _handleOnTapEpisode(Episode episode) async {
    if (episode.stringID.contains(_playerArgs.episode.stringID)) return;
    await setSessionActive(false);
    await _saveVideoPosition();

    _seekInVideoPosition.value = null;
    _playerArgs = _playerArgs.copyWith(
      data: null,
      episode: episode,
    );
    _overlayNextEpisode.value = null;

    customLog('[$runtimeType][_handleOnTapEpisode()][${episode.title}]');

    setStateIfMounted(() {});

    await _getInitMainVideoData();
    _openMenuInFullScreen.value = false;
    await _startPlayerController(false);
    await _continueVideoByHistoricPosition();
  }

  Future<void> _saveVideoPosition([
    Future<void> Function()? onSave,
    // bool stop = false,
  ]) async {
    player?.pause();
    if (_mainVideoData == null ||
        player?.state.duration.inMicroseconds == 0.0) {
      return;
    }

    // _saveDataDebouncer.cancel();
    final currentPositionBase64 = await videoScreenshotBase64();
    await setSessionActive(false);
    await playerAudioHandler.stop();

    if (_videoPercent < _hiveController.historicSavePercent) return;

    final Duration position = player!.state.position;

    final Duration duration = player!.state.duration;

    final EpisodeEntity? entity = _historicController.repo.getHistoric(
      release: _playerArgs.episode,
      content: _playerArgs.anime,
    );

    bool isComplete = _videoPercent >= 0.85;

    final EpisodeEntity episodeEntity = EpisodeEntity.save(
      anime: _playerArgs.anime,
      isComplete: isComplete,
      episode: _playerArgs.episode,
      currentPositionBase64: currentPositionBase64,
      position: position,
      duration: duration,
      entity: entity,
    );

    // if (stop)
    await player?.stop();

    if (onSave != null) {
      await onSave();
      playerAudioHandler.setPlayerController = null;
    }

    customLog(
        '[$runtimeType][_saveVideoPosition()][${episodeEntity.numberEpisode}]');

    final AnimeEntity animeEntity =
        _libraryController.repo.getContentEntityByStringID(
      _playerArgs.anime.stringID,
      orElse: () => _playerArgs.anime.toEntity(createdAt: DateTime.now()),
    );

    animeEntity.animeSkip.value ??= _playerArgs.anime.animeSkip?.toEntity;

    animeEntity.addEpisode(episodeEntity);

    if (animeEntity.animeSkip.value != null) {
      await _animeSkipController.save(animeEntity.animeSkip.value!);
    }
    await _libraryController.add(contentEntity: animeEntity);
    await _historicController.add(historyEntity: episodeEntity);
  }

  void _handleClickSkipAnime(AnimeTimeStamp item) {
    player?.seek(item.duration);
  }

  @override
  Widget buildByArgument(BuildContext context, PlayerArgs argument) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: (mounted ? _playerArgs : argument).times.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () {
                _showAnimeSkip.value = !_showAnimeSkip.value;
              },
              child: Icon(MdiIcons.timelapse),
            ),
      body: PlayerScope(
        animationController: _animationController,
        onClickSkipAnime: _handleClickSkipAnime,
        selectedAnimeTimeStamp: _selectedAnimeTimeStamp,
        showAnimeSkip: _showAnimeSkip,
        openMenuInFullScreen: _openMenuInFullScreen,
        // draggableScrollableController: draggableScrollableController,
        onPipAction: onPipAction,
        onPipChange: onPipChange,
        isPipActivated: isPipActivated,
        isPipAvailable: isPipAvailable,
        enterInPip: handleEnterInPip,
        lockPlayer: _lockPlayer,
        reversedCurrentDuration: _reversedCurrentDuration,
        topTitle: _topTitle,
        overlayBoxFit: _overlayBoxFit,
        overlayNextEpisode: _overlayNextEpisode,
        onTapEpisodeInOverlay: _handleOnTapEpisodeInOverlay,
        onTapEpisode: _handleOnTapEpisode,
        activeFit: _activeFit,
        videoController: _videoController,
        currentValueCircularAnimation: _currentValueCircularAnimation,
        maxValueCircularAnimation: _maxValueCircularAnimation,
        isLoading: _isLoading,
        playerArgs: mounted ? _playerArgs : argument,
        setFits: _handleSetFits,
        child: const _Content(),
      ),
    );
  }

  @override
  void dispose() {
    customLog('[$runtimeType][dispose]');
    _topTitle.dispose();
    _seekInVideoPosition.dispose();
    _openMenuInFullScreen.dispose();
    _lockPlayer.dispose();
    _reversedCurrentDuration.dispose();
    _overlayBoxFit.dispose();
    _systemUIModeTimer.cancel();
    _setContinueVideoTimer?.cancel();
    _selectedAnimeTimeStamp.dispose();
    _animationController.dispose();
    _nextEpisodeDebouncer.cancel();
    _showAnimeSkip.dispose();
    _overlayNextEpisode.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _saveVideoPosition(player?.dispose);
    super.dispose();
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    final scope = PlayerScope.of(context);
    final isLoading = scope.isLoading;
    final videoCtrl = scope.videoController;
    final fit = scope.activeFit;
    final isPipActivated = scope.isPipActivated;
    final args = scope.playerArgs;

    return MaterialVideoControlsTheme(
      normal: const MaterialVideoControlsThemeData(),
      fullscreen: const MaterialVideoControlsThemeData(
        controlsTransitionDuration: Duration(milliseconds: 650),
      ),
      child: Column(
        mainAxisAlignment:
            isLoading ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (isLoading) ...[
            _LoadingIndicator(
              progress: scope.currentValueCircularAnimation /
                  scope.maxValueCircularAnimation,
            ),
            Text('Carregando...',
                style: Theme.of(context).textTheme.titleSmall),
          ] else if (videoCtrl != null) ...[
            Flexible(
              child: _VideoPlayerArea(
                fit: fit,
                controller: videoCtrl,
              ),
            ),
            if (args.getAnimeData &&
                !args.forceEnterFullScreen &&
                !isPipActivated)
              Expanded(flex: 2, child: _EpisodesAndSkipList()),
          ],
        ],
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  final double progress;
  const _LoadingIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 150),
        tween: Tween(begin: 0, end: progress),
        builder: (_, value, __) =>
            CircularProgressIndicator.adaptive(value: value),
      ),
    );
  }
}

class _VideoPlayerArea extends StatelessWidget {
  final BoxFit fit;
  final VideoController controller;
  const _VideoPlayerArea({required this.fit, required this.controller});

  @override
  Widget build(BuildContext context) {
    final scope = PlayerScope.of(context);
    final size = MediaQuery.sizeOf(context);
    return SizedBox(
      height: scope.isPipActivated ? size.height : size.height * 0.4,
      width: double.infinity,
      child: PipWidget(
        onPipAction: scope.onPipAction,
        onPipEntered: scope.onPipChange,
        onPipExited: scope.onPipChange,
        pipLayout: PipActionsLayout.media_only_pause,
        pipChild: Video(
          aspectRatio: 16 / 9,
          fit: fit,
          controls: (_) => const SizedBox.shrink(),
          controller: controller,
        ),
        child: Video(
          key: PlayerView.videoStateKey,
          filterQuality: FilterQuality.medium,
          aspectRatio: 16 / 9,
          fit: fit,
          controller: controller,
          onEnterFullscreen: scope.isPipActivated
              ? () async {}
              : () async {
                  await SystemChrome.setPreferredOrientations([
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.landscapeRight,
                  ]);
                  SystemChrome.setEnabledSystemUIMode(
                    SystemUiMode.immersive,
                  );
                },
          onExitFullscreen: scope.isPipActivated
              ? () async {}
              : () async {
                  await SystemChrome.setPreferredOrientations(
                    [DeviceOrientation.portraitUp],
                  );
                },
          controls: (state) {
            if (!scope.isPipActivated) return CustomMaterialControls(state);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _EpisodesAndSkipList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scope = PlayerScope.of(context);
    final args = scope.playerArgs;
    final hive = context.watch<HiveController>();
    final size = MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: scope.showAnimeSkip,
      builder: (context, child) => Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: _EpisodeList(hive: hive)),
          if (args.times.isNotEmpty)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: scope.showAnimeSkip.value ? size.width / 2 : 0,
              ),
              child: CustomPopup(
                // startAnimatedAlignment: Alignment.,
                duration: const Duration(milliseconds: 250),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                height: size.height,
                width: size.width / 2,
                show: scope.showAnimeSkip.value,
                items: args.times,
                builderFunction: (ctx, idx, stamp) {
                  return ValueListenableBuilder<AnimeTimeStamp?>(
                    valueListenable: scope.selectedAnimeTimeStamp,
                    builder: (_, selected, __) {
                      return ListTile(
                        selected: selected?.id == stamp.id,
                        leading: Text(Duration(microseconds: stamp.at).label()),
                        title: Text(stamp.timeStampType.label),
                        visualDensity:
                            const VisualDensity(vertical: -4, horizontal: -2),
                        onTap: () => scope.onClickSkipAnime(stamp),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _EpisodeList extends StatelessWidget {
  final HiveController hive;
  const _EpisodeList({required this.hive});

  @override
  Widget build(BuildContext context) {
    final scope = PlayerScope.of(context);
    final args = scope.playerArgs;
    final releases = args.anime.releases.reversed.toList();

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 18),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: releases.length,
      itemBuilder: (context, i) {
        final ep = releases[i];
        final selected = ep.stringID == args.episode.stringID;
        return AnimatedSize(
          // alignment: Alignment.centerLeft,
          duration: const Duration(milliseconds: 200),
          child: ListTile(
            minLeadingWidth: scope.showAnimeSkip.value ? 0 : 100,
            selected: selected,
            leading: scope.showAnimeSkip.value
                ? const SizedBox.shrink()
                : SizedBox(
                    width: 100,
                    height: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        cacheManager: App.APP_IMAGE_CACHE,
                        httpHeaders: {
                          'Referer': '${hive.source.baseURL}/',
                          ...App.HEADERS
                        },
                        imageUrl: ep.thumbnail!,
                        placeholder: (_, __) => const Card.filled(),
                        fit: BoxFit.cover,
                        memCacheWidth: 200,
                        memCacheHeight: 150,
                      ),
                    ),
                  ),
            title: Text(
              '${ep.number}. ${ep.title}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            titleTextStyle: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
            visualDensity: VisualDensity(
                vertical: scope.showAnimeSkip.value ? -4 : 2, horizontal: -2),
            onTap: () => scope.onTapEpisode(ep),
            onLongPress: ep.sinopse?.isNotEmpty == true
                ? () => _showSynopsis(context, ep.sinopse!)
                : null,
          ),
        );
      },
    );
  }

  void _showSynopsis(BuildContext context, String sinopse) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      isDismissible: true,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sinopse',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(sinopse.trim(),
                textAlign: TextAlign.justify,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
