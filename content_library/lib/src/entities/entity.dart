// ignore_for_file: must_be_immutable

import 'package:content_library/content_library.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

abstract class Entity with EquatableMixin {
  Id id = Isar.autoIncrement;
}

abstract class ContentEntity extends Entity {
  @Index(replace: true, unique: true)
  final String stringID;
  final AniListMedia? anilistMedia;
  final bool isFavorite;
  ContentEntity({
    required this.stringID,
    this.anilistMedia,
    required this.isFavorite,
  });

  ContentEntity copyWith({
    AniListMedia? anilistMedia,
    bool? isFavorite,
  });
}

abstract class HistoryEntity extends Entity
    implements Comparable<HistoryEntity> {
  double get percent;
  bool get isComplete;
}
