import 'package:app_wsrb_jsr/app/ui/player/view/player_view.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

mixin PlayerControllerMixin on State<PlayerView> {
  late Player _player;

  Player get player => _player;

  bool isPlayerInitialized = false;

  void initPlayer(PlayerConfiguration configuration) {
    _player = Player(configuration: configuration);
    isPlayerInitialized = true;
  }

  bool get playing => isPlayerInitialized ? player.state.playing : false;

  bool get isFullscreen => PlayerView.videoStateKey.currentState?.isFullscreen() ?? false;

  bool get completed => isPlayerInitialized ? player.state.completed : false;

  Duration get position => isPlayerInitialized ? player.state.position : Duration.zero;
  Duration get duration => isPlayerInitialized ? player.state.duration : Duration.zero;

  double get videoPercent {
    if (duration.inMicroseconds > 0) {
      return (position.inMicroseconds / duration.inMicroseconds).clamp(0.0, 1.0);
    }
    return 0.0;
  }
}
