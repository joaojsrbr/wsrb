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
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_lifecycles_states.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_pip.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_screenshot.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_status.dart';
import 'package:app_wsrb_jsr/app/ui/player/widgets/material_video_controls.dart';
import 'package:app_wsrb_jsr/app/ui/player/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_popup.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/release_content.dart';
import 'package:app_wsrb_jsr/app/utils/anchor.dart';
import 'package:app_wsrb_jsr/app/utils/auto_dispose_mixin.dart';
import 'package:app_wsrb_jsr/app/utils/custom_states.dart';
import 'package:app_wsrb_jsr/app/utils/release_utils.dart';
import 'package:audio_service/audio_service.dart';
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
        PlayerStatusMixin,
        AutoDisposeMixin,
        PlayerLifecyclesStates {
  final ValueNotifier<String?> _overlayBoxFit = ValueNotifier(null);
  final ValueNotifier<bool> _showAnimeSkip = ValueNotifier(false);
  final ValueNotifier<String?> _overlayNextEpisode = ValueNotifier(null);
  final ValueNotifier<String> _topTitle = ValueNotifier('');
  final ValueNotifier<bool> _lockPlayer = ValueNotifier(false);
  final ValueNotifier<bool> _openMenuInFullScreen = ValueNotifier(false);
  final ValueNotifier<bool> _reversedCurrentDuration = ValueNotifier(false);
  final ValueNotifier<Duration?> _seekInVideoPosition = ValueNotifier(null);
  final ValueNotifier<AnimeTimeStamp?> _selectedAnimeTimeStamp = ValueNotifier(
    null,
  );
  final ValueNotifier<bool> _showButtonQuality = ValueNotifier(false);

  @override
  List<Object> get autoDispose => [
    _overlayBoxFit,
    _showAnimeSkip,
    _overlayNextEpisode,
    _topTitle,
    _lockPlayer,
    _openMenuInFullScreen,
    _reversedCurrentDuration,
    _seekInVideoPosition,
    _selectedAnimeTimeStamp,
    _showButtonQuality,
    _animationController,
  ];

  Data? _mainVideoData;
  VideoController? _videoController;
  bool _isLoading = true;
  BoxFit _activeFit = BoxFit.contain;
  int _currentValueCircularAnimation = 0;
  Timer? _disposePlayer;
  Duration? _oldPositionAfterDispose;

  final List<Data> data = [];
  final Debouncer _nextEpisodeDebouncer = Debouncer(
    duration: Duration(milliseconds: 200),
  );
  final Debouncer _saveData = Debouncer(duration: Duration(milliseconds: 200));
  final Queue<BoxFit> _queueBoxFits = Queue<BoxFit>();
  final int _maxValueCircularAnimation = 2;

  late PlayerArgs _playerArgs = argument();
  late final AnimationController _animationController;
  late final ContentRepository _repository;
  // late final AppConfigController _appConfigController;
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
        return (position.inMicroseconds / duration.inMicroseconds).clamp(
          0.0,
          1.0,
        );
      }
    }
    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    // _appConfigController = read<AppConfigController>();
    _animeSkipController = read<AnimeSkipController>();
    _repository = read<ContentRepository>();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _startBoxFits();
    _historicController = read<HistoricController>();
    _libraryController = read<LibraryController>();
    _systemUIModeTimer = Timer.periodic(
      const Duration(seconds: 1),
      _setEnabledSystemUIMode,
    );
    addPostFrameCallback(_onInit);
  }

  void _startBoxFits() {
    BoxFit.values
        .where((fit) => !(fit == BoxFit.none || fit == _activeFit))
        .forEach(_queueBoxFits.add);
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
    setState(() => _currentValueCircularAnimation += 1);
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  void didPaused() {
    _systemUIModeTimer.cancel();
    _saveData.call(_saveVideoPosition);
    _oldPositionAfterDispose = player?.state.position;
    _disposePlayer = Timer(const Duration(minutes: 10), () {
      player?.dispose();
      _videoController = null;
      _disposePlayer = null;
    });
  }

  @override
  void didHidden() {
    _saveData.call(_saveVideoPosition);
  }

  @override
  void didInactive() {}

  @override
  void didResumed() async {
    _systemUIModeTimer = Timer.periodic(
      const Duration(seconds: 1),
      _setEnabledSystemUIMode,
    );
    _disposePlayer?.cancel();
    _disposePlayer = null;
    if (_videoController != null) {
      _startPlayerController(initPossition: _oldPositionAfterDispose);
    }
    isPipActivated = await AndroidPIP.isPipActivated;
    setState(() {});
  }

  Future<void> _getInitMainVideoData() async {
    _topTitle.value = 'Episódio ${_playerArgs.episode.number}';

    final state = Navigator.of(context);

    final file = AppStorage.getReleaseFile(
      _playerArgs.anime,
      _playerArgs.episode,
    );

    final result = file != null
        ? Result.success([FileVideoData(file: file)])
        : await _repository.getContent(_playerArgs.episode);

    result.fold(
      onSuccess: (data) {
        if (![VideoData, FileVideoData].contains(data.first.runtimeType)) {
          state.pop();
          return;
        }

        setState(() {
          this.data.clear();
          data.forEach(this.data.cast().addIfNoContains);
          _mainVideoData =
              data.firstWhereOrNull(
                (data) => data is VideoData && data.quality == Quality.Q480P,
              ) ??
              data.first;
          _playerArgs = _playerArgs.copyWith(data: data);
        });
      },
      onError: state.pop,
    );
  }

  Future<void> _getAnimeData() async {
    final lengthBool =
        !(_playerArgs.anime.releases.length <= 1 || _playerArgs.getAnimeData);
    if (lengthBool) return;
    final result = await _repository.getData(_playerArgs.anime);
    result.fold(
      onSuccess: (data) {
        setStateIfMounted(() {
          _playerArgs = _playerArgs.copyWith(anime: data as Anime);
        });
      },
    );
  }

  void _onInit(Duration time) async {
    await pipStart();

    await _getAnimeData().whenComplete(_incrementCurrentCircularAnimation);

    await _getInitMainVideoData().whenComplete(
      _incrementCurrentCircularAnimation,
    );

    await _startPlayerController(
      onInit: true,
      initPossition: _playerArgs.startPossition,
    ).whenComplete(_incrementCurrentCircularAnimation);

    _topTitle.value = 'Episódio ${_playerArgs.episode.number}';

    if (_isLoading) setState(() => _isLoading = false);

    if (player?.state.playing == true && _playerArgs.startPossition == null) {
      await _continueVideoByHistoricPosition();
    }
  }

  void _initControlls() {
    player?.dispose();
    _videoController = null;
    setPlayer = Player(configuration: PlayerConfiguration());
    _videoController = VideoController(
      player!,
      configuration: const VideoControllerConfiguration(),
    );
  }

  Future<void> _startPlayerController({
    bool onInit = false,
    Duration? initPossition,
    bool play = true,
  }) async {
    await subscriptions.cancelAll();

    if (onInit) _initControlls();

    List<Future> futures = [
      _registerListeners(),
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
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
            play: play,
          ),
        );
      case FileVideoData data:
        futures.add(
          player!.open(Media(data.file.path, start: initPossition), play: play),
        );
      default:
    }

    await Future.wait(futures);
    await player?.platform?.waitForVideoControllerInitializationIfAttached;
    await player?.platform?.waitForPlayerInitialization;
    if (_playerArgs.forceEnterFullScreen) {
      Future.delayed(
        const Duration(milliseconds: 800),
        () => PlayerView.videoStateKey.currentState?.enterFullscreen(),
      );
    }

    playerAudioHandler.playbackState.add(
      playerAudioHandler.playbackState.value.copyWith.call(
        processingState: AudioProcessingState.ready,
      ),
    );
  }

  void _completedListener(bool completed) {
    status.setValue(completed: completed);
    if (completed) {
      _saveVideoPosition();
      final playbackState = playerAudioHandler.playbackState;

      playbackState.add(
        playbackState.value.copyWith.call(
          processingState: AudioProcessingState.completed,
          controls: [],
        ),
      );
    }
  }

  Future<void> _registerListeners() async {
    subscriptions.addAll([
      player!.stream.playing.listen(_playingListener),
      player!.stream.position.listen(_positionListener),
      player!.stream.duration.listen(_durationListener),
      player!.stream.buffer.listen(_bufferListener),
      player!.stream.completed.listen(_completedListener),
    ]);
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

    final firstIndex = times.indexWhere((time) => position > time.atDuration);
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

    setState(() {
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
      '[$runtimeType][_continueVideoByHistoricPosition()][${entity.animeStringID}]',
    );
    // final currentPosition = data.getLastCurrentPosition();
    if (entity.percent == 0) return;

    final Anchor dialogAnchor = Anchor();

    // _setContinueVideoTimer = Timer(const Duration(seconds: 5), () {
    //   if (dialogAnchor.currentContext != null) {
    //     Navigator.of(dialogAnchor.currentContext!).pop();
    //   }
    // });

    _setContinueVideoTimer = dialogAnchor.autoPopAfterDelay();

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
              child: const Text('NÃO', style: TextStyle(color: Colors.red)),
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

    final position = entity.getLastCurrentPosition();

    if (result == true && mounted && position != null) {
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

    setState(() {
      _seekInVideoPosition.value = null;
      _playerArgs = _playerArgs.copyWith(data: null, episode: episode);
      _overlayNextEpisode.value = null;
    });

    customLog('[$runtimeType][_handleOnTapEpisode()][${episode.title}]');

    await _getInitMainVideoData();
    _openMenuInFullScreen.value = false;
    await _startPlayerController();
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

    // if (_videoPercent < _hiveController.historicSavePercent) return;

    final Duration position = player!.state.position;

    final Duration duration = player!.state.duration;

    final EpisodeEntity? entity = _historicController.repo.getHistoric(
      release: _playerArgs.episode,
      content: _playerArgs.anime,
    );

    final isComplete = _videoPercent >= 0.85;

    final EpisodeEntity episodeEntity = EpisodeEntity.save(
      anime: _playerArgs.anime,
      isComplete: isComplete,
      episode: _playerArgs.episode,
      currentPositionBase64: currentPositionBase64,
      position: position,
      duration: duration,
      entity: entity,
    );

    if (onSave != null) {
      await onSave();
      // playerAudioHandler.setPlayerController = null;
    }

    customLog(
      '[$runtimeType][_saveVideoPosition()][${episodeEntity.numberEpisode}]',
    );

    final other = _libraryController.repo
        .getContentEntityByStringID<AnimeEntity>(_playerArgs.anime.stringID);

    final animeEntity = _playerArgs.anime.toEntity().copyWith(
      createdAt: other?.createdAt,
      isFavorite: other?.isFavorite,
      updatedAt: other?.updatedAt,
    );

    animeEntity.animeSkip.value ??= _playerArgs.anime.animeSkip?.toEntity;

    animeEntity.addEpisode(episodeEntity);

    if (animeEntity.animeSkip.value != null) {
      await _animeSkipController.save(animeEntity.animeSkip.value!);
    }
    await _libraryController.add(contentEntity: animeEntity);
    await _historicController.add(HistoricEntity: episodeEntity);
  }

  void _handleClickSkipAnime(AnimeTimeStamp item) {
    player?.seek(item.duration);
  }

  void _handleOnTapData(Data data) async {
    _showButtonQuality.value = false;
    setState(() => _mainVideoData = data);
    await _startPlayerController(initPossition: player?.state.position);
    player?.play();
  }

  @override
  Widget buildByArgument(BuildContext context, PlayerArgs argument) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: (mounted ? _playerArgs : argument).times.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => _showAnimeSkip.value = !_showAnimeSkip.value,
              child: Icon(MdiIcons.timelapse),
            ),
      body: PlayerScope(
        mainData: _mainVideoData,
        showButtonQuality: _showButtonQuality,
        data: data,
        onTapData: _handleOnTapData,
        animationController: _animationController,
        onClickSkipAnime: _handleClickSkipAnime,
        selectedAnimeTimeStamp: _selectedAnimeTimeStamp,
        showAnimeSkip: _showAnimeSkip,
        openMenuInFullScreen: _openMenuInFullScreen,
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
    _systemUIModeTimer.cancel();
    _setContinueVideoTimer?.cancel();
    _nextEpisodeDebouncer.cancel();
    _disposePlayer?.cancel();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // _saveVideoPosition(() async {
    //   await player?.stop();
    //   await player?.dispose();
    // });
    _saveData.cancel();
    super.dispose();
  }

  @override
  void deactivate() {
    customLog("$this{deactivate()}");
    _saveVideoPosition(() async {
      await player?.stop();
      await player?.dispose();
    });
    super.deactivate();
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
        mainAxisAlignment: isLoading
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          if (isLoading) ...[
            _LoadingIndicator(
              progress:
                  scope.currentValueCircularAnimation /
                  scope.maxValueCircularAnimation,
            ),
            const SizedBox(height: 8),
            Text(
              'Carregando...',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ] else if (videoCtrl != null) ...[
            Flexible(
              child: _VideoPlayerArea(fit: fit, controller: videoCtrl),
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
          aspectRatio: 16 / 9,
          fit: fit,
          controller: controller,
          onEnterFullscreen: scope.isPipActivated
              ? () async {}
              : () async {
                  await SystemChrome.setPreferredOrientations([
                    DeviceOrientation.landscapeRight,
                    DeviceOrientation.landscapeLeft,
                  ]);
                  // SystemChrome.setEnabledSystemUIMode(
                  //   SystemUiMode.immersive,
                  // );
                },

          onExitFullscreen: scope.isPipActivated
              ? () async {}
              : () async {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                  ]);
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
    final appConfig = context.watch<AppConfigController>();
    final size = MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: scope.showAnimeSkip,
      builder: (context, child) => Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: _EpisodeList(appConfig: appConfig)),
          if (args.times.isNotEmpty)
            CustomPopup(
              startAnimatedAlignment: Alignment.centerRight,
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
                    if (!scope.showAnimeSkip.value) {
                      return const SizedBox.shrink();
                    }
                    return ListTile(
                      selected: selected?.id == stamp.id,
                      leading: Text(Duration(microseconds: stamp.at).label()),
                      title: Text(stamp.timeStampType.label),
                      visualDensity: const VisualDensity(
                        vertical: -4,
                        horizontal: -2,
                      ),
                      onTap: () => scope.onClickSkipAnime(stamp),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _EpisodeList extends StatelessWidget {
  final AppConfigController appConfig;
  const _EpisodeList({required this.appConfig});

  @override
  Widget build(BuildContext context) {
    final scope = PlayerScope.of(context);
    final args = scope.playerArgs;
    final content = scope.playerArgs.anime;
    final releases = args.anime.releases.reversed.toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 18),
      // separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: releases.length,
      itemBuilder: (context, index) {
        final ep = releases[index];
        final selected = ep.stringID.contains(args.episode.stringID);
        return ReleaseContent<Episode>(
          release: ep,
          content: content,
          index: index,
          trailing: const SizedBox.shrink(),
          selected: selected,
          onDoubleTap: (release) => ReleaseUtils.onDoubleTap(context, release),
          onTap: scope.onTapEpisode,
        );
      },
    );
  }
}
