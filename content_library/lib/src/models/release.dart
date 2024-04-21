import 'package:equatable/equatable.dart';
import '../extensions/custom_extensions/string_extensions.dart';

abstract class Release extends Equatable implements Comparable<Release> {
  const Release({
    required this.url,
    required this.title,
  });

  final String url;

  final String title;

  StringID get id => StringID.fromURL(url);

  Map<String, dynamic> get toMap;

  String get number;

  @override
  int compareTo(other) => number.compareTo(other.number);
}
