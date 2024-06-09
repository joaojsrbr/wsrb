import 'package:equatable/equatable.dart';
import '../extensions/custom_extensions/string_extensions.dart';

abstract class Release extends Equatable implements Comparable<Release> {
  const Release({
    required this.url,
    required this.title,
  });

  final String url;

  final String title;

  String get stringID => url.toUuID;

  String get number;

  @override
  int compareTo(other) => int.parse(number).compareTo(int.parse(other.number));
}
