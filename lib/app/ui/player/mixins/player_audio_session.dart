import 'dart:async';

import 'player_audio_handler.dart';
import 'player_controller.dart';
import '../view/player_view.dart';
import '../../shared/mixins/subscriptions.dart';
import 'package:audio_session/audio_session.dart';
import 'package:content_library/content_library.dart';

mixin PlayerAudioSessionMixin
    on
        PlayerControllerMixin,
        SubscriptionsByStateArgumentMixin<PlayerView>,
        PlayerAudioHandlerMixin {
  @override
  void initState() {
    super.initState();
    scheduleMicrotask(_startAudioSession);
  }

  late final AudioSession _session;

  Future<void> _startAudioSession() async {
    _session = await AudioSession.instance;
    await _configureAudioSession();
    subscriptions.addAll([
      _session.interruptionEventStream.listen(_interruptionEventListener),
      _session.devicesChangedEventStream.listen(_devicesChangedListener),
    ]);
  }

  void _interruptionEventListener(AudioInterruptionEvent event) {
    customLog('${event.begin}[${event.type}]');
    if (event.begin) {
      switch (event.type) {
        case AudioInterruptionType.duck:
          break;
        case AudioInterruptionType.pause:
        case AudioInterruptionType.unknown:
          playerAudioHandler.pause();
          break;
      }
    } else {
      switch (event.type) {
        case AudioInterruptionType.duck:
          break;
        case AudioInterruptionType.pause:
        case AudioInterruptionType.unknown:
          break;
      }
    }
  }

  void _devicesChangedListener(AudioDevicesChangedEvent event) {
    customLog('[Devices added: ${event.devicesAdded}]_devicesChangedListener()');
    customLog('[Devices removed: ${event.devicesRemoved}]_devicesChangedListener()');
  }

  Future<void> _configureAudioSession() async {
    await _session.configure(const AudioSessionConfiguration.music());
  }

  Future<bool> setSessionActive(bool active) async {
    return _session.setActive(active);
  }
}
