// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: must_be_immutable, constant_identifier_names

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:content_library/src/entities/anime_skip_entity.dart';
import 'package:content_library/src/extensions/custom_extensions/string_extensions.dart';

class AnimeSkip {
  final String name;
  final String animeSkipId;
  final List<AnimeTimeStamp> times;
  const AnimeSkip({
    required this.name,
    required this.animeSkipId,
    this.times = const [],
  });

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

  Map<String, dynamic> get toMap {
    return <String, dynamic>{
      'name': name,
      'animeSkipId': animeSkipId,
      'times': times.map((e) => e.toMap).toList(),
    };
  }

  static AnimeSkip fromMap(Map<String, dynamic> map) {
    return AnimeSkip(
      name: map['name'] as String,
      animeSkipId: map['animeSkipId'] as String,
      times: (map['times'] as List)
          .map((e) => AnimeTimeStamp.fromMap(e, map))
          .toList(),
    );
  }

  AnimeSkipEntity get toEntity {
    final obj = AnimeSkipEntity(
      animeSkipId: animeSkipId,
      name: name,
      times: jsonEncode(
        times.map((skip) => skip.toMap).toList(),
      ),
    );

    return obj;
  }
}

class AnimeTimeStamp {
  int at = 0;
  String id = "";
  String episodeId = "";
  String createdBy = "";
  int absoluteNumber = 0;
  String updatedBy = "";
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  AnimeTimeStampType timeStampType = AnimeTimeStampType.UNKNOWN;

  Duration get duration => Duration(microseconds: at);

  AnimeTimeStamp({
    required this.id,
    required this.episodeId,
    required this.at,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    required this.absoluteNumber,
    required this.createdBy,
    this.timeStampType = AnimeTimeStampType.UNKNOWN,
  });

  factory AnimeTimeStamp.fromMap(
    dynamic episodeMap,
    dynamic map,
  ) {
    final timeStamp = episodeMap['animeTimeStampType'] != null
        ? AnimeTimeStampType.values.elementAt(episodeMap['animeTimeStampType'])
        : AnimeTimeStampType.values.firstWhereOrNull((time) {
            return map['type']['name']
                .toString()
                .toID
                .toUpperCase()
                .contains(time.name.toUpperCase());
          });

    return AnimeTimeStamp(
      absoluteNumber: int.tryParse(((episodeMap['absoluteNumber'] ??
                  map['episode']['absoluteNumber'] ??
                  map['episode']['number']))
              .toString()) ??
          0,
      id: map['id'] ?? episodeMap['episodeId'],
      episodeId: episodeMap['episodeId'] ?? episodeMap['id'],
      at: episodeMap['at'] ??
          (double.parse(map['at'].toString()) * 1000000).toInt(),
      createdAt: DateTime.parse(episodeMap['createdAt'] ?? map['createdAt']),
      updatedBy:
          episodeMap['updatedBy'] ?? map['type']['updatedBy']['username'],
      updatedAt: DateTime.parse(episodeMap['updatedAt'] ?? map['updatedAt']),
      createdBy:
          episodeMap['createdBy'] ?? map['type']['createdBy']['username'],
      timeStampType: timeStamp ?? AnimeTimeStampType.UNKNOWN,
    );
  }

  factory AnimeTimeStamp._fromMap2(
    dynamic map,
  ) {
    return AnimeTimeStamp(
      absoluteNumber: map['absoluteNumber'],
      id: map['id'],
      episodeId: map['episodeId'],
      at: map['at'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedBy: map['updatedBy'],
      updatedAt: DateTime.parse(map['updatedAt']),
      createdBy: map['createdBy'],
      timeStampType:
          AnimeTimeStampType.values.elementAt(map['animeTimeStampType']),
    );
  }

  Duration get atDuration => Duration(microseconds: at);

  AnimeTimeStamp copyWith(
    String? id,
    String? episodeId,
    int? at,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
    int? absoluteNumber,
    String? createdBy,
    AnimeTimeStampType? animeTimeStampType,
  ) {
    return AnimeTimeStamp(
      absoluteNumber: absoluteNumber ?? this.absoluteNumber,
      id: id ?? this.id,
      episodeId: episodeId ?? this.episodeId,
      at: at ?? this.at,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      timeStampType: animeTimeStampType ?? AnimeTimeStampType.UNKNOWN,
    );
  }

  Map<String, dynamic> get toMap {
    return <String, dynamic>{
      'at': atDuration.inMicroseconds,
      'id': id,
      'episodeId': episodeId,
      'createdBy': createdBy,
      'absoluteNumber': absoluteNumber,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'animeTimeStampType': timeStampType.index,
    };
  }

  factory AnimeTimeStamp.fromJson(source) => AnimeTimeStamp._fromMap2(source);
}

enum AnimeTimeStampType {
  CREDITS("Créditos"),
  TITLE_CARD("Cartão De Título"),
  CANON("Cânone"),
  PREVIEW("Pré-visualização"),
  INTRO("Abertura"),
  NEW_INTRO("Nova Abertura"),
  RECAP("Recapitulação"),
  BRANDING("Marca"),
  UNKNOWN("Desconhecido"),
  MIXED_CREDITS("Créditos Mistos");

  const AnimeTimeStampType(this.label);

  final String label;
}
