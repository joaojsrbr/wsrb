import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_controller.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_pip.dart';
import 'package:app_wsrb_jsr/app/ui/player/view/player_view.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';
import 'package:audio_service/audio_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:simple_pip_mode/actions/pip_action.dart';
import 'package:simple_pip_mode/simple_pip.dart';

mixin PlayerAudioHandlerMixin
    on
        PlayerControllerMixin,
        SubscriptionsByStateArgumentMixin<PlayerView, PlayerArgs>,
        PlayerSimplePip {
  static late final PlayerAudioHandler _playerAudioHandler;

  PlayerAudioHandler get playerAudioHandler => _playerAudioHandler;

  static Future<void> startPlayerAudio() async {
    _playerAudioHandler = await AudioService.init(
      builder: () => _AudioPlayerHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
      ),
    );
  }

  void setPlayerMedia(PlayerArgs playerArgs) async {
    final mediaItem =
        await _playerAudioHandler.getMediaItem(playerArgs.episode.stringID);
    // customLog("[${player!.state.duration}]setPlayerMedia()");
    if (mediaItem == null) {
      final mediaItem = MediaItem(
        displayTitle: playerArgs.anime.title,
        id: playerArgs.episode.stringID,
        title: playerArgs.anime.title,
        duration: player!.state.duration,
        artUri: (playerArgs.episode.thumbnail != null
            ? Uri.parse(playerArgs.episode.thumbnail!)
            : null),
      );
      _playerAudioHandler.mediaItem.add(mediaItem);
      await _playerAudioHandler.playMediaItem(mediaItem);
    }
  }

  @override
  void onPipAction(PipAction pipAction) {
    switch (pipAction) {
      case PipAction.play:
        playerAudioHandler.play();
      case PipAction.pause:
        playerAudioHandler.pause();
      case PipAction.previous:
      case PipAction.next:
      case PipAction.live:
      case PipAction.none:
    }
  }

  @override
  void onPipState(PipState pipState) {
    switch (pipState) {
      case PipState.pipEntered:
      case PipState.pipExited:
      case PipState.none:
    }
  }

  @override
  void dispose() {
    _playerAudioHandler.setPlayerController = null;
    _playerAudioHandler.stop();
    super.dispose();
  }
}

abstract class PlayerAudioHandler extends BaseAudioHandler with SeekHandler {
  PlayerAudioHandlerMixin? _controller;

  Player? get _player => _controller?.player;

  set setPlayerController(PlayerAudioHandlerMixin? controller) {
    _controller = controller;
  }

  void setPlaybackState(PlayerState state);
}

class _AudioPlayerHandler extends PlayerAudioHandler {
  @override
  Future<void> pause() async => await _player?.pause();

  @override
  Future<void> stop() async {
    await _player?.stop();
    await super.stop();
  }

  @override
  Future<void> play() async => await _player?.play();

  @override
  Future<void> seek(Duration position) async => await _player?.seek(position);

  @override
  void setPlaybackState(PlayerState state) {
    playbackState.add(playbackState.value.copyWith.call(
      controls: [state.playing ? MediaControl.play : MediaControl.pause],
      systemActions: MediaAction.values.toSet(),
      processingState: AudioProcessingState.ready,
      playing: state.playing,
      updatePosition: state.position,
      bufferedPosition: state.buffer,
      speed: state.rate,
    ));
  }
}
