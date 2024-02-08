import 'dart:async';
import 'dart:collection';

import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/list_extensions.dart';
import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/state_extensions.dart';
import 'package:app_wsrb_jsr/app/models/anime.dart';
import 'package:app_wsrb_jsr/app/models/data.dart';
import 'package:app_wsrb_jsr/app/repositories/content_repository.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/dismissible.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/player/widgets/player_custom_overlay.dart';
import 'package:app_wsrb_jsr/app/ui/player/widgets/player_theme.dart';
import 'package:app_wsrb_jsr/app/utils/custom_log.dart';
import 'package:app_wsrb_jsr/app/utils/custom_states.dart';
import 'package:app_wsrb_jsr/app/utils/subscriptions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends StateByArgument<PlayerView, PlayerArgs> {
  static final GlobalKey<VideoState> _videoStateKey = GlobalKey<VideoState>();

  late PlayerArgs _playerArgs;
  late final ContentRepository _repository;
  // Create a [VideoController] to handle video output from [Player].
  late VideoController _videoController;

  ColorScheme? _contentColorScheme;
  VideoData? _mainVideoData;
  Timer? _setEnabledSystemUIMode;
  // Create a [Player] to control playback.
  Player? _player;

  bool _isLoading = true;
  BoxFit _activeFit = BoxFit.contain;

  final Subscriptions _subscriptions = Subscriptions();
  final ValueNotifier<String?> _overlayBoxFit = ValueNotifier(null);
  final ValueNotifier<String?> _overlayNextEpisode = ValueNotifier(null);
  final Queue<BoxFit> _queueBoxFits = Queue<BoxFit>();
  final List<VideoData> data = [];

  @override
  void initState() {
    _repository = context.read<ContentRepository>();
    addPostFrameCallback(_onInit);
    super.initState();
  }

  Future<void> _getMainVideoData() async {
    final result = await _repository.getContent(_playerArgs.episode);

    result.when(
      onSucess: (data) {
        if (data is! List<VideoData>) Navigator.of(context).pop();

        setStateIfMounted(() {
          data.forEach(this.data.cast().addIfNoContains);
          _mainVideoData = this.data.first;
        });
      },
    );
  }

  Future<void> _getAllEpisodesAndColorScheme() async {
    await _repository.getData(_playerArgs.anime).then((result) {
      result.when(onSucess: (data) async {
        _playerArgs.anime = data as Anime;

        try {
          _contentColorScheme = await ColorScheme.fromImageProvider(
            brightness: Theme.of(context).brightness,
            provider: CachedNetworkImageProvider(
              _playerArgs.anime.imageUrl,
              cacheKey: _playerArgs.anime.imageUrl,
              maxHeight: 330,
              maxWidth: 245,
            ),
          );
        } catch (_) {}
      });
    });
  }

  void _onInit(Duration time) async {
    _playerArgs = argument();

    delayed() async {
      await _getAllEpisodesAndColorScheme();
      await _getMainVideoData();
      await _startPlayer();
    }

    BoxFit.values
        .where((fit) => !(fit == BoxFit.none || fit == _activeFit))
        .forEach(_queueBoxFits.add);

    await Future.delayed(const Duration(seconds: 1), delayed);
    setStateIfMounted(() => _isLoading = false);
  }

  bool get _playing => _player?.state.playing ?? false;
  bool get _isFullscreen =>
      _videoStateKey.currentState?.isFullscreen() ?? false;

  Future<void> _startPlayer() async {
    if (_playing) {
      await _player?.stop();
      // _videoController.id.dispose();
      // _videoController.notifier.dispose();
      // _videoController.rect.dispose();
      // await _player?.dispose();
      // await _registerListeners(true);
      // setState(() {
      //   _player = Player();
      //   _videoController = VideoController(_player!);
      // });
    } else {
      _player = Player();
      _videoController = VideoController(_player!);
    }

    await _player!.open(Media(
      _mainVideoData!.videoContent,
      httpHeaders: {
        "origin": _repository.source.BASE_URL,
        "referer": "${_repository.source.BASE_URL}/",
      },
    ));
    await _player!.setAudioDevice(AudioDevice.auto());
    await _player!.setVideoTrack(VideoTrack.auto());
    await _registerListeners(false);
    await _videoController.waitUntilFirstFrameRendered;
    // setState(() {});
  }

  Future<void> _registerListeners(bool clearListeners) async {
    if (clearListeners) {
      await _subscriptions.cancellAll(true);
    } else {
      _subscriptions.addAll([
        _player!.stream.playing.listen(_playingListener),
        _player!.stream.position.listen(_positionListener),
        // _player.stream..listen(_playingListener),
      ]);
    }
  }

  void _playingListener(bool playing) {
    _setEnabledSystemUIMode?.cancel();

    if (playing && !_isFullscreen) {
      _setEnabledSystemUIMode = Timer(const Duration(milliseconds: 200), () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      });
    } else if (!_isFullscreen) {
      _setEnabledSystemUIMode = Timer(const Duration(milliseconds: 300), () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      });
    }
  }

  void _positionListener(Duration position) {
    _nextEpisode(position);
  }

  void _handleSetFits() async {
    final videoState = _videoStateKey.currentState;
    if (videoState == null) return;

    final nextBoxFit = _queueBoxFits.removeFirst();
    _queueBoxFits.addLast(_activeFit);

    _overlayBoxFit.value = nextBoxFit.name;

    customLog(nextBoxFit);

    setState(() {
      _activeFit = nextBoxFit;
      _videoStateKey.currentState?.update(fit: nextBoxFit);
    });
  }

  bool get _hasNextEpisode {
    final indexOf = _playerArgs.anime.dataContents.reversed
        .toList()
        .indexOf(_playerArgs.episode);

    return !(_playerArgs.anime.dataContents.length - 1 == indexOf);
  }

  void _nextEpisode(Duration position) async {
    if (!_hasNextEpisode && _player == null) return;

    final maxPosition = _player!.state.duration;
    final activeOverlay = maxPosition - const Duration(seconds: 30);
    final diff = _player!.state.duration - position;

    if (position >= activeOverlay &&
        !diff.inSeconds.isNegative &&
        maxPosition.inSeconds > 0) {
      _overlayNextEpisode.value =
          '${_playerArgs.episode.title} - ${diff.inSeconds}';
      customLog(_overlayNextEpisode.value);
    } else if (_overlayNextEpisode.value != null) {
      _overlayNextEpisode.value = null;
    }
  }

  @override
  Widget buildByArgument(
    BuildContext context,
    PlayerArgs argument,
  ) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;
    return Theme(
      data: Theme.of(context).copyWith(colorScheme: _contentColorScheme),
      child: PlayerTheme(
        setFits: _handleSetFits,
        child: Scaffold(
          body: Column(
            mainAxisAlignment:
                _isLoading ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              if (_isLoading) ...[
                const Center(child: CircularProgressIndicator.adaptive()),
                const SizedBox(height: 12),
                Text(
                  'Carregando...',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ] else ...[
                SizedBox(
                  width: width,
                  height: height * .35,
                  child: Video(
                    aspectRatio: 16 / 9,
                    fit: _activeFit,
                    controls: _VideoControlls.new,
                    key: _videoStateKey,
                    controller: _videoController,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _playerArgs.anime.dataContents.length,
                    itemBuilder: (context, index) {
                      final episode = _playerArgs.anime.dataContents[index];
                      return CustomDismissible(
                        onUpdate: (details) {},
                        dismissThresholds: const {
                          DismissDirection.endToStart: 0.5,
                          DismissDirection.startToEnd: 0.5
                        },
                        resizeDuration: const Duration(milliseconds: 600),
                        background: Container(
                          alignment: Alignment.centerLeft,
                          decoration:
                              const BoxDecoration(color: Colors.blueAccent),
                          padding: const EdgeInsets.only(left: 20.0),
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                        radius: 20,
                        secondaryBackground: Container(
                          decoration:
                              const BoxDecoration(color: Colors.redAccent),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        key: ValueKey(episode.id),
                        onTap: episode == _playerArgs.episode
                            ? null
                            : () async {
                                customLog(
                                  'tapped name: ${episode.title} - id: ${episode.id}',
                                );

                                setState(() {
                                  _playerArgs = _playerArgs.copyWith(
                                    episode: episode,
                                  );
                                });

                                await _getMainVideoData();
                                await _startPlayer();
                              },
                        child: ListTile(
                          selected: episode == _playerArgs.episode,
                          titleTextStyle:
                              Theme.of(context).textTheme.labelLarge,
                          title: Text(episode.title),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscriptions.cancellAll();
    _videoController.id.dispose();
    _videoController.notifier.dispose();
    _videoController.rect.dispose();
    _player?.dispose();
    _overlayBoxFit.dispose();
    _overlayNextEpisode.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}

class _VideoControlls extends StatelessWidget {
  const _VideoControlls(this.state);

  final VideoState state;

  @override
  Widget build(BuildContext context) {
    final playerViewState = _PlayerViewState._videoStateKey.currentContext!
        .findRootAncestorStateOfType<_PlayerViewState>()!;
    final orientation = MediaQuery.orientationOf(context);
    final isPortrait = orientation == Orientation.portrait;
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: playerViewState._contentColorScheme,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: MaterialVideoControls(state),
          ),
          Padding(
            padding: EdgeInsets.only(top: !isPortrait ? 20 : 8),
            child: CustomOverlay(
              key: const ValueKey('custom_overlay_1'),
              begin: const Offset(-1, 0),
              notifierChange: playerViewState._overlayBoxFit,
            ),
          ),
          Positioned(
            bottom: !isPortrait ? 100 : 70,
            right: 0,
            top: 0,
            child: Align(
              alignment: Alignment.bottomRight,
              child: CustomOverlay(
                reversedBorder: true,
                key: const ValueKey('custom_overlay_2'),
                begin: const Offset(1, 0),
                end: Offset.zero,
                enableCancelReversed: false,
                notifierChange: playerViewState._overlayNextEpisode,
                onTap: () async {
                  final playerArgs = playerViewState._playerArgs;

                  final indexOf =
                      playerArgs.anime.dataContents.indexOf(playerArgs.episode);

                  final nexEpisode = playerArgs.anime.dataContents[indexOf - 1];

                  playerViewState._playerArgs = playerArgs.copyWith(
                    episode: nexEpisode,
                  );

                  await playerViewState._getMainVideoData();
                  await playerViewState._startPlayer();
                  playerViewState._overlayNextEpisode.value = null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
