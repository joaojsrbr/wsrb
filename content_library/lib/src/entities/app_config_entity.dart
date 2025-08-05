// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'package:content_library/content_library.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

part 'app_config_entity.g.dart';

@Collection(ignore: {'props', 'stringify', 'hashCode'})
class AppConfigEntity extends OtherEntity {
  @enumerated
  final OrderBy orderBy;

  final bool reverseContents;

  final FilterWatching filterWatching;

  @enumerated
  final Source source;

  final List<ContentCookie> betterAnimeCookies;

  @override
  List<Object?> get props => [orderBy, reverseContents, source];

  AppConfigEntity({
    required this.orderBy,
    required this.filterWatching,
    required this.reverseContents,
    required this.source,
    this.betterAnimeCookies = const [],
  });

  factory AppConfigEntity.init() => AppConfigEntity(
    orderBy: OrderBy.LATEST,
    betterAnimeCookies: [],
    filterWatching: FilterWatching.dafult(),
    source: Source.ANROLL,
    reverseContents: true,
  );

  AppConfigEntity copyWith({
    OrderBy? orderBy,
    bool? reverseContents,
    Source? source,
    ConnectivityResult? connectivityResult,
    List<ContentCookie>? betterAnimeCookies,
    double? historicSavePercent,
    FilterWatching? filterWatching,
  }) {
    final newConfig = AppConfigEntity(
      betterAnimeCookies: betterAnimeCookies ?? this.betterAnimeCookies,
      filterWatching: filterWatching ?? this.filterWatching,
      orderBy: orderBy ?? this.orderBy,
      reverseContents: reverseContents ?? this.reverseContents,
      source: source ?? this.source,
    );
    newConfig.id = id;
    return newConfig;
  }

  @override
  bool? get stringify => true;
}

@Embedded(ignore: {"toJson", "fromJson", "props", "stringify", "hashCode"})
class ContentCookie with EquatableMixin {
  ContentCookie({this.value = "", this.key = "", this.expiresDate});

  final String value;
  final String key;
  final int? expiresDate;

  static String stringifyCookies(List<ContentCookie> cookies) {
    return cookies.map((cookie) => '${cookie.key}=${cookie.value}').join('; ');
  }

  @override
  List<Object?> get props => [value, key];
}

@Embedded(ignore: {"toJson", "fromJson", "props", "stringify", "hashCode"})
class FilterWatching with EquatableMixin {
  final DateTime? start;
  final DateTime? end;
  final bool infiniteDate;
  final List<String> genresFilter;
  @enumerated
  final List<Source> filterSources;

  factory FilterWatching.dafult() => FilterWatching(filterSources: Source.list);

  @override
  List<Object?> get props => [start, end, infiniteDate, genresFilter, filterSources];

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
