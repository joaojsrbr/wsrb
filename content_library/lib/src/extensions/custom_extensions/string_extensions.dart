import 'dart:io';

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

  String get toID => trim().toLowerCase().replaceAll(' ', '_');

  String get toUuID => const Uuid().v5(Uuid.NAMESPACE_URL, trim());

  Uri get toUri => Uri.parse(this);

  File get toFile => File(this);

  Directory get toDir => Directory(this);

  String get capitalize {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
