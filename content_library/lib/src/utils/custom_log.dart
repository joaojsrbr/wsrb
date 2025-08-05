import 'dart:developer' as dev;

void customLog(Object? object, {Object? error, StackTrace? stackTrace, String? name}) {
  dev.log(
    object.toString(),
    time: DateTime.now(),
    error: error,
    name: name ?? 'WSRB_JSR',
    stackTrace: stackTrace,
  );
}
