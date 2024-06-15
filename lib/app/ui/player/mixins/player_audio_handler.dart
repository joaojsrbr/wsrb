import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_controller.dart';
import 'package:app_wsrb_jsr/app/ui/player/view/player_view.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';
import 'package:audio_service/audio_service.dart';
import 'package:media_kit/media_kit.dart';

mixin PlayerAudioHandlerMixin
    on
        PlayerControllerMixin,
        SubscriptionsByStateArgumentMixin<PlayerView, PlayerArgs> {
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

  Future<void> addMediaItem(MediaItem mediaItem) async {
    _playerAudioHandler.mediaItem.add(mediaItem);
    await _playerAudioHandler.playMediaItem(mediaItem);
  }

  @override
  void dispose() {
    _playerAudioHandler.setPlayerController = null;
    _playerAudioHandler.stop();
    super.dispose();
  }
}

abstract class PlayerAudioHandler extends BaseAudioHandler with SeekHandler {
  PlayerControllerMixin? _controller;

  Player? get _player => _controller?.player;

  set setPlayerController(PlayerControllerMixin? controller) {
    _controller = controller;
  }

  PlaybackState transformEvent(PlayerState event);
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
  PlaybackState transformEvent(PlayerState event) {
    return playbackState.value.copyWith.call(
      controls: [
        event.playing ? MediaControl.play : MediaControl.pause,
      ],
      systemActions: MediaAction.values.toSet(),
      processingState: AudioProcessingState.ready,
      playing: event.playing,
      updatePosition: event.position,
      bufferedPosition: event.buffer,
      speed: event.rate,
    );
  }
}
