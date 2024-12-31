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
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_screenshot_.dart';
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
        PlayerSimplePipMixin,
        PlayerAudioHandlerMixin,
        PlayerAudioSessionMixin,
        PlayerScreenShotMixin,
        SingleTickerProviderStateMixin,
        PlayerStatusShotMixin {
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

  final List<VideoData> data = [];
  final Queue<BoxFit> _queueBoxFits = Queue<BoxFit>();
  final int _maxValueCircularAnimation = 2;

  late PlayerArgs _playerArgs = argument();
  late final AnimationController _animationController;
  late final ContentRepository _repository;
  late final LibraryService _libraryService;
  late final HiveController _hiveController;
  late final LibraryController _libraryController;
  late final HistoricController _historicController;
  late final Timer _systemUIModeTimer;

  // Debouncer _saveDataDebouncer = Debouncer(
  //   duration: const Duration(milliseconds: 200),
  // );
  Timer? _setContinueVideoTimer;

  bool get _hasNextEpisode {
    // if (!_playerArgs.getAnimeData || _playerArgs.anime.releases.isEmpty) {
    //   return false;
    // }
    return _playerArgs.anime.releases.last.stringID !=
            _playerArgs.episode.stringID &&
        (!_playerArgs.getAnimeData || _playerArgs.anime.releases.isEmpty);
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
    _libraryService = context.read<LibraryService>();
    _hiveController = context.read<HiveController>();
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
      case AppLifecycleState.detached:
    }

    super.didChangeAppLifecycleState(state);
  }

  Future<void> _getInitMainVideoData() async {
    _topTitle.value = 'Episódio ${_playerArgs.episode.number}';
    if (_playerArgs.data != null && !_playerArgs.getAnimeData) {
      _mainVideoData = _playerArgs.data;
      return;
    }

    final state = Navigator.of(context);
    final result = await _repository.getContent(_playerArgs.episode);

    result.fold(
      onSuccess: (data) {
        if (data.first is! VideoData) state.pop();

        setStateIfMounted(() {
          data.forEach(this.data.cast().addIfNoContains);
          _mainVideoData = data.first as VideoData;
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

    _playerArgs = argument();

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
      // player!.setAudioDevice(AudioDevice.auto()),
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

    if (_playerArgs.forceEnterFullScreen) {
      _videoController?.waitUntilFirstFrameRendered.whenComplete(() {
        PlayerView.videoStateKey.currentState?.enterFullscreen();
      });
    }

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

    customLog("[$runtimeType][_handleSetFits()][$_queueBoxFits]");

    setStateIfMounted(() {
      _activeFit = nextBoxFit;
      videoState.update(fit: nextBoxFit);
    });
  }

  void _nextEpisode(Duration position) async {
    final maxPosition = player!.state.duration;
    final positionActiveOverlay = maxPosition - const Duration(seconds: 90);
    final diff = player!.state.duration - position;

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
      _overlayNextEpisode.value = null;
    }
  }

  Future<void> _continueVideoByHistoricPosition() async {
    final entity = _historicController.entities
        .firstWhereOrNull((entity) => switch (entity) {
              EpisodeEntity data =>
                data.stringID.contains(_playerArgs.episode.stringID) &&
                    data.animeStringID.contains(_playerArgs.anime.stringID),
              _ => false,
            }) as EpisodeEntity?;

    if (entity == null) return;

    customLog(
        '[$runtimeType][_continueVideoByHistoricPosition()][${entity.animeStringID}]');

    if (entity.currentDuration == 0) return;

    final GlobalKey anchor = GlobalKey();

    _setContinueVideoTimer = Timer(const Duration(seconds: 5), () {
      if (anchor.currentContext != null) {
        Navigator.of(anchor.currentContext!).pop();
      }
    });

    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          key: anchor,
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
    _overlayNextEpisode.value = null;

    customLog('[$runtimeType][_handleOnTapEpisode()][${episode.title}]');

    final file = AppStorage.getReleaseFile(_playerArgs.anime, episode);

    Data? data;

    if (file != null) data = FileVideoData(file: file);

    // await playerAudioHandler.stop();
    setStateIfMounted(() {
      _playerArgs = _playerArgs.copyWith(
        episode: episode,
        data: data,
      );
    });

    await _getInitMainVideoData();
    _openMenuInFullScreen.value = false;
    await _startPlayerController();
    await _continueVideoByHistoricPosition();
  }

  Future<void> _saveVideoPosition([void Function()? onSave]) async {
    player?.pause();
    if (_mainVideoData == null) return;
    // _saveDataDebouncer.cancel();
    final currentPositionBase64 = await videoScreenshotBase64();
    await setSessionActive(false);
    await playerAudioHandler.stop();

    if (_videoPercent < _hiveController.historicSavePercent) return;

    final Duration position = player!.state.position;

    final Duration duration = player!.state.duration;

    final HistoryService historyService = HistoryService(_historicController);
    final EpisodeEntity? entity = historyService.getHistoric(
      release: _playerArgs.episode,
      content: _playerArgs.anime,
    );
    // final entity = historyService.entities.firstWhereOrNull(
    //   (episode) =>
    //       episode is EpisodeEntity &&
    //       episode.animeStringID.contains(_playerArgs.anime.stringID) &&
    //       episode.stringID.contains(_playerArgs.episode.stringID),
    // ) as EpisodeEntity?;

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

    await player?.stop();
    if (onSave != null) {
      onSave();
      playerAudioHandler.setPlayerController = null;
    }

    customLog(
        '[$runtimeType][_saveVideoPosition()][${episodeEntity.numberEpisode}]');

    final AnimeEntity animeEntity = _libraryService.getContentEntityByStringID(
      _playerArgs.anime.stringID,
      orElse: () => _playerArgs.anime.toEntity(createdAt: DateTime.now()),
    );

    animeEntity.animeSkip.value ??= _playerArgs.anime.animeSkip?.toEntity;
    animeEntity.episodes.add(episodeEntity);

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
      extendBody: true,
      body: PlayerScope(
        animationController: _animationController,
        onClickSkipAnime: _handleClickSkipAnime,
        selectedAnimeTimeStamp: _selectedAnimeTimeStamp,
        showAnimeSkip: _showAnimeSkip,
        openMenuInFullScreen: _openMenuInFullScreen,
        draggableScrollableController: draggableScrollableController,
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
    final PlayerScope scope = PlayerScope.of(context);
    final bool isLoading = PlayerScope.isLoadingOf(context);
    final BoxFit activeFit = PlayerScope.activeFitOf(context);
    final PlayerArgs playerArgs = PlayerScope.playerArgsOf(context);
    final VideoController? videoController = scope.videoController;
    final int currentValueCircularAnimation =
        PlayerScope.currentValueCircularAnimationOf(context);
    final HiveController hiveController = context.watch<HiveController>();

    final Size sizeOf = MediaQuery.sizeOf(context);

    List<Widget> children = [];

    if (isLoading) {
      customLog(
          'progress: ${currentValueCircularAnimation / scope.maxValueCircularAnimation}');
      children.addAll([
        Center(
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 150),
            tween: Tween(
              begin: 0.0,
              end: currentValueCircularAnimation /
                  scope.maxValueCircularAnimation,
            ),
            builder: (_, value, __) =>
                CircularProgressIndicator.adaptive(value: value),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Carregando...',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ]);
    } else if (videoController != null) {
      children.addAll(
        [
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: sizeOf.height * .40,
                  width: double.infinity,
                  child: PipWidget(
                    onPipAction: scope.onPipAction,
                    onPipEntered: scope.onPipChange,
                    onPipExited: scope.onPipChange,
                    pipLayout: PipActionsLayout.media_only_pause,
                    pipChild: Video(
                      aspectRatio: 16 / 9,
                      fit: activeFit,
                      controls: (state) => const SizedBox.shrink(),
                      controller: videoController,
                    ),
                    child: Video(
                      filterQuality: FilterQuality.medium,
                      aspectRatio: 16 / 9,
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
                      fit: activeFit,
                      controls: (state) {
                        final PlayerScope scopeFullScreen = PlayerScope.of(
                            PlayerView.videoStateKey.currentContext!);
                        if (!scopeFullScreen.isPipActivated) {
                          return CustomMaterialControls(state);
                        }
                        return const SizedBox.shrink();
                      },
                      key: PlayerView.videoStateKey,
                      controller: videoController,
                    ),
                  ),
                ),
                if (!scope.isPipActivated &&
                    (playerArgs.getAnimeData &&
                        !playerArgs.forceEnterFullScreen))
                  Expanded(
                    flex: 1,
                    child: ValueListenableBuilder(
                      valueListenable: scope.showAnimeSkip,
                      builder: (context, value, child) {
                        return Row(
                          children: [
                            Expanded(
                              child: ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                padding:
                                    const EdgeInsets.only(top: 18, bottom: 18),
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemCount: playerArgs.anime.releases.length,
                                itemBuilder: (context, index) {
                                  final Episode episode = playerArgs
                                      .anime.releases.reversed
                                      .elementAt(index);

                                  return ListTile(
                                    minLeadingWidth: value ? 0 : 112,
                                    selected: episode.stringID
                                        .contains(playerArgs.episode.stringID),
                                    leading: value
                                        ? null
                                        : SizedBox(
                                            width: 112,
                                            height: double.infinity,
                                            child: episode.thumbnail != null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: CachedNetworkImage(
                                                      httpHeaders: {
                                                        ...App.HEADERS,
                                                        'Referer':
                                                            '${hiveController.source.baseURL}/',
                                                      },
                                                      imageUrl:
                                                          episode.thumbnail!,
                                                      placeholder: (context,
                                                              url) =>
                                                          const Card.filled(),
                                                      fit: BoxFit.cover,
                                                      maxWidthDiskCache: 300,
                                                      maxHeightDiskCache: 200,
                                                    ),
                                                  )
                                                : const Card.filled(),
                                          ),
                                    titleTextStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold),
                                    onTap: () async {
                                      customLog(
                                        'tapped name: ${episode.title} - id: ${episode.stringID}',
                                      );
                                      scope.onTapEpisode(episode);
                                    },
                                    onLongPress: episode.sinopse?.isNotEmpty ==
                                            true
                                        ? () {
                                            showModalBottomSheet(
                                              isScrollControlled: false,
                                              isDismissible: true,
                                              showDragHandle: true,
                                              useRootNavigator: true,
                                              context: context,
                                              builder: (context) {
                                                return Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 12.0,
                                                      ),
                                                      child: Text(
                                                        'Sinopse',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleLarge
                                                            ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 16,
                                                      ),
                                                      child: Text(
                                                        episode.sinopse!.trim(),
                                                        textAlign:
                                                            TextAlign.justify,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 30),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        : null,
                                    visualDensity: VisualDensity(
                                      vertical: value ? -4 : 2,
                                      horizontal: -2,
                                    ),
                                    title: Text(
                                      '${episode.number}. ${episode.title}',
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (playerArgs.times.isNotEmpty)
                              CustomPopup(
                                duration: const Duration(milliseconds: 100),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                                height: sizeOf.height,
                                width: sizeOf.width / 2,
                                show: value,
                                items: playerArgs.times,
                                builderFunction: (context, index, item) {
                                  return ValueListenableBuilder(
                                    valueListenable:
                                        scope.selectedAnimeTimeStamp,
                                    builder: (context, value, child) {
                                      return ListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: index == 0
                                                ? Radius.circular(8)
                                                : Radius.zero,
                                            bottomLeft: index ==
                                                    playerArgs.times.length - 1
                                                ? Radius.circular(8)
                                                : Radius.zero,
                                          ),
                                        ),
                                        onTap: () =>
                                            scope.onClickSkipAnime.call(item),
                                        selected: value?.id.contains(item.id) ??
                                            false,
                                        leading: Text(
                                          Duration(microseconds: item.at)
                                              .label(),
                                        ),
                                        title: Text(item.timeStampType.label),
                                        visualDensity: const VisualDensity(
                                          vertical: -4,
                                          horizontal: -2,
                                        ),
                                      );
                                    },
                                  );
                                },
                              )
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center;

    if (!isLoading) mainAxisAlignment = MainAxisAlignment.start;

    return MaterialVideoControlsTheme(
      normal: const MaterialVideoControlsThemeData(),
      fullscreen: const MaterialVideoControlsThemeData(
        controlsTransitionDuration: Duration(milliseconds: 650),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: mainAxisAlignment,
        children: children,
      ),
    );
  }
}
