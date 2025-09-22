import 'dart:async';

import 'package:android_pip/actions/pip_action.dart';
import 'package:android_pip/android_pip.dart';
import '../arguments/player_args.dart';
import 'player_controller.dart';
import 'player_pip.dart';
import '../view/player_view.dart';
import '../../shared/mixins/subscriptions.dart';
import 'package:audio_service/audio_service.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

/// 🔊 Mixin responsável por integrar o [AudioService] com o player e PIP
mixin PlayerAudioHandlerMixin
    on
        PlayerControllerMixin,
        SubscriptionsByStateArgumentMixin<PlayerView>,
        PlayerPipMixin {
  static PlayerAudioHandler? _playerAudioHandler;

  PlayerAudioHandler get playerAudioHandler {
    final handler = _playerAudioHandler;
    if (handler == null) {
      throw StateError("PlayerAudioHandler ainda não foi inicializado.");
    }
    return handler;
  }

  /// Inicializa o [AudioService] apenas uma vez.
  static Future<void> startPlayerAudio() async {
    if (_playerAudioHandler != null) return;
    _playerAudioHandler = await AudioService.init(
      builder: () => _AudioPlayerHandler(),
      config: const AudioServiceConfig(),
    );
  }

  @override
  void initState() {
    super.initState();
    playerAudioHandler.attach(this);
  }

  @override
  void dispose() {
    playerAudioHandler.detach();
    super.dispose();
  }

  /// Define o [MediaItem] para o player atual.
  Future<void> setPlayerMedia(PlayerArgs playerArgs) async {
    final mediaItem = await _playerAudioHandler?.getMediaItem(
      playerArgs.episode.stringID,
    );

    if (mediaItem != null) return;

    final newMediaItem = MediaItem(
      id: playerArgs.episode.stringID,
      title: playerArgs.anime.title,
      displayTitle: playerArgs.anime.title,
      duration: player.state.duration,
      artUri: playerArgs.episode.thumbnail != null
          ? Uri.parse(playerArgs.episode.thumbnail!)
          : null,
    );

    _playerAudioHandler?.mediaItem.add(newMediaItem);
    await _playerAudioHandler?.playMediaItem(newMediaItem);
  }

  /// Controle das ações vindas do modo PIP
  @override
  void onPipAction(PipAction pipAction) {
    customLog("onPipAction[$pipAction]");

    switch (pipAction) {
      case PipAction.play:
        playerAudioHandler.play();
        break;
      case PipAction.pause:
        playerAudioHandler.pause();
        break;
      case PipAction.previous:
      case PipAction.next:
      case PipAction.live:
      case PipAction.rewind:
      case PipAction.forward:
        // Pode implementar futuramente
        break;
    }
  }

  /// Entrar no modo PIP
  Future<void> handleEnterInPip() async {
    setState(() => isPipActivated = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AndroidPIP().enterPipMode(seamlessResize: true);
    });
  }

  /// Atualizar estado do PIP
  @override
  Future<void> onPipChange() async {
    isPipActivated = await AndroidPIP.isPipActivated;
    if (mounted) setState(() {});
  }
}

/// Abstração para integração entre o [AudioService] e o [PlayerControllerMixin].
abstract class PlayerAudioHandler extends BaseAudioHandler with SeekHandler {
  PlayerControllerMixin? _state;

  void attach(PlayerControllerMixin state) => _state = state;
  void detach() => _state = null;

  void setPlaybackState(PlayerState state);
}

/// Implementação concreta do [PlayerAudioHandler].
class _AudioPlayerHandler extends PlayerAudioHandler {
  @override
  Future<void> pause() async => _state?.player.pause();

  @override
  Future<void> play() async => _state?.player.play();

  @override
  Future<void> seek(Duration position) async => _state?.player.seek(position);

  @override
  void setPlaybackState(PlayerState state) {
    final control = state.playing ? MediaControl.pause : MediaControl.play;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [control],
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
