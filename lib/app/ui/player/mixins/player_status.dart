import 'package:equatable/equatable.dart';

import 'player_controller.dart';

mixin PlayerStatusMixin on PlayerControllerMixin {
  final PlayerStatus status = PlayerStatus();
}

class PlayerStatus extends Equatable {
  bool _playing;
  Duration _position;
  Duration _duration;
  Duration _buffer;
  bool _completed;

  PlayerStatus({
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
    _playing = playing ?? _playing;
    _position = position ?? _position;
    _duration = duration ?? _duration;
    _buffer = buffer ?? _buffer;
    _completed = completed ?? _completed;
    // final status = PlayerStatus(
    //   playing: playing ?? _playing,
    //   position: position ?? _position,
    //   duration: duration ?? _duration,
    //   buffer: buffer ?? _buffer,
    //   completed: completed ?? _completed,
    // );
    // if (_position.inMilliseconds != position?.inMilliseconds &&
    //     _position.inMilliseconds > 0) {
    //   customLog(toString());
    // }

    return this;
  }

  @override
  String toString() {
    return '_PlayerStatus(playing: $_playing, position: $_position, duration: $_duration, buffer: $_buffer, completed: $_completed)';
  }

  @override
  List<Object?> get props => [_playing, _position, _duration, _buffer, _completed];
}
