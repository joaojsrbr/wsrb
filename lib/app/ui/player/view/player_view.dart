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
import 'package:app_wsrb_jsr/app/ui/player/widgets/material_video_controls.dart';
import 'package:app_wsrb_jsr/app/ui/player/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';
import 'package:app_wsrb_jsr/app/utils/custom_states.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
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
        PlayerScreenShotMixin {
  final ValueNotifier<String?> _overlayBoxFit = ValueNotifier(null);
  final ValueNotifier<String?> _overlayNextEpisode = ValueNotifier(null);
  final ValueNotifier<String> _topTitle = ValueNotifier('');
  final ValueNotifier<bool> _lockPlayer = ValueNotifier(false);
  final MenuController _openMenuInFullScreen = MenuController();
  final ValueNotifier<bool> _reversedCurrentDuration = ValueNotifier(false);
  final ValueNotifier<Duration?> _seekInVideoPosition = ValueNotifier(null);

  Data? _mainVideoData;
  VideoController? _videoController;
  bool _isLoading = true;
  BoxFit _activeFit = BoxFit.contain;
  double _currentValueCircularAnimation = 0;

  final List<VideoData> data = [];
  final Queue<BoxFit> _queueBoxFits = Queue<BoxFit>();
  final _PlayerStatus _status = _PlayerStatus();
  final double _maxValueCircularAnimation = 1.0;

  late PlayerArgs _playerArgs = argument();

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
    _libraryService = context.read<LibraryService>();
    _hiveController = context.read<HiveController>();
    _repository = context.read<ContentRepository>();
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
    if (player == null) return;

    if (_playing && !player!.state.completed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Future<void> _incrementCurrentCircularAnimation() async {
    setStateIfMounted(() => _currentValueCircularAnimation += 0.5);
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
    if ((_playerArgs.data != null || !_playerArgs.getAnimeData) &&
        _playerArgs.data != null) {
      _mainVideoData = _playerArgs.data;
      _topTitle.value = 'Episódio ${_playerArgs.episode.number}';
      return;
    }

    _topTitle.value = 'Episódio ${_playerArgs.episode.number}';

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
                  anime: data.merge(_playerArgs.anime) as Anime,
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
      setPlayer = Player(configuration: const PlayerConfiguration(pitch: true));
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

    // await _videoController?.waitUntilFirstFrameRendered;

    if (!_playerArgs.getAnimeData && _playerArgs.forceEnterFullScreen) {
      addPostFrameCallback((time) {
        PlayerView.videoStateKey.currentState?.enterFullscreen();
      });
    }

    playbackState.add(playbackState.value.copyWith
        .call(processingState: AudioProcessingState.ready));
  }

  void _completedListener(bool completed) {
    _status.setValue(completed: completed);
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
    _status.setValue(buffer: buffer);
  }

  void _playingListener(bool playing) async {
    setSessionActive(playing);
    _status.setValue(playing: playing);
    await AndroidPIP().setIsPlaying(playing);
  }

  void _durationListener(Duration duration) {
    _status.setValue(duration: duration);
    if (duration != Duration.zero) setPlayerMedia(_playerArgs);
  }

  void _positionListener(Duration position) {
    _status.setValue(position: position);
    playerAudioHandler.setPlaybackState(player!.state);

    if (_seekInVideoPosition.value != null) {
      playerAudioHandler.seek(_seekInVideoPosition.value!);
      _seekInVideoPosition.value = null;
    }

    if (_hasNextEpisode) _nextEpisode(position);
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
    await _saveVideoPosition(playerAudioHandler.stop);

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
    await _startPlayerController();
    await _continueVideoByHistoricPosition();
  }

  Future<void> _saveVideoPosition([Future<void> Function()? onSave]) async {
    // _saveDataDebouncer.cancel();
    final currentPositionBase64 = await videoScreenshotBase64();

    if (_videoPercent < _hiveController.historicSavePercent) return;

    final Duration position = player!.state.position;

    final Duration duration = player!.state.duration;

    final HistoryService historyService = HistoryService(_historicController);

    final entity = historyService.entities.firstWhereOrNull(
      (episode) =>
          episode is EpisodeEntity &&
          episode.animeStringID.contains(_playerArgs.anime.stringID) &&
          episode.stringID.contains(_playerArgs.episode.stringID),
    ) as EpisodeEntity?;

    bool isComplete = _videoPercent >= 0.85;

    final EpisodeEntity episodeEntity = EpisodeEntity(
      currentDuration: position.inMicroseconds,
      currentPositionBase64: currentPositionBase64,
      title: _playerArgs.episode.title,
      animeStringID: _playerArgs.anime.stringID,
      generateID: _playerArgs.episode.generateID,
      slugSerie: _playerArgs.episode.slugSerie,
      url: _playerArgs.episode.url,
      episodeDuration: duration.inMicroseconds,
      thumbnail: _playerArgs.episode.thumbnail,
      createdAt: entity?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      stringID: _playerArgs.episode.stringID,
      isComplete: isComplete,
      sinopse: _playerArgs.episode.sinopse,
      numberEpisode: int.tryParse(_playerArgs.episode.number),
    );

    customLog(
        '[$runtimeType][_saveVideoPosition()][${episodeEntity.numberEpisode}]');

    AnimeEntity animeEntity = _playerArgs.anime.toEntity();

    final bAnimeEntity = _libraryService
        .getContentEntityByStringID(_playerArgs.anime.stringID) as AnimeEntity?;

    if (bAnimeEntity != null) {
      animeEntity = animeEntity.merge(bAnimeEntity) as AnimeEntity;
    }

    animeEntity.episodes.add(episodeEntity);

    await _libraryController.add(contentEntity: animeEntity);

    await _historicController.add(historyEntity: episodeEntity);

    await onSave?.call();
  }

  @override
  Widget buildByArgument(BuildContext context, PlayerArgs argument) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: PlayerScope(
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
    super.dispose();

    _topTitle.dispose();
    _seekInVideoPosition.dispose();
    _lockPlayer.dispose();
    _reversedCurrentDuration.dispose();
    _overlayBoxFit.dispose();
    _systemUIModeTimer.cancel();
    _setContinueVideoTimer?.cancel();
    _overlayNextEpisode.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (_mainVideoData != null) {
      player?.pause();
      _saveVideoPosition(() async {
        setSessionActive(false);
        await player?.stop();
        await playerAudioHandler.stop();
        playerAudioHandler.setPlayerController = null;
      });
    } else {
      playerAudioHandler.stop();
      player?.stop();
      playerAudioHandler.setPlayerController = null;
    }
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
    final double currentValueCircularAnimation =
        PlayerScope.currentValueCircularAnimationOf(context);
    final HiveController hiveController = context.watch<HiveController>();

    final Size sizeOf = MediaQuery.sizeOf(context);

    List<Widget> children = [];

    if (isLoading) {
      children.addAll([
        Center(
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 300),
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
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 18, bottom: 18),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemCount: playerArgs.anime.releases.length,
                      itemBuilder: (context, index) {
                        final Episode episode =
                            playerArgs.anime.releases.reversed.elementAt(index);

                        return ListTile(
                          selected: episode.stringID
                              .contains(playerArgs.episode.stringID),
                          leading: SizedBox(
                            width: 112,
                            height: double.infinity,
                            child: episode.thumbnail != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      httpHeaders: {
                                        ...App.HEADERS,
                                        'Referer':
                                            '${hiveController.source.baseURL}/',
                                      },
                                      imageUrl: episode.thumbnail!,
                                      placeholder: (context, url) =>
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
                                  fontSize: 13, fontWeight: FontWeight.bold),
                          onTap: () async {
                            customLog(
                              'tapped name: ${episode.title} - id: ${episode.stringID}',
                            );
                            scope.onTapEpisode(episode);
                          },
                          onLongPress: episode.sinopse?.isNotEmpty == true
                              ? () {
                                  showModalBottomSheet(
                                    isScrollControlled: false,
                                    isDismissible: true,
                                    showDragHandle: true,
                                    useRootNavigator: true,
                                    context: context,
                                    builder: (context) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12.0,
                                            ),
                                            child: Text(
                                              'Sinopse',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: Text(
                                              episode.sinopse!.trim(),
                                              textAlign: TextAlign.justify,
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
                          visualDensity:
                              const VisualDensity(vertical: 2, horizontal: -2),
                          title: Text(
                            '${episode.number}. ${episode.title}',
                          ),
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

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: mainAxisAlignment,
      children: children,
    );
  }
}

class _PlayerStatus with EquatableMixin {
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _buffer = Duration.zero;
  bool _completed = false;

  void setValue({
    bool? playing,
    Duration? position,
    Duration? duration,
    Duration? buffer,
    bool? completed,
  }) {
    _playing = playing ?? _playing;
    _position = position ?? _position;
    _duration = duration ?? _duration;
    _buffer = buffer ?? _buffer;
    _completed = completed ?? _completed;

    if (toHashCode(playing, position, duration, buffer, completed) !=
        hashCode) {
      customLog(toString());
    }
  }

  @override
  String toString() {
    return '_PlayerStatus(playing: $_playing, position: $_position, duration: $_duration, buffer: $_buffer, completed: $_completed)';
  }

  @override
  List<Object?> get props => [
        _playing,
        _position,
        _duration,
        _buffer,
        _completed,
      ];

  int toHashCode(
    bool? playing,
    Duration? position,
    Duration? duration,
    Duration? buffer,
    bool? completed,
  ) {
    return playing.hashCode ^
        position.hashCode ^
        duration.hashCode ^
        buffer.hashCode ^
        completed.hashCode;
  }
}

// class OpenMenuEpisodes extends ValueNotifier<bool> {
//   OpenMenuEpisodes(super.value);

//   void toogle(bool value) {
//     this.value = value;
//   }
// }
