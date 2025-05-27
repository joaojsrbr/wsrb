// ignore_for_file: must_be_immutable

import 'package:content_library/content_library.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show Colors, Color, ColorScheme;
import 'package:isar/isar.dart';

sealed class Entity with EquatableMixin {
  Id id = Isar.autoIncrement;
}

abstract class OtherEntity implements Entity {
  @override
  Id id = Isar.autoIncrement;

  @override
  bool? get stringify => true;
}

abstract class ContentEntity implements Entity {
  @Index(replace: true, unique: true)
  final String stringID;
  final AniListMedia? anilistMedia;
  final bool isFavorite;

  ContentEntity({
    required this.stringID,
    this.anilistMedia,
    required this.isFavorite,
  }) : super();

  ContentEntity copyWith({
    AniListMedia? anilistMedia,
    bool? isFavorite,
  });

  @override
  Id id = Isar.autoIncrement;

  @override
  bool? get stringify => true;
}

abstract class HistoryEntity implements Entity, Comparable<HistoryEntity> {
  double get percent;
  bool get isComplete;

  double getPercent() {
    if (isComplete) return 1.0;
    return percent.isNaN ? 0.0 : percent;
  }

  Color completeColor(ColorScheme scheme) =>
      isComplete ? Colors.green : scheme.primary;

  @override
  Id id = Isar.autoIncrement;

  @override
  bool? get stringify => true;
}
