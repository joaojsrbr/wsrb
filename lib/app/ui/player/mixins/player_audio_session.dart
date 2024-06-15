import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_controller.dart';
import 'package:app_wsrb_jsr/app/ui/player/view/player_view.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';
import 'package:audio_session/audio_session.dart';
import 'package:content_library/content_library.dart';

mixin PlayerAudioSessionMixin
    on
        PlayerControllerMixin,
        SubscriptionsByStateArgumentMixin<PlayerView, PlayerArgs> {
  @override
  void initState() {
    super.initState();
    scheduleMicrotask(_startAudioSession);
  }

  late final AudioSession _session;

  Future<void> _startAudioSession() async {
    _session = await AudioSession.instance;
    await _configureAudioSession();
    subscriptions.addAll(
      [
        _session.interruptionEventStream.listen(_interruptionEventListener),
        _session.devicesChangedEventStream.listen(_devicesChangedListener),
      ],
    );
  }

  void _interruptionEventListener(AudioInterruptionEvent event) {
    customLog('${event.begin}[${event.type}]');
    if (event.begin) {
      switch (event.type) {
        case AudioInterruptionType.duck:
          // Another app started playing audio and we should duck.
          break;
        case AudioInterruptionType.pause:
        case AudioInterruptionType.unknown:
          player?.pause();
          // Another app started playing audio and we should pause.
          break;
      }
    } else {
      switch (event.type) {
        case AudioInterruptionType.duck:
          // The interruption ended and we should unduck.
          break;
        case AudioInterruptionType.pause:
        // The interruption ended and we should resume.
        case AudioInterruptionType.unknown:
          // The interruption ended but we should not resume.
          break;
      }
    }
  }

  void _devicesChangedListener(AudioDevicesChangedEvent event) {
    customLog('Devices added:   ${event.devicesAdded}');
    customLog('Devices removed: ${event.devicesRemoved}');
  }

  Future<void> _configureAudioSession() async {
    await _session.configure(const AudioSessionConfiguration.music());
  }

  Future<bool> setSessionActive(bool active) async {
    return _session.setActive(active);
  }

  @override
  void dispose() {
    super.dispose();
    setSessionActive(false);
  }
}
