import 'package:flutter/material.dart';

extension ImageExtension on num {
  int cacheSize(BuildContext context) {
    return (this * MediaQuery.of(context).devicePixelRatio).round();
  }

  Duration get microsecondsToDuration {
    if (this case int data) return Duration(microseconds: data);

    return Duration.zero;
  }
}
