import 'package:app_wsrb_jsr/app/ui/player/mixins/player_controller.dart';
import 'package:equatable/equatable.dart';

mixin PlayerStatusMixin on PlayerControllerMixin {
  final PlayerStatus status = PlayerStatus();
}

class PlayerStatus with EquatableMixin {
  final bool _playing;
  final Duration _position;
  final Duration _duration;
  final Duration _buffer;
  final bool _completed;

  const PlayerStatus({
    bool playing = false,
    Duration position = Duration.zero,
    Duration duration = Duration.zero,
    Duration buffer = Duration.zero,
    bool completed = false,
  }) : _playing = playing,
       _position = position,
       _duration = duration,
       _buffer = buffer,
       _completed = completed;

  PlayerStatus setValue({
    bool? playing,
    Duration? position,
    Duration? duration,
    Duration? buffer,
    bool? completed,
  }) {
    final status = PlayerStatus(
      playing: playing ?? _playing,
      position: position ?? _position,
      duration: duration ?? _duration,
      buffer: buffer ?? _buffer,
      completed: completed ?? _completed,
    );
    // if (_position.inMilliseconds != position?.inMilliseconds &&
    //     _position.inMilliseconds > 0) {
    //   customLog(toString());
    // }

    return status;
  }

  @override
  String toString() {
    return '_PlayerStatus(playing: $_playing, position: $_position, duration: $_duration, buffer: $_buffer, completed: $_completed)';
  }

  @override
  List<Object?> get props => [_playing, _position, _duration, _buffer, _completed];
}
