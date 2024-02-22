import 'dart:async';
import 'dart:collection';

import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/list_extensions.dart';
import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/state_extensions.dart';
import 'package:app_wsrb_jsr/app/models/anime.dart';
import 'package:app_wsrb_jsr/app/models/data.dart';
import 'package:app_wsrb_jsr/app/models/episode.dart';
import 'package:app_wsrb_jsr/app/repositories/content_repository.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/player/widgets/player_custom_overlay.dart';
import 'package:app_wsrb_jsr/app/ui/player/widgets/player_theme.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/list_dismissible.dart';
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

  static final GlobalKey<VideoState> _videoStateKey = GlobalKey<VideoState>();

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends StateByArgument<PlayerView, PlayerArgs> {
  late PlayerArgs _playerArgs;
  late final ContentRepository _repository;
  // Create a [VideoController] to handle video output from [Player].
  VideoController? _videoController;

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

  final int _maxCircularAnimation = 5;
  int _currentCircularAnimation = 1;

  @override
  void initState() {
    super.initState();
    _repository = context.read<ContentRepository>();
    BoxFit.values
        .where((fit) => !(fit == BoxFit.none || fit == _activeFit))
        .forEach(_queueBoxFits.add);
    addPostFrameCallback(_onInit);
  }

  Future<void> _incrementCurrentCircularAnimation() async {
    setStateIfMounted(() => _currentCircularAnimation++);
    await Future.delayed(const Duration(milliseconds: 150));
  }

  Future<void> _getInitMainVideoData() async {
    final result = await _repository.getContent(_playerArgs.episode);
    result.when(
      onSucess: (data) {
        if (data is! List<VideoData>) Navigator.of(context).pop();

        setStateIfMounted(() {
          _currentCircularAnimation++;
          data.forEach(this.data.cast().addIfNoContains);
          _mainVideoData = data.first as VideoData;
        });
      },
    );
  }

  // Future<VideoData?> _showBottomSheet() async {
  //   final result = showBottomSheet<VideoData>(
  //     context: context,
  //     builder: (context) {
  //       return GridView.builder(
  //         gridDelegate:
  //             SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 200),
  //         itemBuilder: (context, index) {
  //           return Text('data');
  //         },
  //       );
  //     },
  //   );

  //   return await result.closed;
  // }

  Future<void> _getContentColorScheme() async {
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
  }

  Future<void> _getAllEpisodesAndColorScheme() async {
    final result = await _repository
        .getData(_playerArgs.anime)
        .then((result) => result.when(onSucess: (data) => data as Anime));

    if (result != null) _playerArgs.anime = result;
  }

  void _onInit(Duration time) async {
    _playerArgs = argument();
    await Future.delayed(const Duration(milliseconds: 400));

    await _getAllEpisodesAndColorScheme()
        .whenComplete(_incrementCurrentCircularAnimation);
    await _getContentColorScheme()
        .whenComplete(_incrementCurrentCircularAnimation);
    await _getInitMainVideoData()
        .whenComplete(_incrementCurrentCircularAnimation);
    await _startPlayer().whenComplete(_incrementCurrentCircularAnimation);
    setStateIfMounted(() => _isLoading = false);
  }

  bool get _playing => _player?.state.playing ?? false;
  bool get _isFullscreen =>
      PlayerView._videoStateKey.currentState?.isFullscreen() ?? false;

  Future<void> _startPlayer() async {
    if (_playing) {
      await _player?.stop();
    } else {
      _player = Player();
      _videoController = VideoController(_player!);
    }

    await Future.wait([
      if (_player != null && _mainVideoData != null) ...[
        _player!.open(Media(
          _mainVideoData!.videoContent,
          httpHeaders: {
            "origin": _repository.source.BASE_URL,
            "referer": "${_repository.source.BASE_URL}/",
          },
        )),
        _player!.setAudioDevice(AudioDevice.auto()),
        _player!.setVideoTrack(VideoTrack.auto()),
      ],
      _registerListeners(false),
      if (_videoController != null)
        _videoController!.waitUntilFirstFrameRendered,
    ]);
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
    if (_player == null) return;
    if (_hasNextEpisode) _nextEpisode(position);
  }

  void _handleSetFits() async {
    final videoState = PlayerView._videoStateKey.currentState;
    if (videoState == null) return;

    final nextBoxFit = _queueBoxFits.removeFirst();
    _queueBoxFits.addLast(_activeFit);

    _overlayBoxFit.value = nextBoxFit.name;

    customLog(nextBoxFit);

    setState(() {
      _activeFit = nextBoxFit;
      PlayerView._videoStateKey.currentState?.update(fit: nextBoxFit);
    });
  }

  bool get _hasNextEpisode {
    return !(_playerArgs.anime.releases.reversed.last == _playerArgs.episode);
  }

  void _nextEpisode(Duration position) async {
    final maxPosition = _player!.state.duration;
    final activeOverlay = maxPosition - const Duration(seconds: 90);
    final diff = _player!.state.duration - position;

    if (position >= activeOverlay &&
        !diff.inSeconds.isNegative &&
        maxPosition.inSeconds > 0) {
      _overlayNextEpisode.value =
          '${_playerArgs.episode.title} - ${diff.inSeconds}';
      customLog(_overlayNextEpisode.value);
    }
    // else if (_overlayNextEpisode.value != null) {
    //   _overlayNextEpisode.value = null;
    // }
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
                Center(
                  child: TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween(
                      begin: 0.0,
                      end: _currentCircularAnimation / _maxCircularAnimation,
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
              ] else if (_videoController != null) ...[
                SizedBox(
                  width: width,
                  height: height * .35,
                  child: Video(
                    aspectRatio: 16 / 9,
                    fit: _activeFit,
                    controls: _VideoControlls.new,
                    key: PlayerView._videoStateKey,
                    controller: _videoController!,
                  ),
                ),
                Expanded(
                  child: ListDismissible<Episode>(
                    titleTextStyle: Theme.of(context).textTheme.labelLarge,
                    releases: _playerArgs.anime.releases,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    selected: (content) => content == _playerArgs.episode,
                    physics: const BouncingScrollPhysics(),
                    onTap: (episode) async {
                      customLog(
                        'tapped name: ${episode.title} - id: ${episode.id}',
                      );

                      setState(() {
                        _playerArgs = _playerArgs.copyWith(
                          episode: episode,
                        );
                      });

                      await _getInitMainVideoData();
                      await _startPlayer();
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
    _videoController?.id.dispose();
    _setEnabledSystemUIMode?.cancel();
    _videoController?.notifier.dispose();
    _videoController?.rect.dispose();
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
    final playerViewState = PlayerView._videoStateKey.currentContext!
        .findAncestorStateOfType<_PlayerViewState>();
    if (playerViewState == null) return const SizedBox.shrink();

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
                  playerViewState._overlayNextEpisode.value = null;
                  final playerArgs = playerViewState._playerArgs;

                  final indexOf =
                      playerArgs.anime.releases.indexOf(playerArgs.episode);

                  final nexEpisode = playerArgs.anime.releases[indexOf - 1];

                  playerViewState._playerArgs = playerArgs.copyWith(
                    episode: nexEpisode,
                  );

                  await playerViewState._getInitMainVideoData();
                  await playerViewState._startPlayer();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
