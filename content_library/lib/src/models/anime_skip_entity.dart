// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'dart:convert';

import 'package:content_library/content_library.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

part 'generated/anime_skip_entity.g.dart';
part 'generated/anime_skip_entity.mapper.dart';

@MappableClass()
@Embedded(ignore: {'props', 'stringify', 'hashCode', 'toObj', 'toMap'})
class AnimeSkipEntity with AnimeSkipEntityMappable, EquatableMixin {
  final String name;
  final String animeSkipId;
  final String times;

  AnimeSkipEntity({this.animeSkipId = "", this.name = "", this.times = ""});

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
}
