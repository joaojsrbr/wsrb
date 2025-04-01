import 'package:content_library/content_library.dart';

class Elapsed {
  final _stopwatch = Stopwatch();

  void start() => _stopwatch.start();
  void reset() => _stopwatch.reset();
  void stop() => _stopwatch.stop();
  void printAndStop([String start = 'Timer']) {
    _stopwatch.stop();
    final requestDuration = _stopwatch.elapsed;
    customLog('$start[${_format(requestDuration)}]');
  }

  String _format(Duration d) =>
      d.toString().split('.').first.padLeft(8, "0").replaceFirst("00:", "");
}
