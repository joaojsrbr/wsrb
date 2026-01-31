// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:collection';

import 'package:android_pip/actions/pip_actions_layout.dart';
import 'package:android_pip/android_pip.dart';
import 'package:android_pip/pip_widget.dart';
import 'package:audio_service/audio_service.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:provider/provider.dart';

import '../../../utils/anchor.dart';
import '../../../utils/auto_dispose_mixin.dart';
import '../../../utils/release_utils.dart';
import '../../shared/mixins/subscriptions.dart';
import '../../shared/widgets/custom_popup.dart';
import '../../shared/widgets/release_content.dart';
import '../arguments/player_args.dart';
import '../mixins/player_audio_handler.dart';
import '../mixins/player_audio_session.dart';
import '../mixins/player_controller.dart';
import '../mixins/player_lifecycles_states.dart';
import '../mixins/player_pip.dart';
import '../mixins/player_screenshot.dart';
import '../mixins/player_status.dart';
import '../widgets/material_video_controls.dart';
import '../widgets/scope.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  static final GlobalKey<VideoState> videoStateKey = GlobalKey<VideoState>();

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView>
    with
        WidgetsBindingObserver,
        SubscriptionsByStateArgumentMixin<PlayerView>,
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
  final ValueNotifier<AnimeTimeStamp?> _selectedAnimeTimeStamp = ValueNotifier(null);
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
  Timer? _setContinueVideoTimer;
  bool _argsInitialized = false;

  final List<Data> data = [];
  final Debouncer _nextEpisodeDebouncer = Debouncer(
    duration: const Duration(milliseconds: 200),
  );
  final Debouncer _saveData = Debouncer(duration: const Duration(milliseconds: 200));
  final Queue<BoxFit> _queueBoxFits = Queue<BoxFit>();
  final int _maxValueCircularAnimation = 2;
  Data? _firstSelectData;
  late PlayerArgs _playerArgs;

  late final AnimationController _animationController;
  late final ContentRepository _repository;
  // late final AppConfigController _appConfigController;
  late final LibraryController _libraryController;
  late final HistoricController _historicController;
  late final Timer _systemUIModeTimer;

  bool get _hasNextEpisode {
    if (_playerArgs.anime.releases.isEmpty) {
      return false;
    }

    return _playerArgs.anime.releases.last.stringID != _playerArgs.episode.stringID;
  }

  @override
  void initState() {
    super.initState();
    // _appConfigController = read<AppConfigController>();
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
    _initControlls();
    addPostFrameCallback(_onInit);
  }

  void _startBoxFits() {
    BoxFit.values
        .where((fit) => !(fit == BoxFit.none || fit == _activeFit))
        .forEach(_queueBoxFits.add);
  }

  void _setEnabledSystemUIMode(Timer timer) {
    if (!mounted) return;

    if (playing && !completed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Future<void> _incrementCurrentCircularAnimation() async {
    setState(() => _currentValueCircularAnimation += 1);
    // await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  void didPaused() {
    _saveData.call(_saveVideoPosition);
    // _oldPositionAfterDispose = player.state.position;
    // _disposePlayer = Timer(const Duration(minutes: 10), () {
    //   player.dispose();
    //   _videoController = null;
    //   _disposePlayer = null;
    // });
  }

  @override
  void didHidden() {
    _saveData.call(_saveVideoPosition);
  }

  @override
  void didInactive() {}

  @override
  void didResumed() async {
    // _systemUIModeTimer.cancel();
    // _systemUIModeTimer = Timer.periodic(
    //   const Duration(seconds: 1),
    //   _setEnabledSystemUIMode,
    // );
    // _disposePlayer?.cancel();
    // _disposePlayer = null;
    // if (_videoController != null) {
    //   _startPlayerController(initPossition: _oldPositionAfterDispose);
    // }
    isPipActivated = await AndroidPIP.isPipActivated;
    setStateIfMounted(() {});
  }

  Future<void> _getInitMainVideoData() async {
    _topTitle.value = _playerArgs.episode.getEpisodeTitle();

    final navigator = Navigator.of(context);

    Result<List<Data>> result;

    // 1️⃣ Verifica se já existe arquivo local
    final file = AppStorage.getReleaseFile(_playerArgs.anime, _playerArgs.episode);
    if (file != null) {
      result = Result.success([FileVideoData(file: file)]);
    }
    // 3️⃣ Usa dados pré-carregados, se existirem
    else if (_playerArgs.data.isNotEmpty) {
      result = Result.success(_playerArgs.data);
    }
    // 4️⃣ Caso contrário, busca do repositório
    else {
      result = await _repository.getContent(_playerArgs.episode, _playerArgs.anime);
    }

    // 5️⃣ Trata resultado
    result.fold(
      onSuccess: (data) {
        if (data.isEmpty) {
          navigator.pop();
          return;
        }

        final mainVideo = data.first is FileVideoData
            ? data.first
            : _firstSelectData != null
            ? _firstSelectData!
            : _selectMainVideo(data.whereType<VideoData>().toList());

        setState(() {
          this.data
            ..clear()
            ..addAll(data.where((e) => !this.data.contains(e)));

          _mainVideoData = mainVideo;
          _playerArgs = _playerArgs.copyWith(data: data);
        });
      },
      onError: navigator.pop,
    );
  }

  /// 🔧 Função auxiliar para escolher o vídeo principal
  VideoData _selectMainVideo(List<VideoData> data) {
    return data.firstWhere((d) => d.quality == Quality.Q480P, orElse: () => data.first);
  }

  Future<void> _getAnimeData() async {
    _firstSelectData = _playerArgs.firstSelectData;
    if (_playerArgs.anime.repoStatus.getData &&
        _playerArgs.anime.repoStatus.getReleases) {
      return;
    }
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

    await _getInitMainVideoData().whenComplete(_incrementCurrentCircularAnimation);

    await _startPlayerController(
      initPossition: _playerArgs.startPossition,
    ).whenComplete(_incrementCurrentCircularAnimation);

    _topTitle.value = _playerArgs.episode.getEpisodeTitle();

    if (_isLoading) setState(() => _isLoading = false);

    if (player.state.playing == true && _playerArgs.startPossition == null) {
      await _continueVideoByHistoricPosition();
    }
  }

  void _initControlls() async {
    if (isPlayerInitialized) {
      await player.dispose();
      _videoController = null;
      isPlayerInitialized = false;
    }

    initPlayer(const PlayerConfiguration());
    _videoController = VideoController(
      player,
      configuration: const VideoControllerConfiguration(),
    );
  }

  Future<void> _startPlayerController({Duration? initPossition, bool play = true}) async {
    await subscriptions.cancelAll();

    // if (onInit) _initControlls();

    final stepTwo = [
      _registerListeners(),
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
    ];

    final List<Future<dynamic>> stepOne = [];

    switch (_mainVideoData) {
      case VideoData data:
        stepOne.add(
          player.open(
            Media(data.videoContent, start: initPossition, httpHeaders: data.httpHeaders),
            play: play,
          ),
        );
      case FileVideoData data:
        stepOne.add(player.open(Media(data.file.path, start: initPossition), play: play));
      default:
    }

    await Future.wait(stepOne);
    await Future.wait(stepTwo);
    // await player.platform?.waitForVideoControllerInitializationIfAttached;
    // await player.platform?.waitForPlayerInitialization;
    await _videoController?.waitUntilFirstFrameRendered;
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
      playerAudioHandler.limpar();
    }
  }

  Future<void> _registerListeners() async {
    subscriptions.addAll([
      player.stream.playing.listen(_playingListener),
      player.stream.position.listen(_positionListener),
      player.stream.duration.listen(_durationListener),
      player.stream.buffer.listen(_bufferListener),
      player.stream.completed.listen(_completedListener),
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
    playerAudioHandler.setPlaybackState(player.state);

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
    final maxPosition = duration;
    final positionActiveOverlay = maxPosition - const Duration(seconds: 120);
    final diff = maxPosition - position;

    if (position >= positionActiveOverlay &&
        !diff.inSeconds.isNegative &&
        _hasNextEpisode &&
        maxPosition.inSeconds > 0) {
      final indexOf = _playerArgs.anime.releases.indexOf(_playerArgs.episode) + 1;
      final nextEpisode = _playerArgs.anime.releases[indexOf];

      _overlayNextEpisode.value = 'Episódio ${nextEpisode.numberInt} - ${diff.inSeconds}';
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
      '[$runtimeType][_continueVideoByHistoricPosition()][${entity.contentStringID}]',
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

    final position = entity.position;

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
    playerAudioHandler.limpar();
    await setSessionActive(false);
    await _saveVideoPosition();

    setState(() {
      _firstSelectData = null;
      _seekInVideoPosition.value = null;
      _playerArgs = _playerArgs.copyWith(data: [], episode: episode);
      _overlayNextEpisode.value = null;
    });

    customLog('[$runtimeType][_handleOnTapEpisode()][${episode.title}]');

    _openMenuInFullScreen.value = false;
    await _getInitMainVideoData();
    await _startPlayerController();
    await _continueVideoByHistoricPosition();
  }

  @override
  void didChangeDependencies() {
    final args = ModalRoute.settingsOf(context)?.arguments;

    if (args is PlayerArgs && !_argsInitialized) {
      _playerArgs = args;
      _argsInitialized = true;
    }

    super.didChangeDependencies();
  }

  Future<void> _saveVideoPosition([
    Future<void> Function()? onSave,
    // bool stop = false,
  ]) async {
    player.pause();
    if (_mainVideoData == null || player.state.duration.inMicroseconds == 0.0) {
      return;
    }

    // _saveDataDebouncer.cancel();
    final currentPositionBase64 = await videoScreenshotBase64();
    await setSessionActive(false);
    await playerAudioHandler.stop();

    // if (_videoPercent < _hiveController.historicSavePercent) return;

    final EpisodeEntity? entity = _historicController.repo.getHistoric(
      release: _playerArgs.episode,
      content: _playerArgs.anime,
    );

    final isComplete = videoPercent >= 0.85;

    final EpisodeEntity episodeEntity = EpisodeEntity.save(
      anime: _playerArgs.anime,
      isComplete: isComplete,
      episode: _playerArgs.episode,
      currentPositionBase64: currentPositionBase64,
      position: position,
      duration: duration,
      animeSkipEntity: _playerArgs.anime.animeSkip?.toEntity,
      entity: entity,
    );

    if (onSave != null) {
      await onSave();
      // playerAudioHandler.setPlayerController = null;
    }

    customLog('[$runtimeType][_saveVideoPosition()][${episodeEntity.numberEpisode}]');

    final other = _libraryController.repo.getContentEntityByStringID<AnimeEntity>(
      _playerArgs.anime.stringID,
    );

    final animeEntity = _playerArgs.anime.toEntity().copyWith(
      createdAt: other?.createdAt,
      isFavorite: other?.isFavorite,
      updatedAt: other?.updatedAt,
    );

    // animeEntity.animeSkip.value ??= _playerArgs.anime.animeSkip?.toEntity;

    animeEntity.addEpisode(episodeEntity);

    await _libraryController.add(contentEntity: animeEntity);
    await _historicController.add(historic: episodeEntity);
  }

  void _handleClickSkipAnime(AnimeTimeStamp item) {
    player.seek(item.duration);
  }

  void _handleOnTapData(Data data) async {
    _showButtonQuality.value = false;
    setState(() => _mainVideoData = data);
    await _startPlayerController(initPossition: player.state.position);
    player.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: _playerArgs.times.isEmpty
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
        playerArgs: _playerArgs,
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
    if (_argsInitialized) {
      customLog("$this{deactivate()}");
      _saveVideoPosition(() async {
        await player.stop();
        await player.dispose();
      });
    }
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
        mainAxisAlignment: isLoading ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (isLoading) ...[
            _LoadingIndicator(
              progress:
                  scope.currentValueCircularAnimation / scope.maxValueCircularAnimation,
            ),
            const SizedBox(height: 8),
            Text('Carregando...', style: Theme.of(context).textTheme.titleSmall),
          ] else if (videoCtrl != null) ...[
            Flexible(
              child: _VideoPlayerArea(fit: fit, controller: videoCtrl),
            ),
            if (!args.forceEnterFullScreen && !isPipActivated)
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
        builder: (_, value, __) => CircularProgressIndicator.adaptive(value: value),
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

    final videoWidget = Video(
      key: PlayerView.videoStateKey,
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
            },
      onExitFullscreen: scope.isPipActivated
          ? () async {}
          : () async {
              SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
            },
      controls: CustomMaterialControls.new,
    );

    final pipVideoWidget = Video(
      fit: fit,
      aspectRatio: 16 / 9,
      controller: controller,
      controls: (state) => const SizedBox.shrink(),
    );

    return SizedBox(
      height: scope.isPipActivated ? double.infinity : size.height * 0.4,
      width: double.infinity,
      child: PipWidget(
        onPipAction: scope.onPipAction,
        onPipEntered: scope.onPipChange,
        onPipExited: scope.onPipChange,
        pipLayout: PipActionsLayout.media_only_pause,
        pipChild: pipVideoWidget,
        child: videoWidget,
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
            CustomPopup.items(
              startAnimatedAlignment: Alignment.centerRight,
              duration: const Duration(milliseconds: 250),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              height: size.height,
              width: size.width / 2,
              show: scope.showAnimeSkip.value,
              items: args.times,
              itemBuilder: (ctx, idx, stamp) {
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
                      visualDensity: const VisualDensity(vertical: -4, horizontal: -2),
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
    final anime = scope.playerArgs.anime;
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
          content: anime,
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
