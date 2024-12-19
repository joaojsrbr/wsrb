// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:content_library/content_library.dart';
import 'package:isar/isar.dart';

part 'anime_skip_entity.g.dart';

@Collection(
  ignore: {
    'props',
    'stringify',
    'hashCode',
    'toObj',
    'toMap',
  },
)
class AnimeSkipEntity extends Entity {
  String name = "";
  String animeSkipId = "";
  List<AnimeTimeStampEntity> times = [];

  @override
  List<Object?> get props => [name, animeSkipId, times];

  AnimeSkip get toObj {
    return AnimeSkip(
      name: name,
      animeSkipId: animeSkipId,
      times: times.map((e) => e.toObj).toList(),
    );
  }

  Map<String, dynamic> get toMap {
    return <String, dynamic>{
      'name': name,
      'id': id,
      'animeSkipId': animeSkipId,
      'times': times.map((x) => x.toMap).toList(),
    };
  }

  static AnimeSkipEntity fromMap(Map<String, dynamic> map) {
    final obj = AnimeSkipEntity();

    obj.name = map['name'] as String;
    obj.animeSkipId = map['animeSkipId'] as String;
    obj.times = (map['times'] as List)
        .map((e) => AnimeTimeStampEntity.fromMap(e))
        .toList();

    return obj;
  }
}
