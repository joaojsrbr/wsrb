import 'package:collection/collection.dart';
import 'package:content_library/src/entities/anime_skip_entity.dart';
import 'package:content_library/src/entities/anime_stamp_entity.dart';
import 'package:content_library/src/extensions/custom_extensions/string_extensions.dart';

class AnimeSkip extends AnimeSkipEntity {
  AnimeSkip({
    required String name,
    required String animeSkipId,
    required List<AnimeTimeStamp> times,
  }) {
    this.name = name;
    this.animeSkipId = animeSkipId;
    this.times = times;
  }

  static AnimeSkip fromMapApi(dynamic map) {
    final times = (map['episodes'] as List)
        .map((episode) => MapEntry(episode, episode['timestamps'] as List))
        .map(
          (entry) => entry.value.map(
            (obj) => AnimeTimeStamp.fromMap(entry.key, obj),
          ),
        )
        .flattened
        .toList();

    return AnimeSkip(
      name: map['name'],
      animeSkipId: map['id'],
      times: times,
    );
  }

  // AnimeSkipEntity toEntity() {
  //   final obj = AnimeSkipEntity();
  //   final times = this.times;

  //   obj.times = times;
  //   obj.name = name;
  //   obj.animeSkipId = animeSkipId;
  //   return obj;
  // }
  AnimeSkipEntity get toEntity => this;
}

class AnimeTimeStamp extends AnimeTimeStampEntity {
  AnimeTimeStamp({
    required String id,
    required String episodeId,
    required int at,
    required DateTime createdAt,
    required String updatedBy,
    required DateTime updatedAt,
    required String createdBy,
    AnimeTimeStampType? animeTimeStampType,
  }) {
    this.id = id;
    this.episodeId = episodeId;
    this.at = at;
    this.createdAt = createdAt;
    this.updatedBy = updatedBy;
    this.updatedAt = updatedAt;
    this.createdBy = createdBy;
    timeStampType = animeTimeStampType ?? AnimeTimeStampType.UNKNOWN;
  }

  factory AnimeTimeStamp.fromMap(
    dynamic episodeMap,
    dynamic map,
  ) {
    final timeStamp = AnimeTimeStampType.values.firstWhereOrNull((time) {
      return map['type']['name']
          .toString()
          .toID
          .toUpperCase()
          .contains(time.name.toUpperCase());
    });

    double timestampInSeconds = double.parse(map['at'].toString());

    return AnimeTimeStamp(
      id: map['id'],
      episodeId: episodeMap['id'],
      at: (timestampInSeconds * 1000000).toInt(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedBy: map['type']['updatedBy']['username'],
      updatedAt: DateTime.parse(map['updatedAt']),
      createdBy: map['type']['createdBy']['username'],
      animeTimeStampType: timeStamp ?? AnimeTimeStampType.UNKNOWN,
    );
  }

  AnimeTimeStampEntity get toEntity => this;

  // AnimeTimeStampEntity toEntity() {
  //   final obj = AnimeTimeStampEntity();

  //   obj.id = id;
  //   obj.episodeId = episodeId;
  //   obj.at = at;
  //   obj.createdAt = createdAt;
  //   obj.updatedBy = updatedBy;
  //   obj.updatedAt = updatedAt;
  //   obj.createdBy = createdBy;
  //   obj.timeStampType = timeStampType;
  //   return obj;
  // }
}
