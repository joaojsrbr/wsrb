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

abstract class ContentEntity implements Entity, Comparable<ContentEntity> {
  @Index(replace: true, unique: true)
  final String stringID;
  final AniListMedia? anilistMedia;
  final Source source;
  final bool isFavorite;
  final String title;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String url;
  final String? sinopse;

  String get imageUrl;

  @override
  int compareTo(ContentEntity other) {
    return stringID.compareTo(other.stringID);
  }

  @override
  List<Object?> get props => [stringID];

  ContentEntity({
    required this.title,
    required this.stringID,
    required this.url,
    required this.source,
    required this.isFavorite,
    this.anilistMedia,
    this.sinopse,
    this.createdAt,
    this.updatedAt,
  }) : super();

  ContentEntity copyWith({AniListMedia? anilistMedia, bool? isFavorite});

  bool contains(ContentEntity other) => other.stringID.contains(stringID);

  @override
  Id id = Isar.autoIncrement;

  @override
  bool? get stringify => true;
}

abstract class HistoricEntity implements Entity, Comparable<HistoricEntity> {
  final double percent;
  final bool isComplete;
  final String title;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String url;
  // final List<CurrentPosition> positions;
  final CurrentPosition? position;
  final String? thumbnail;

  // double getPercent() {
  //   if (isComplete) return 1.0;
  //   return percent.isNaN ? 0.0 : percent;
  // }

  HistoricEntity({
    required this.url,
    required this.title,
    this.thumbnail,
    this.createdAt,
    this.updatedAt,
    this.isComplete = false,
    this.percent = 0.0,
    this.position,
  });

  Color completeColor(ColorScheme scheme) => Colors.white;

  bool contains(HistoricEntity other) => other.id == id;

  @override
  Id id = Isar.autoIncrement;

  @override
  bool? get stringify => true;

  HistoricEntity copyWith({
    bool? isComplete,
    String? title,
    String? url,
    CurrentPosition? position,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}
