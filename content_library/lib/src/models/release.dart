import 'package:equatable/equatable.dart';

import '../extensions/custom_extensions/string_extensions.dart';

abstract class Release extends Equatable implements Comparable<Release> {
  const Release({required this.url, required this.title, this.numberEpisode});

  final String url;
  final int? numberEpisode;

  final String title;

  String get stringID => url.toUuID;

  int get numberInt => int.parse(
    numberEpisode?.toString() ?? title.replaceAll(RegExp(r'[^0-9]'), '').trim(),
  );

  String getEpisodeTitle() {
    return 'Episódio $numberInt';
  }

  @override
  int compareTo(other) => numberInt.compareTo(other.numberInt);
}
