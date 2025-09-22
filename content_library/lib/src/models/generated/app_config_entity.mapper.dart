// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../app_config_entity.dart';

class AppConfigEntityMapper extends SubClassMapperBase<AppConfigEntity> {
  AppConfigEntityMapper._();

  static AppConfigEntityMapper? _instance;
  static AppConfigEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AppConfigEntityMapper._());
      OtherEntityMapper.ensureInitialized().addSubMapper(_instance!);
      OrderByMapper.ensureInitialized();
      SourceMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AppConfigEntity';

  static int _$id(AppConfigEntity v) => v.id;
  static const Field<AppConfigEntity, int> _f$id =
      Field('id', _$id, opt: true, def: Isar.autoIncrement);
  static OrderBy _$orderBy(AppConfigEntity v) => v.orderBy;
  static const Field<AppConfigEntity, OrderBy> _f$orderBy =
      Field('orderBy', _$orderBy);
  static FilterWatching _$filterWatching(AppConfigEntity v) => v.filterWatching;
  static const Field<AppConfigEntity, FilterWatching> _f$filterWatching =
      Field('filterWatching', _$filterWatching);
  static bool _$reverseContents(AppConfigEntity v) => v.reverseContents;
  static const Field<AppConfigEntity, bool> _f$reverseContents =
      Field('reverseContents', _$reverseContents);
  static Source _$source(AppConfigEntity v) => v.source;
  static const Field<AppConfigEntity, Source> _f$source =
      Field('source', _$source);
  static AutoUpdateInterval _$autoUpdateInterval(AppConfigEntity v) =>
      v.autoUpdateInterval;
  static const Field<AppConfigEntity, AutoUpdateInterval>
      _f$autoUpdateInterval = Field('autoUpdateInterval', _$autoUpdateInterval);

  @override
  final MappableFields<AppConfigEntity> fields = const {
    #id: _f$id,
    #orderBy: _f$orderBy,
    #filterWatching: _f$filterWatching,
    #reverseContents: _f$reverseContents,
    #source: _f$source,
    #autoUpdateInterval: _f$autoUpdateInterval,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'AppConfigEntity';
  @override
  late final ClassMapperBase superMapper =
      OtherEntityMapper.ensureInitialized();

  static AppConfigEntity _instantiate(DecodingData data) {
    return AppConfigEntity(
        id: data.dec(_f$id),
        orderBy: data.dec(_f$orderBy),
        filterWatching: data.dec(_f$filterWatching),
        reverseContents: data.dec(_f$reverseContents),
        source: data.dec(_f$source),
        autoUpdateInterval: data.dec(_f$autoUpdateInterval));
  }

  @override
  final Function instantiate = _instantiate;

  static AppConfigEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AppConfigEntity>(map);
  }

  static AppConfigEntity fromJson(String json) {
    return ensureInitialized().decodeJson<AppConfigEntity>(json);
  }
}

mixin AppConfigEntityMappable {
  String toJson() {
    return AppConfigEntityMapper.ensureInitialized()
        .encodeJson<AppConfigEntity>(this as AppConfigEntity);
  }

  Map<String, dynamic> toMap() {
    return AppConfigEntityMapper.ensureInitialized()
        .encodeMap<AppConfigEntity>(this as AppConfigEntity);
  }

  AppConfigEntityCopyWith<AppConfigEntity, AppConfigEntity, AppConfigEntity>
      get copyWith => _AppConfigEntityCopyWithImpl(
          this as AppConfigEntity, $identity, $identity);
  @override
  String toString() {
    return AppConfigEntityMapper.ensureInitialized()
        .stringifyValue(this as AppConfigEntity);
  }

  @override
  bool operator ==(Object other) {
    return AppConfigEntityMapper.ensureInitialized()
        .equalsValue(this as AppConfigEntity, other);
  }

  @override
  int get hashCode {
    return AppConfigEntityMapper.ensureInitialized()
        .hashValue(this as AppConfigEntity);
  }
}

extension AppConfigEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AppConfigEntity, $Out> {
  AppConfigEntityCopyWith<$R, AppConfigEntity, $Out> get $asAppConfigEntity =>
      $base.as((v, t, t2) => _AppConfigEntityCopyWithImpl(v, t, t2));
}

abstract class AppConfigEntityCopyWith<$R, $In extends AppConfigEntity, $Out>
    implements OtherEntityCopyWith<$R, $In, $Out> {
  @override
  $R call(
      {int? id,
      OrderBy? orderBy,
      FilterWatching? filterWatching,
      bool? reverseContents,
      Source? source,
      AutoUpdateInterval? autoUpdateInterval});
  AppConfigEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _AppConfigEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AppConfigEntity, $Out>
    implements AppConfigEntityCopyWith<$R, AppConfigEntity, $Out> {
  _AppConfigEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AppConfigEntity> $mapper =
      AppConfigEntityMapper.ensureInitialized();
  @override
  $R call(
          {int? id,
          OrderBy? orderBy,
          FilterWatching? filterWatching,
          bool? reverseContents,
          Source? source,
          AutoUpdateInterval? autoUpdateInterval}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (orderBy != null) #orderBy: orderBy,
        if (filterWatching != null) #filterWatching: filterWatching,
        if (reverseContents != null) #reverseContents: reverseContents,
        if (source != null) #source: source,
        if (autoUpdateInterval != null) #autoUpdateInterval: autoUpdateInterval
      }));
  @override
  AppConfigEntity $make(CopyWithData data) => AppConfigEntity(
      id: data.get(#id, or: $value.id),
      orderBy: data.get(#orderBy, or: $value.orderBy),
      filterWatching: data.get(#filterWatching, or: $value.filterWatching),
      reverseContents: data.get(#reverseContents, or: $value.reverseContents),
      source: data.get(#source, or: $value.source),
      autoUpdateInterval:
          data.get(#autoUpdateInterval, or: $value.autoUpdateInterval));

  @override
  AppConfigEntityCopyWith<$R2, AppConfigEntity, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _AppConfigEntityCopyWithImpl($value, $cast, t);
}
