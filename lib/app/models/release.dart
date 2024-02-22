import 'package:equatable/equatable.dart';
import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/string_extensions.dart';

abstract class Release extends Equatable {
  const Release({
    required this.url,
    required this.title,
  });

  final String url;

  final String title;

  StringID get id => StringID.fromURL(url);

  Map<String, dynamic> get toMap;

  String get number;
}
