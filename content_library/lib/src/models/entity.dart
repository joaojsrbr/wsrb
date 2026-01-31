// ignore_for_file: must_be_immutable

import 'package:content_library/content_library.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show Colors, Color, ColorScheme;
import 'package:isar/isar.dart';

part 'generated/entity.mapper.dart';

@MappableClass(discriminatorKey: 'type')
sealed class Entity with EquatableMixin, EntityMappable {
  Entity({this.id = Isar.autoIncrement});
  final Id id;
}

@MappableClass(discriminatorKey: 'type')
abstract class OtherEntity with OtherEntityMappable implements Entity {
  OtherEntity({this.id = Isar.autoIncrement});
  @override
  Id id = Isar.autoIncrement;

  @override
  bool? get stringify => true;
}

@MappableClass(discriminatorKey: 'type')
abstract class ContentEntity
    with ContentEntityMappable
    implements Entity, Comparable<ContentEntity> {
  @Index(replace: true, unique: true)
  final String stringID;
  final AniListMedia? anilistMedia;
  final Source source;
  final bool isFavorite;
  final bool isMovie;
  final String title;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String url;
  final String? sinopse;
  @override
  Id id = Isar.autoIncrement;

  final List<String> newReleases;

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
    this.isMovie = false,
    this.sinopse,
    this.newReleases = const [],
    this.createdAt,
    this.updatedAt,
    this.id = Isar.autoIncrement,
  }) : super();

  bool contains(ContentEntity other) => other.stringID.contains(stringID);

  @override
  bool? get stringify => true;

  Content toContent();
}

@MappableClass(discriminatorKey: 'type')
abstract class HistoricEntity
    with HistoricEntityMappable
    implements Entity, Comparable<HistoricEntity> {
  final double percent;
  final int numberEpisode;
  final bool isComplete;
  final String title;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String url;
  // final List<CurrentPosition> positions;
  final CurrentPosition? position;
  final String? thumbnail;
  final String contentStringID;
  @override
  Id id = Isar.autoIncrement;

  // double getPercent() {
  //   if (isComplete) return 1.0;
  //   return percent.isNaN ? 0.0 : percent;
  // }

  HistoricEntity({
    required this.url,
    required this.title,
    required this.contentStringID,
    this.thumbnail,
    this.createdAt,
    this.updatedAt,
    this.isComplete = false,
    this.percent = 0.0,
    this.numberEpisode = 0,
    this.position,
    this.id = Isar.autoIncrement,
  });

  Color completeColor(ColorScheme scheme) => Colors.white;

  bool contains(HistoricEntity other) => other.id == id;

  @override
  bool? get stringify => true;
}
