import 'package:equatable/equatable.dart';
import '../extensions/custom_extensions/string_extensions.dart';
import '../utils/releases.dart';

abstract class Content extends Equatable {
  String get imageUrl;

  StringID get id => StringID.fromURL(title);

  final String url;

  final String? sinopse;

  final Releases releases;

  final String title;

  const Content({
    required this.url,
    this.sinopse,
    required this.releases,
    required this.title,
  });

  Content copyWith({
    String? title,
    String? sinopse,
    String? url,
    Releases? releases,
  });

  Map<String, dynamic> get toMap;
}
