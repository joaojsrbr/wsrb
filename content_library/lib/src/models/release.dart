import 'package:dart_mappable/dart_mappable.dart';
import 'package:equatable/equatable.dart';

import '../extensions/custom_extensions/string_extensions.dart';

part 'generated/release.mapper.dart';

@MappableClass(discriminatorKey: 'type')
abstract class Release extends Equatable
    with ReleaseMappable
    implements Comparable<Release> {
  const Release({required this.url, required this.title, this.numberEpisode});

  final String url;
  final int? numberEpisode;

  final String title;

  String get stringID => url.toUuID;

  int get numberInt {
    return numberEpisode ??
        int.tryParse(
          numberEpisode?.toString() ?? title.replaceAll(RegExp(r'[^0-9]'), '').trim(),
        ) ??
        -1;
  }

  String getEpisodeTitle() {
    return 'Episódio $numberInt';
  }

  @override
  int compareTo(other) => numberInt.compareTo(other.numberInt);
}
