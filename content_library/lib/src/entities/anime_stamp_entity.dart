// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: constant_identifier_names

import 'package:content_library/src/models/anime_skip.dart';
import 'package:isar/isar.dart';

part 'anime_stamp_entity.g.dart';

@Embedded(
  ignore: {
    'props',
    'stringify',
    'hashCode',
    'duration',
    'toObj',
    'toMap',
  },
)
class AnimeTimeStampEntity {
  int at = 0;
  String id = "";
  String episodeId = "";
  String createdBy = "";
  String updatedBy = "";
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  @enumerated
  AnimeTimeStampType timeStampType = AnimeTimeStampType.UNKNOWN;

  Duration get duration => Duration(microseconds: at);

  AnimeTimeStamp get toObj {
    return AnimeTimeStamp(
      id: id,
      episodeId: episodeId,
      at: at,
      createdAt: createdAt,
      updatedBy: updatedBy,
      updatedAt: updatedAt,
      createdBy: createdBy,
      animeTimeStampType: timeStampType,
    );
  }

  Map<String, dynamic> get toMap {
    return <String, dynamic>{
      'at': at,
      'id': id,
      'episodeId': episodeId,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'timeStampType': timeStampType.index,
    };
  }

  static AnimeTimeStampEntity fromMap(Map<String, dynamic> map) {
    final obj = AnimeTimeStampEntity();

    obj.at = map['at'] as int;
    obj.id = map['id'] as String;
    obj.episodeId = map['episodeId'] as String;
    obj.createdBy = map['createdBy'] as String;
    obj.updatedBy = map['updatedBy'] as String;
    obj.timeStampType =
        AnimeTimeStampType.values.elementAt(map['timeStampType']);
    return obj;
  }
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
