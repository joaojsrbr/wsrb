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
}

extension type const StringID._(String _) implements String {
  StringID.fromURL(String url) : _ = const Uuid().v5(Uuid.NAMESPACE_URL, url);
}

extension type const StringRouter(String _) implements String {
  String get subRouter => _.replaceFirst('/', '');
}
