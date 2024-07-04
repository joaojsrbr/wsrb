import 'dart:async';
import 'dart:collection';

import 'package:app_wsrb_jsr/app/ui/player/mixins/player_audio_handler.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_audio_session.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_controller.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';
import 'package:app_wsrb_jsr/app/ui/player/widgets/material_video_controls.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/player/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/utils/custom_states.dart';
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
        PlayerAudioHandlerMixin,
        PlayerAudioSessionMixin {
  late PlayerArgs _playerArgs = argument();

  late final ContentRepository _repository;

  VideoController? _videoController;

  VideoData? _mainVideoData;

  bool _isLoading = true;

  BoxFit _activeFit = BoxFit.contain;

  final ValueNotifier<String?> _overlayBoxFit = ValueNotifier(null);

  final ValueNotifier<String?> _overlayNextEpisode = ValueNotifier(null);

  late final ValueNotifier<String> _topTitle = ValueNotifier('');

  final Queue<BoxFit> _queueBoxFits = Queue<BoxFit>();

  final List<VideoData> data = [];

  final double _maxValueCircularAnimation = 1.5;

  double _currentValueCircularAnimation = 0;

  late final LibraryController _libraryController;

  late final HistoricController _historicController;

  final ValueNotifier<bool> _lockPlayer = ValueNotifier(false);

  final ValueNotifier<bool> _reversedCurrentDuration = ValueNotifier(false);

  final ValueNotifier<Duration?> _seekInVideoPosition = ValueNotifier(null);

  late final Timer _systemUIModeTimer;

  final Debouncer _removeAllListenersDebouncer = Debouncer(
    duration: const Duration(seconds: 20),
  );

  Duration _currentPositionDuration = Duration.zero;

  bool _playerDisposed = false;

  final Debouncer _saveDataDebouncer = Debouncer();

  Timer? _setEnabledSystemUIModeTimer;

  Timer? _setContinueVideoTimer;

  bool get _hasNextEpisode {
    return !(_playerArgs.anime.releases.last.stringID
        .contains(_playerArgs.episode.stringID));
  }

  bool get _playing => player?.state.playing ?? false;

  bool get isFullscreen =>
      PlayerView.videoStateKey.currentState?.isFullscreen() ?? false;

  double get _videoPercent {
    if (player != null) {
      final Duration position = player!.state.position;

      final Duration duration = player!.state.duration;

      return ((position.inMilliseconds / duration.inMilliseconds)).abs();
    }
    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

    _setEnabledSystemUIModeTimer?.cancel();

    if (_playing && !player!.state.completed) {
      _setEnabledSystemUIModeTimer =
          Timer(const Duration(milliseconds: 200), () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      });
    } else {
      _setEnabledSystemUIModeTimer =
          Timer(const Duration(milliseconds: 200), () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      });
    }
  }

  Future<void> _incrementCurrentCircularAnimation() async {
    setStateIfMounted(() => _currentValueCircularAnimation += 0.5);
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> _removeAllListeners() async {
    _playerDisposed = true;
    _saveDataDebouncer.cancel();
    _setEnabledSystemUIModeTimer?.cancel();
    _systemUIModeTimer.cancel();
    _removeAllListenersDebouncer.cancel();
    _setContinueVideoTimer?.cancel();
    playerAudioHandler.playbackState.add(playerAudioHandler.playbackState.value
        .copyWith(processingState: AudioProcessingState.idle));
    await setSessionActive(false);
    await playerAudioHandler.playbackState.firstWhere(
        (state) => state.processingState == AudioProcessingState.idle);
    await _registerListeners(true);
  }

  Future<void> _resumePlayerAfterRemoveAllListeners() async {
    await _registerListeners(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    customLog(state);

    switch (state) {
      case AppLifecycleState.hidden:
        _saveVideoData();
        _removeAllListenersDebouncer.cancel();
        _removeAllListenersDebouncer.call(_removeAllListeners);
      case AppLifecycleState.paused:
        _saveVideoData();
        _removeAllListenersDebouncer.cancel();
        _removeAllListenersDebouncer.call(_removeAllListeners);
      case AppLifecycleState.inactive:
      case AppLifecycleState.resumed:
        if (_playerDisposed) _resumePlayerAfterRemoveAllListeners();
      case AppLifecycleState.detached:
    }

    super.didChangeAppLifecycleState(state);
  }

  Future<void> _getInitMainVideoData() async {
    final state = Navigator.of(context);
    final result = await _repository.getContent(_playerArgs.episode);
    _topTitle.value = 'Episódio ${_playerArgs.episode.number}';
    result.fold(
      onSuccess: (data) {
        if (data.first is! VideoData) state.pop();

        setStateIfMounted(() {
          _currentValueCircularAnimation++;
          data.forEach(this.data.cast().addIfNoContains);
          _mainVideoData = data.first as VideoData;
        });
      },
      onError: state.pop,
    );
  }

  Future<void> _getAllEpisodes() async {
    Anime anime = _playerArgs.anime;
    if (_playerArgs.anime.releases.length == 1) {
      final result = await _repository
          .getData(_playerArgs.anime)
          .then((result) => result.fold(onSuccess: (data) => data as Anime));
      if (result != null) anime = result;
    }

    _playerArgs = _playerArgs.copyWith(
      anime: anime.copyWith(
        releases: (_playerArgs.anime.releases.length > anime.releases.length
            ? _playerArgs.anime.releases
            : null),
      ),
    );
    // _playerArgs.anime.releases.sort(
    //   (release1, release2) => release1.compareTo(release2),
    // );
  }

  void _onInit(Duration time) async {
    await _getAllEpisodes().whenComplete(_incrementCurrentCircularAnimation);
    await _getInitMainVideoData()
        .whenComplete(_incrementCurrentCircularAnimation);
    await _startPlayerController(true)
        .whenComplete(_incrementCurrentCircularAnimation);
    setStateIfMounted(() => _isLoading = false);

    if (player?.state.playing == true) {
      await _continueVideo();
    }
  }

  Future<void> _startPlayerController(
      [bool onInit = false, Duration? initPossition]) async {
    final playbackState = playerAudioHandler.playbackState;
    playerAudioHandler.setPlayerController = this;

    if (onInit) {
      setPlayer = Player(configuration: const PlayerConfiguration());
      _videoController = VideoController(player!);
    }

    List<Future> futures = [
      player!.open(Media(_mainVideoData!.videoContent,
          httpHeaders: _mainVideoData?.httpHeaders)),
      player!.setAudioDevice(AudioDevice.auto()),
      _registerListeners(false),
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive)
    ];

    await Future.wait(futures);

    await _videoController?.waitUntilFirstFrameRendered;

    if (initPossition != null) {
      await player!.seek(initPossition);
    }

    playbackState.add(playbackState.value.copyWith
        .call(processingState: AudioProcessingState.ready));
  }

  void _completedListener(bool completed) {
    if (completed) {
      _saveVideoData();
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

  void _bufferListener(Duration buffer) {}

  void _playingListener(bool playing) async {
    setSessionActive(playing);
  }

  void _durationListener(Duration duration) {
    if (duration != Duration.zero) setPlayerMedia(_playerArgs);
  }

  void _positionListener(Duration position) {
    _currentPositionDuration = position;
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

    customLog("[$_queueBoxFits]_handleSetFits()");

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

  Future<void> _continueVideo() async {
    final entity = _historicController.entities
        .firstWhereOrNull((entity) => switch (entity) {
              EpisodeEntity data =>
                data.stringID.contains(_playerArgs.episode.stringID) &&
                    data.animeStringID.contains(_playerArgs.anime.stringID),
              _ => false,
            }) as EpisodeEntity?;

    if (entity == null) return;

    customLog('[${entity.numberEpisode}]_continueVideo()');

    final videoPercent =
        ((entity.currentDuration / entity.episodeDuration)).abs();

    if (videoPercent < 0.20) return;

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
      _seekInVideoPosition.value =
          Duration(milliseconds: entity.currentDuration);
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
    await playerAudioHandler.stop();
    _seekInVideoPosition.value = null;
    _overlayNextEpisode.value = null;
    customLog('[${episode.title}]_handleOnTapEpisode()');

    await _saveVideoData();

    ifMounted(() async {
      setState(() => _playerArgs = _playerArgs.copyWith(episode: episode));

      await _getInitMainVideoData();
      await _startPlayerController();
      await _continueVideo();
    });
  }

  Future<void> _saveVideoData() async {
    _saveDataDebouncer.cancel();
    _saveDataDebouncer.call(() async {
      if (_videoPercent < 0.20) return;

      final Duration position = player!.state.position;

      final Duration duration = player!.state.duration;

      bool isComplete = _videoPercent >= 0.85;

      final EpisodeEntity episodeEntity = EpisodeEntity(
        currentDuration: position.inMilliseconds,
        animeStringID: _playerArgs.anime.stringID,
        episodeDuration: duration.inMilliseconds,
        stringID: _playerArgs.episode.stringID,
        isComplete: isComplete,
        sinopse: _playerArgs.episode.sinopse,
        numberEpisode: int.tryParse(_playerArgs.episode.number),
      );

      customLog('[${episodeEntity.numberEpisode}]_saveVideoData()');

      final animeEntity = _libraryController.entities.firstWhere(
        (content) {
          return content is AnimeEntity &&
              content.stringID.contains(_playerArgs.anime.stringID);
        },
        orElse: () => _playerArgs.anime.toEntity(),
      ) as AnimeEntity;

      animeEntity.episodes.add(episodeEntity);

      await _libraryController.add(contentEntity: animeEntity);

      await _historicController.add(historyEntity: episodeEntity);
    });
  }

  @override
  Widget buildByArgument(
    BuildContext context,
    PlayerArgs argument,
  ) {
    return PlayerScope(
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
      child: const _BuildScaffold(),
    );
  }

  @override
  void dispose() {
    customLog('$runtimeType[dispose]');
    _topTitle.dispose();
    _seekInVideoPosition.dispose();
    _lockPlayer.dispose();
    _reversedCurrentDuration.dispose();
    _overlayBoxFit.dispose();
    _saveDataDebouncer.cancel();
    _setEnabledSystemUIModeTimer?.cancel();
    _systemUIModeTimer.cancel();
    _removeAllListenersDebouncer.cancel();
    _setContinueVideoTimer?.cancel();
    _overlayNextEpisode.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (_mainVideoData != null) _saveVideoData();
    super.dispose();
  }
}

class _BuildScaffold extends StatelessWidget {
  const _BuildScaffold();

  @override
  Widget build(BuildContext context) {
    final PlayerScope scope = PlayerScope.of(context);
    final bool isLoading = PlayerScope.isLoadingOf(context);
    final BoxFit activeFit = PlayerScope.activeFitOf(context);
    final PlayerArgs playerArgs = PlayerScope.playerArgsOf(context);
    final VideoController? videoController = scope.videoController;
    final double currentValueCircularAnimation =
        PlayerScope.currentValueCircularAnimationOf(context);
    List<Widget> children = [];

    if (isLoading) {
      children.addAll([
        Center(
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 300),
            tween: Tween(
              begin: 0.0,
              end: (currentValueCircularAnimation /
                  scope.maxValueCircularAnimation),
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
      children.addAll([
        // Flexible(
        //   flex: 1,
        //   child: Video(
        //     aspectRatio: 16 / 9,
        //     onEnterFullscreen: () async {
        //       await SystemChrome.setPreferredOrientations([
        //         DeviceOrientation.landscapeLeft,
        //         DeviceOrientation.landscapeRight,
        //       ]);
        //       SystemChrome.setEnabledSystemUIMode(
        //         SystemUiMode.immersive,
        //       );
        //     },
        //     onExitFullscreen: () async {
        //       await SystemChrome.setPreferredOrientations(
        //         [DeviceOrientation.portraitUp],
        //       );
        //     },
        //     fit: activeFit,
        //     controls: CustomMaterialControls.new,
        //     key: PlayerView.videoStateKey,
        //     controller: videoController,
        //   ),
        // ),
        // Expanded(
        //   flex: 2,
        //   child: ListDismissible<Episode>(
        //     titleTextStyle: Theme.of(context).textTheme.labelLarge,
        //     releases: playerArgs.anime.releases,
        //     padding: const EdgeInsets.symmetric(vertical: 8),
        //     selected: (content) => content == playerArgs.episode,
        //     physics: const BouncingScrollPhysics(),
        //     onTap: scope.onTapEpisode,
        //   ),
        // ),
        Expanded(
          flex: 2,
          child: DraggableScrollableSheet(
            minChildSize: 0.8,
            initialChildSize: 1.0,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: Video(
                      aspectRatio: 16 / 9,
                      onEnterFullscreen: () async {
                        await SystemChrome.setPreferredOrientations([
                          DeviceOrientation.landscapeLeft,
                          DeviceOrientation.landscapeRight,
                        ]);
                        SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.immersive,
                        );
                      },
                      onExitFullscreen: () async {
                        await SystemChrome.setPreferredOrientations(
                          [DeviceOrientation.portraitUp],
                        );
                      },
                      fit: activeFit,
                      controls: CustomMaterialControls.new,
                      key: PlayerView.videoStateKey,
                      controller: videoController,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ListView.separated(
                      controller: scrollController,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 18, bottom: 18),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemCount: playerArgs.anime.releases.length,
                      itemBuilder: (context, index) {
                        final Episode episode =
                            playerArgs.anime.releases.reversed.elementAt(index);
                        final String? thumbnail = episode.thumbnail;

                        return ListTile(
                          selected: episode.stringID
                              .contains(playerArgs.episode.stringID),
                          leading: SizedBox(
                            width: 112,
                            height: double.infinity,
                            child: thumbnail != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: thumbnail,
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
                                                vertical: 12.0),
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
              );
            },
          ),
        ),
        // Expanded(
        //   flex: 2,

        // ),
      ]);
    }

    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center;

    if (!isLoading) mainAxisAlignment = MainAxisAlignment.start;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: mainAxisAlignment,
        children: children,
      ),
    );
  }
}
