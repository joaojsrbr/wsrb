import 'dart:io';

import 'package:flutter/material.dart';
import 'package:slugify/slugify.dart';
import 'package:uuid/uuid.dart';

extension StringExtensions on String {
  String? get isEmptyOrNull {
    if (isNotEmpty) return trim();
    return null;
  }

  String get subRouter => replaceFirst('/', '');

  String get removerDiacriticos {
    final list = split('');

    list.removeWhere(
      (string) => string.contains(RegExp(r'/[\u0300-\u036F]/g')),
    );
    return list.reduce((value, element) => '$value$element');
  }

  String get toID => slugify(trim(), delimiter: '_');

  String get toUuID => const Uuid().v5(Uuid.NAMESPACE_URL, trim());

  Uri get toUri => Uri.parse(this);

  File get toFile => File(this);

  Directory get toDir => Directory(this);

  String get capitalize {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  Duration get parseDuration {
    int hours = 0;
    int minutes = 0;
    int micros;
    try {
      List<String> parts = split(':');
      if (parts.length > 2) {
        hours = int.parse(parts[parts.length - 3]);
      }
      if (parts.length > 1) {
        minutes = int.parse(parts[parts.length - 2]);
      }
      micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
      return Duration(hours: hours, minutes: minutes, microseconds: micros);
    } catch (_) {
      return Duration.zero;
    }
  }

  Color get fromHex {
    final buffer = StringBuffer();
    if (length == 6 || length == 7) buffer.write('ff');
    buffer.write(replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
