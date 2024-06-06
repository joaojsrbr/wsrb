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

  String get toID => trim().replaceAll(' ', '_');

  String get toUuID => const Uuid().v5(Uuid.NAMESPACE_URL, trim());
}
