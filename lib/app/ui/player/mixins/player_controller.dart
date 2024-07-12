import 'package:app_wsrb_jsr/app/ui/player/view/player_view.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

mixin PlayerControllerMixin on State<PlayerView> {
  Player? _player;

  Player? get player => _player;

  set setPlayer(Player player) {
    _player = player;
  }

  // @override
  // void dispose() {
  //   _player?.dispose();
  //   super.dispose();
  // }
}
