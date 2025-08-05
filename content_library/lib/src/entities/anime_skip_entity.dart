// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'dart:convert';

import 'package:content_library/content_library.dart';
import 'package:isar/isar.dart';

part 'anime_skip_entity.g.dart';

@Collection(ignore: {'props', 'stringify', 'hashCode', 'toObj', 'toMap'})
class AnimeSkipEntity extends OtherEntity {
  final String name;
  @Index(replace: true, unique: true)
  final String animeSkipId;
  final String times;

  AnimeSkipEntity({required this.animeSkipId, required this.name, required this.times});

  @override
  List<Object?> get props => [name, animeSkipId, times];

  AnimeSkip toObj() {
    return AnimeSkip(
      name: name,
      animeSkipId: animeSkipId,
      times: times.isNotEmpty
          ? (jsonDecode(times) as List).map((e) => AnimeTimeStamp.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'id': id,
      'animeSkipId': animeSkipId,
      'times': jsonEncode(times),
    };
  }
}
