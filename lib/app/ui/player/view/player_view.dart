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

  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

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

  final int _maxValueCircularAnimation = 2;

  int _currentValueCircularAnimation = 0;

  late final LibraryController _libraryController;

  late final HistoricController _historicController;

  final ValueNotifier<bool> _lockPlayer = ValueNotifier(false);

  final ValueNotifier<bool> _reversedCurrentDuration = ValueNotifier(false);

  final ValueNotifier<Duration?> _seekInVideoPosition = ValueNotifier(null);

  late final Timer _systemUIModeTimer;

  Timer? _setEnabledSystemUIModeTimer;

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

    // final playing = player.state.playing;

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
    setStateIfMounted(() => _currentValueCircularAnimation++);
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    customLog(state);
    if ([AppLifecycleState.hidden, AppLifecycleState.paused].contains(state)) {
      _saveVideoData();
    }

    super.didChangeAppLifecycleState(state);
  }

  Future<void> _getInitMainVideoData() async {
    final state = Navigator.of(context);
    final result = await _repository.getContent(_playerArgs.episode);
    _topTitle.value = 'Episódio ${_playerArgs.episode.number}'.trim();
    result.fold(
      onSucess: (data) {
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
          .then((result) => result.fold(onSucess: (data) => data as Anime));
      if (result != null) anime = result;
    }

    _playerArgs = _playerArgs.copyWith(
      anime: anime.copyWith(
        releases: _playerArgs.anime.releases.length > anime.releases.length
            ? _playerArgs.anime.releases
            : null,
      ),
    );
    _playerArgs.anime.releases.sort(
      (release1, release2) => release1.compareTo(release2),
    );
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

  bool get _playing => player?.state.playing ?? false;

  bool get isFullscreen =>
      PlayerView.videoStateKey.currentState?.isFullscreen() ?? false;

  Future<void>? get toggleFullscreen =>
      PlayerView.videoStateKey.currentState?.toggleFullscreen();

  Future<void> _startPlayerController([bool onInit = false]) async {
    final playbackState = playerAudioHandler.playbackState;
    playerAudioHandler.playbackState.add(playbackState.value.copyWith.call(
      systemActions: {MediaAction.playPause, MediaAction.play},
      controls: [MediaControl.pause, MediaControl.play],
      processingState: AudioProcessingState.loading,
    ));

    if (onInit) {
      setPlayer = Player(configuration: const PlayerConfiguration());
      _videoController = VideoController(player!);
    }

    List<Future> futures = [
      _registerListeners(false),
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive)
    ];

    if (player != null && _mainVideoData != null) {
      futures.addAll([
        player!.open(Media(
          _mainVideoData!.videoContent,
          httpHeaders: _mainVideoData?.httpHeaders,
        )),
        player!.setAudioDevice(AudioDevice.auto()),
      ]);
    }

    await Future.wait(futures);

    playerAudioHandler.setPlayerController = this;

    await _videoController?.waitUntilFirstFrameRendered;

    Future.delayed(const Duration(seconds: 2), () async {
      if (player != null && _mainVideoData != null) {
        final item = MediaItem(
          displayTitle: _playerArgs.anime.title,
          id: _mainVideoData!.videoContent,
          title: _playerArgs.anime.title,
          duration: player!.state.duration,
          artUri: (_playerArgs.episode.thumbnail != null
              ? Uri.parse(_playerArgs.episode.thumbnail!)
              : null),
        );
        await addMediaItem(item);
      }
    });
    playerAudioHandler.playbackState.add(playbackState.value.copyWith.call(
      processingState: AudioProcessingState.ready,
    ));
  }

  void _completedListener(bool completed) {
    if (completed) {
      _saveVideoData();
      final playbackState = playerAudioHandler.playbackState;

      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
      ));
    }
  }

  Future<void> _registerListeners(bool clearListeners) async {
    if (clearListeners) {
      await subscriptions.cancelAll();
    } else {
      subscriptions.addAll([
        player!.stream.playing.listen(_playingListener),
        player!.stream.position.listen(_positionListener),
        player!.stream.buffer.listen(_bufferListener),
        player!.stream.completed.listen(_completedListener),
      ]);
    }
  }

  void _bufferListener(Duration buffer) {
    playerAudioHandler.playbackState.add(
      playerAudioHandler.transformEvent(player!.state),
    );
  }

  void _playingListener(bool playing) {
    // playerAudioHandler.playbackState.add(
    //   playerAudioHandler.transformEvent(player!.state),
    // );
    setActiveAudioService(playing);
  }

  void _positionListener(Duration position) {
    playerAudioHandler.playbackState.add(
      playerAudioHandler.transformEvent(player!.state),
    );

    if (_seekInVideoPosition.value != null) {
      player?.seek(_seekInVideoPosition.value!);
      _seekInVideoPosition.value = null;
    }
    if (player == null) return;
    if (_hasNextEpisode) _nextEpisode(position);
  }

  void _handleSetFits() async {
    final videoState = PlayerView.videoStateKey.currentState;
    if (videoState == null) return;

    final nextBoxFit = _queueBoxFits.removeFirst();
    _queueBoxFits.addLast(_activeFit);

    _overlayBoxFit.value = nextBoxFit.name;

    setStateIfMounted(() {
      _activeFit = nextBoxFit;
      videoState.update(fit: nextBoxFit);
    });
  }

  bool get _hasNextEpisode {
    return !(_playerArgs.anime.releases.last.stringID
        .contains(_playerArgs.episode.stringID));
  }

  void _nextEpisode(Duration position) async {
    final maxPosition = player!.state.duration;
    final activeOverlay = maxPosition - const Duration(seconds: 90);
    final diff = player!.state.duration - position;

    if (position >= activeOverlay &&
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

    customLog('_continueVideo[${entity.numberEpisode}]');

    final videoPercent =
        ((entity.currentDuration / entity.episodeDuration)).abs();

    if (!mounted || videoPercent < 0.20) return;

    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
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

    if (result == true) {
      _seekInVideoPosition.value =
          Duration(milliseconds: entity.currentDuration);
    }
  }

  Future<void> _handleOnTapEpisodeInOverlay() async {
    _overlayNextEpisode.value = null;
    await player?.pause();
    // await _player?.stop();

    final indexOf = _playerArgs.anime.releases.indexOf(_playerArgs.episode);

    final nexEpisode = _playerArgs.anime.releases[indexOf + 1];

    await _handleOnTapEpisode(nexEpisode);

    _overlayNextEpisode.value = null;
  }

  Future<void> _handleOnTapEpisode(Episode episode) async {
    if (episode.stringID.contains(_playerArgs.episode.stringID)) return;
    await player?.pause();
    _seekInVideoPosition.value = null;
    _overlayNextEpisode.value = null;
    customLog(
      'tapped title: ${episode.title} - id: ${episode.stringID}',
    );

    await _saveVideoData();

    setStateIfMounted(
      () => _playerArgs = _playerArgs.copyWith(episode: episode),
    );

    await _getInitMainVideoData();
    await _startPlayerController();
    await _continueVideo();
  }

  double get _videoPercent {
    if (player != null) {
      final Duration position = player!.state.position;

      final Duration duration = player!.state.duration;

      return ((position.inMilliseconds / duration.inMilliseconds)).abs();
    }
    return 0.0;
  }

  Future<void> _saveVideoData() async {
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

    customLog('save-episode[${episodeEntity.numberEpisode}]');

    final animeEntity = _libraryController.entities.firstWhere(
      (content) {
        return content is AnimeEntity &&
            content.stringID.contains(_playerArgs.anime.stringID);
      },
      orElse: () => _playerArgs.anime.toEntity(),
    ) as AnimeEntity;

    animeEntity.episodes.add(episodeEntity);
    await _libraryController.add(contentEntity: animeEntity);

    // if (!_libraryController.contains(contentEntity: animeEntity)) {
    // }
    await _historicController.add(historyEntity: episodeEntity);
  }

  @override
  Widget buildByArgument(
    BuildContext context,
    PlayerArgs argument,
  ) {
    return PlayerScope(
      lockPlayer: _lockPlayer,
      reversedCurrentDuration: _reversedCurrentDuration,
      scaffoldKey: PlayerView.scaffoldKey,
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
    if (_mainVideoData != null) _saveVideoData();
    _topTitle.dispose();
    customLog('$runtimeType[dispose]');
    _setEnabledSystemUIModeTimer?.cancel();
    _systemUIModeTimer.cancel();
    _seekInVideoPosition.dispose();
    _lockPlayer.dispose();
    _reversedCurrentDuration.dispose();
    _overlayBoxFit.dispose();
    _overlayNextEpisode.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
    final GlobalKey<ScaffoldState> scaffoldKey = scope.scaffoldKey;
    final int currentValueCircularAnimation =
        PlayerScope.currentValueCircularAnimationOf(context);
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
            initialChildSize: 0.8,
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
      key: scaffoldKey,
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
