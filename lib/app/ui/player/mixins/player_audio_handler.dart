import 'dart:async';

import 'package:android_pip/actions/pip_action.dart';
import 'package:android_pip/android_pip.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_controller.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_pip.dart';
import 'package:app_wsrb_jsr/app/ui/player/view/player_view.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';
import 'package:audio_service/audio_service.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

mixin PlayerAudioHandlerMixin
    on
        PlayerControllerMixin,
        SubscriptionsByStateArgumentMixin<PlayerView, PlayerArgs>,
        PlayerPipMixin {
  static late final PlayerAudioHandler _playerAudioHandler;

  PlayerAudioHandler get playerAudioHandler => _playerAudioHandler;

  static Future<void> startPlayerAudio() async {
    _playerAudioHandler = await AudioService.init(
      builder: () => _AudioPlayerHandler(),
      config: const AudioServiceConfig(),
    );
  }

  @override
  void initState() {
    super.initState();
    playerAudioHandler._state = this;
  }

  void setPlayerMedia(PlayerArgs playerArgs) async {
    final mediaItem = await _playerAudioHandler.getMediaItem(playerArgs.episode.stringID);
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
    customLog("onPipAction[$pipAction]");

    switch (pipAction) {
      case PipAction.play:
        playerAudioHandler.play();
      case PipAction.pause:
        playerAudioHandler.pause();
      case PipAction.previous:
      case PipAction.next:
      case PipAction.live:
      case PipAction.rewind:
      case PipAction.forward:
    }
  }

  void handleEnterInPip() async {
    // if (draggableScrollableController.isAttached) {
    //   await draggableScrollableController.animateTo(
    //     1.0,
    //     duration: const Duration(milliseconds: 250),
    //     curve: Curves.ease,
    //   );
    // }

    setState(() => isPipActivated = true);
    WidgetsBinding.instance.addPostFrameCallback((timer) {
      AndroidPIP().enterPipMode(seamlessResize: true);
    });
  }

  @override
  void onPipChange() async {
    isPipActivated = await AndroidPIP.isPipActivated;
    setState(() {});
    // customLog("PipState[$pipState]");
    // this.pipState = pipState;
    // switch (pipState) {
    //   case PipState.pipEntered:
    //   case PipState.pipExited:
    //   case PipState.none:
    // }
  }
}

abstract class PlayerAudioHandler extends BaseAudioHandler with SeekHandler {
  PlayerControllerMixin? _state;

  void setPlaybackState(PlayerState state);
}

class _AudioPlayerHandler extends PlayerAudioHandler {
  @override
  Future<void> pause() async => await _state?.player?.pause();

  @override
  Future<void> play() async => await _state?.player?.play();

  @override
  Future<void> seek(Duration position) async => await _state?.player?.seek(position);

  @override
  void setPlaybackState(PlayerState state) {
    playbackState.add(
      playbackState.value.copyWith.call(
        controls: [state.playing ? MediaControl.play : MediaControl.pause],
        systemActions: MediaAction.values.toSet(),
        processingState: AudioProcessingState.ready,
        playing: state.playing,
        updatePosition: state.position,
        bufferedPosition: state.buffer,
        speed: state.rate,
      ),
    );
  }
}
