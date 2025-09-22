// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../anime_skip_entity.dart';

class AnimeSkipEntityMapper extends ClassMapperBase<AnimeSkipEntity> {
  AnimeSkipEntityMapper._();

  static AnimeSkipEntityMapper? _instance;
  static AnimeSkipEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AnimeSkipEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AnimeSkipEntity';

  static String _$animeSkipId(AnimeSkipEntity v) => v.animeSkipId;
  static const Field<AnimeSkipEntity, String> _f$animeSkipId =
      Field('animeSkipId', _$animeSkipId, opt: true, def: "");
  static String _$name(AnimeSkipEntity v) => v.name;
  static const Field<AnimeSkipEntity, String> _f$name =
      Field('name', _$name, opt: true, def: "");
  static String _$times(AnimeSkipEntity v) => v.times;
  static const Field<AnimeSkipEntity, String> _f$times =
      Field('times', _$times, opt: true, def: "");

  @override
  final MappableFields<AnimeSkipEntity> fields = const {
    #animeSkipId: _f$animeSkipId,
    #name: _f$name,
    #times: _f$times,
  };

  static AnimeSkipEntity _instantiate(DecodingData data) {
    return AnimeSkipEntity(
        animeSkipId: data.dec(_f$animeSkipId),
        name: data.dec(_f$name),
        times: data.dec(_f$times));
  }

  @override
  final Function instantiate = _instantiate;

  static AnimeSkipEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AnimeSkipEntity>(map);
  }

  static AnimeSkipEntity fromJson(String json) {
    return ensureInitialized().decodeJson<AnimeSkipEntity>(json);
  }
}

mixin AnimeSkipEntityMappable {
  String toJson() {
    return AnimeSkipEntityMapper.ensureInitialized()
        .encodeJson<AnimeSkipEntity>(this as AnimeSkipEntity);
  }

  Map<String, dynamic> toMap() {
    return AnimeSkipEntityMapper.ensureInitialized()
        .encodeMap<AnimeSkipEntity>(this as AnimeSkipEntity);
  }

  AnimeSkipEntityCopyWith<AnimeSkipEntity, AnimeSkipEntity, AnimeSkipEntity>
      get copyWith => _AnimeSkipEntityCopyWithImpl(
          this as AnimeSkipEntity, $identity, $identity);
  @override
  String toString() {
    return AnimeSkipEntityMapper.ensureInitialized()
        .stringifyValue(this as AnimeSkipEntity);
  }

  @override
  bool operator ==(Object other) {
    return AnimeSkipEntityMapper.ensureInitialized()
        .equalsValue(this as AnimeSkipEntity, other);
  }

  @override
  int get hashCode {
    return AnimeSkipEntityMapper.ensureInitialized()
        .hashValue(this as AnimeSkipEntity);
  }
}

extension AnimeSkipEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AnimeSkipEntity, $Out> {
  AnimeSkipEntityCopyWith<$R, AnimeSkipEntity, $Out> get $asAnimeSkipEntity =>
      $base.as((v, t, t2) => _AnimeSkipEntityCopyWithImpl(v, t, t2));
}

abstract class AnimeSkipEntityCopyWith<$R, $In extends AnimeSkipEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? animeSkipId, String? name, String? times});
  AnimeSkipEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _AnimeSkipEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AnimeSkipEntity, $Out>
    implements AnimeSkipEntityCopyWith<$R, AnimeSkipEntity, $Out> {
  _AnimeSkipEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AnimeSkipEntity> $mapper =
      AnimeSkipEntityMapper.ensureInitialized();
  @override
  $R call({String? animeSkipId, String? name, String? times}) =>
      $apply(FieldCopyWithData({
        if (animeSkipId != null) #animeSkipId: animeSkipId,
        if (name != null) #name: name,
        if (times != null) #times: times
      }));
  @override
  AnimeSkipEntity $make(CopyWithData data) => AnimeSkipEntity(
      animeSkipId: data.get(#animeSkipId, or: $value.animeSkipId),
      name: data.get(#name, or: $value.name),
      times: data.get(#times, or: $value.times));

  @override
  AnimeSkipEntityCopyWith<$R2, AnimeSkipEntity, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _AnimeSkipEntityCopyWithImpl($value, $cast, t);
}
