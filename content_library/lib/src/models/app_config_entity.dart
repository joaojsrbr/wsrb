// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'package:content_library/content_library.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'generated/app_config_entity.g.dart';
part 'generated/app_config_entity.mapper.dart';

@MappableClass()
@Collection(ignore: {'props', 'stringify', 'hashCode'})
class AppConfigEntity extends OtherEntity with AppConfigEntityMappable {
  @enumerated
  final OrderBy orderBy;

  final bool reverseContents;

  final FilterWatching filterWatching;

  @enumerated
  final AutoUpdateInterval autoUpdateInterval;

  @enumerated
  final ThemeMode themeMode;

  @enumerated
  final Source source;

  @override
  List<Object?> get props => [orderBy, reverseContents, source];

  AppConfigEntity({
    super.id,
    required this.orderBy,
    required this.filterWatching,
    required this.themeMode,
    required this.reverseContents,
    required this.source,
    required this.autoUpdateInterval,
  });

  factory AppConfigEntity.init() => AppConfigEntity(
    orderBy: OrderBy.LATEST,
    themeMode: ThemeMode.dark,
    autoUpdateInterval: AutoUpdateInterval.every30Minutes,
    filterWatching: FilterWatching.dafult(),
    source: Source.TOP_ANIMES,
    reverseContents: true,
  );

  @override
  bool? get stringify => true;
}

@Embedded(ignore: {"toJson", "fromJson", "props", "stringify", "hashCode"})
class FilterWatching with EquatableMixin {
  final DateTime? start;
  final DateTime? end;
  final bool infiniteDate;
  final List<String> genresFilter;
  @enumerated
  final List<Source> filterSources;

  factory FilterWatching.dafult() =>
      FilterWatching(filterSources: Source.values);

  @override
  List<Object?> get props => [
    start,
    end,
    infiniteDate,
    genresFilter,
    filterSources,
  ];

  FilterWatching({
    this.start,
    this.end,
    this.infiniteDate = false,
    this.genresFilter = const [],
    this.filterSources = const [],
  });

  FilterWatching copyWith({
    DateTime? start,
    DateTime? end,
    bool? infiniteDate,
    List<String>? genresFilter,
    List<Source>? filterSources,
  }) {
    return FilterWatching(
      start: start == DateTime(0) ? null : start ?? this.start,
      end: end == DateTime(0) ? null : end ?? this.end,
      infiniteDate: infiniteDate ?? this.infiniteDate,
      genresFilter: genresFilter ?? this.genresFilter,
      filterSources: filterSources ?? this.filterSources,
    );
  }
}

enum AutoUpdateInterval {
  disabled,
  every15Minutes,
  every30Minutes,
  every12Hours,
  daily,
  every2Days,
  every3Days,
  weekly;

  String get getIntervalText {
    switch (this) {
      case AutoUpdateInterval.disabled:
        return "Desligado";
      case AutoUpdateInterval.every15Minutes:
        return "A cada 15 minutos";
      case AutoUpdateInterval.every30Minutes:
        return "A cada 30 minutos";
      case AutoUpdateInterval.every12Hours:
        return "A cada 12 horas";
      case AutoUpdateInterval.daily:
        return "Diariamente";
      case AutoUpdateInterval.every2Days:
        return "A cada 2 dias";
      case AutoUpdateInterval.every3Days:
        return "A cada 3 dias";
      case AutoUpdateInterval.weekly:
        return "Semanalmente";
    }
  }

  Duration get intervalDuration {
    switch (this) {
      case AutoUpdateInterval.disabled:
        return Duration.zero;
      case AutoUpdateInterval.every15Minutes:
        return const Duration(minutes: 15);
      case AutoUpdateInterval.every30Minutes:
        return const Duration(minutes: 30);
      case AutoUpdateInterval.every12Hours:
        return const Duration(hours: 12);
      case AutoUpdateInterval.daily:
        return const Duration(days: 1);
      case AutoUpdateInterval.every2Days:
        return const Duration(days: 2);
      case AutoUpdateInterval.every3Days:
        return const Duration(days: 3);
      case AutoUpdateInterval.weekly:
        return const Duration(days: 7);
    }
  }
}
