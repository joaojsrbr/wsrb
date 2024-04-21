import 'dart:async';
import 'dart:collection';

import 'package:app_wsrb_jsr/app/ui/player/widgets/material_video_controls.dart';
import 'package:content_library/content_library.dart';

import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';

import 'package:app_wsrb_jsr/app/ui/player/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/list_dismissible.dart';
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
    with WidgetsBindingObserver {
  /// [PlayerArgs] object used as argument of this page.
  late PlayerArgs _playerArgs = argument();

  /// content repository [ContentRepository] instance.
  late final ContentRepository _repository;

  /// Create a [VideoController] to handle video output from [Player].
  VideoController? _videoController;

  /// Anime colors [ColorScheme] instance.
  ColorScheme? _contentColorScheme;

  /// [_mainVideoData] instance used to store video data.
  VideoData? _mainVideoData;

  Timer? _setEnabledSystemUIMode;

  /// Create a [Player] to control playback.
  Player? _player;

  /// variable used to load the page.
  bool _isLoading = true;

  /// variable using to store the initial [BoxFit].
  BoxFit _activeFit = BoxFit.contain;

  /// instance using to store all Subscriptions.
  final Subscriptions _subscriptions = Subscriptions();

  /// instance with single state used to store the [BoxFit] selected on the player button.
  final ValueNotifier<String?> _overlayBoxFit = ValueNotifier(null);

  /// instance with single state using to notify the user and activate the [_nextEpisode] method.
  final ValueNotifier<String?> _overlayNextEpisode = ValueNotifier(null);

  late final ValueNotifier<String> _topTitle = ValueNotifier('');

  /// Queue instance to store all [BoxFit].
  final Queue<BoxFit> _queueBoxFits = Queue<BoxFit>();

  /// Queue instance to store all [VideoData] instance.
  final List<VideoData> data = [];

  /// maximum [int] type variable responsible for controlling the [CircularProgressIndicator] animation.
  final int _maxValueCircularAnimation = 4;

  /// current [int] type variable responsible for controlling the [CircularProgressIndicator] animation.
  int _currentValueCircularAnimation = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _repository = context.read<ContentRepository>();
    BoxFit.values
        .where((fit) => !(fit == BoxFit.none || fit == _activeFit))
        .forEach(_queueBoxFits.add);

    addPostFrameCallback(_onInit);
  }

  Future<void> _incrementCurrentCircularAnimation() async {
    setStateIfMounted(() => _currentValueCircularAnimation++);
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   customLog('$runtimeType[$state]');
  //   switch (state) {
  //     case AppLifecycleState.resumed:
  //       break;
  //     case AppLifecycleState.detached:
  //       break;
  //     default:
  //   }

  //   super.didChangeAppLifecycleState(state);
  // }

  Future<void> _getInitMainVideoData() async {
    final state = Navigator.of(context);
    final result = await _repository.getContent(_playerArgs.episode);
    _topTitle.value = _playerArgs.episode.title;
    result.when(
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

  // Future<void> _getContentColorScheme() async {
  //   try {
  //     _contentColorScheme = (await ColorScheme.fromImageProvider(
  //       brightness: Theme.of(context).brightness,
  //       provider: CachedNetworkImageProvider(
  //         _playerArgs.anime.imageUrl,
  //         cacheKey: _playerArgs.anime.imageUrl,
  //         maxHeight: 330,
  //         maxWidth: 245,
  //       ),
  //     ))
  //         .harmonized();
  //   } catch (_) {}
  // }

  Future<void> _getAllEpisodesAndColorScheme() async {
    final result = await _repository
        .getData(_playerArgs.anime)
        .then((result) => result.when(onSucess: (data) => data as Anime));

    if (result != null) _playerArgs.anime = result;
  }

  void _onInit(Duration time) async {
    // VolumeOverlay.volumeOverlay(volumeDown: false, volumeUp: false);

    // _playerArgs = argument();

    await Future.delayed(const Duration(milliseconds: 200));

    await _getAllEpisodesAndColorScheme()
        .whenComplete(_incrementCurrentCircularAnimation);

    if (_playerArgs.capturedThemes == null) {
      // await _getContentColorScheme()
      //     .whenComplete(_incrementCurrentCircularAnimation);
    } else {
      await _incrementCurrentCircularAnimation();
    }

    await _getInitMainVideoData()
        .whenComplete(_incrementCurrentCircularAnimation);
    await _initPlayer(true).whenComplete(_incrementCurrentCircularAnimation);
    setStateIfMounted(() => _isLoading = false);
  }

  // bool get _playing => _player?.state.playing ?? false;

  bool get isFullscreen =>
      PlayerView.videoStateKey.currentState?.isFullscreen() ?? false;

  Future<void>? get toggleFullscreen =>
      PlayerView.videoStateKey.currentState?.toggleFullscreen();

  Future<void> _initPlayer([bool onInit = false]) async {
    if (onInit) {
      _player = Player(configuration: const PlayerConfiguration());
      _videoController = VideoController(_player!);
    }

    // if (_playing) {
    //   // await _player?.stop();
    // } else {
    //   _player = Player();
    //   _videoController = VideoController(_player!);
    // }

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
      ],
      _registerListeners(false),
      if (_videoController != null)
        _videoController!.waitUntilFirstFrameRendered,
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive)
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

    if (playing) {
      _setEnabledSystemUIMode = Timer(const Duration(milliseconds: 200), () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      });
    } else {
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
    final videoState = PlayerView.videoStateKey.currentState;
    if (videoState == null) return;

    final nextBoxFit = _queueBoxFits.removeFirst();
    _queueBoxFits.addLast(_activeFit);

    _overlayBoxFit.value = nextBoxFit.name;

    setStateIfMounted(() {
      _activeFit = nextBoxFit;
      PlayerView.videoStateKey.currentState?.update(fit: nextBoxFit);
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
      final indexOf =
          _playerArgs.anime.releases.indexOf(_playerArgs.episode) - 1;
      final nextEpisode = _playerArgs.anime.releases[indexOf];
      _overlayNextEpisode.value = '${nextEpisode.title} - ${diff.inSeconds}';
      customLog(_overlayNextEpisode.value);
    }
    // else if (_overlayNextEpisode.value != null) {
    //   _overlayNextEpisode.value = null;
    // }
  }

  ThemeData _themeData(BuildContext context) {
    Color? scaffoldBackgroundColor = _contentColorScheme?.background;

    scaffoldBackgroundColor ??= Theme.of(context).colorScheme.background;

    return Theme.of(context).copyWith(
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      colorScheme: _contentColorScheme,
    );
  }

  Future<void> _handleOnTapEpisodeInOverlay() async {
    _overlayNextEpisode.value = null;
    await _player?.pause();

    final indexOf = _playerArgs.anime.releases.indexOf(_playerArgs.episode);

    final nexEpisode = _playerArgs.anime.releases[indexOf - 1] as Episode;

    await _handleOnTapEpisode(nexEpisode);

    _overlayNextEpisode.value = null;
  }

  Future<void> _handleOnTapEpisode(Episode episode) async {
    customLog(
      'tapped name: ${episode.title} - id: ${episode.id}',
    );

    setState(
      () => _playerArgs = _playerArgs.copyWith(episode: episode),
    );

    await _getInitMainVideoData();
    await _initPlayer();
  }

  @override
  Widget buildByArgument(
    BuildContext context,
    PlayerArgs argument,
  ) {
    return PlayerScope(
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
      child: Theme(
        data: _themeData(context),
        child: const _BuildScaffold(),
      ),
    );
  }

  @override
  void dispose() {
    _topTitle.dispose();
    customLog('$runtimeType[dispose]');
    _subscriptions.cancellAll();
    _setEnabledSystemUIMode?.cancel();
    _videoController?.id.dispose();
    _videoController?.notifier.dispose();
    _videoController?.rect.dispose();
    _player?.dispose();
    _overlayBoxFit.dispose();
    _overlayNextEpisode.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // VolumeOverlay.volumeOverlay(volumeDown: true, volumeUp: true);
    super.dispose();
  }
}

class _BuildScaffold extends StatelessWidget {
  const _BuildScaffold();

  @override
  Widget build(BuildContext context) {
    final scope = PlayerScope.of(context);
    final isLoading = PlayerScope.isLoadingOf(context);
    final activeFit = PlayerScope.activeFitOf(context);
    final playerArgs = PlayerScope.playerArgsOf(context);
    final videoController = scope.videoController;
    final scaffoldKey = scope.scaffoldKey;
    final currentValueCircularAnimation =
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
          child: ListDismissible<Episode>(
            titleTextStyle: Theme.of(context).textTheme.labelLarge,
            releases: playerArgs.anime.releases,
            padding: const EdgeInsets.symmetric(vertical: 8),
            selected: (content) => content == playerArgs.episode,
            physics: const BouncingScrollPhysics(),
            onTap: scope.onTapEpisode,
          ),
        ),
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
