// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../episode_entity.dart';

class EpisodeEntityMapper extends SubClassMapperBase<EpisodeEntity> {
  EpisodeEntityMapper._();

  static EpisodeEntityMapper? _instance;
  static EpisodeEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EpisodeEntityMapper._());
      HistoricEntityMapper.ensureInitialized().addSubMapper(_instance!);
      CurrentPositionMapper.ensureInitialized();
      AnimeSkipEntityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'EpisodeEntity';

  static int _$id(EpisodeEntity v) => v.id;
  static const Field<EpisodeEntity, int> _f$id =
      Field('id', _$id, opt: true, def: Isar.autoIncrement);
  static CurrentPosition? _$position(EpisodeEntity v) => v.position;
  static const Field<EpisodeEntity, CurrentPosition> _f$position =
      Field('position', _$position, opt: true);
  static String _$stringID(EpisodeEntity v) => v.stringID;
  static const Field<EpisodeEntity, String> _f$stringID =
      Field('stringID', _$stringID);
  static String _$title(EpisodeEntity v) => v.title;
  static const Field<EpisodeEntity, String> _f$title = Field('title', _$title);
  static String _$contentStringID(EpisodeEntity v) => v.contentStringID;
  static const Field<EpisodeEntity, String> _f$contentStringID =
      Field('contentStringID', _$contentStringID);
  static String? _$sinopse(EpisodeEntity v) => v.sinopse;
  static const Field<EpisodeEntity, String> _f$sinopse =
      Field('sinopse', _$sinopse);
  static int _$numberEpisode(EpisodeEntity v) => v.numberEpisode;
  static const Field<EpisodeEntity, int> _f$numberEpisode =
      Field('numberEpisode', _$numberEpisode, def: 0);
  static String _$url(EpisodeEntity v) => v.url;
  static const Field<EpisodeEntity, String> _f$url = Field('url', _$url);
  static String? _$slugSerie(EpisodeEntity v) => v.slugSerie;
  static const Field<EpisodeEntity, String> _f$slugSerie =
      Field('slugSerie', _$slugSerie, opt: true);
  static AnimeSkipEntity? _$animeSkipEntity(EpisodeEntity v) =>
      v.animeSkipEntity;
  static const Field<EpisodeEntity, AnimeSkipEntity> _f$animeSkipEntity =
      Field('animeSkipEntity', _$animeSkipEntity, opt: true);
  static DateTime? _$registrationData(EpisodeEntity v) => v.registrationData;
  static const Field<EpisodeEntity, DateTime> _f$registrationData =
      Field('registrationData', _$registrationData, opt: true);
  static int? _$pageNumber(EpisodeEntity v) => v.pageNumber;
  static const Field<EpisodeEntity, int> _f$pageNumber =
      Field('pageNumber', _$pageNumber, opt: true);
  static String? _$generateID(EpisodeEntity v) => v.generateID;
  static const Field<EpisodeEntity, String> _f$generateID =
      Field('generateID', _$generateID, opt: true);
  static DateTime? _$createdAt(EpisodeEntity v) => v.createdAt;
  static const Field<EpisodeEntity, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, opt: true);
  static String? _$thumbnail(EpisodeEntity v) => v.thumbnail;
  static const Field<EpisodeEntity, String> _f$thumbnail =
      Field('thumbnail', _$thumbnail, opt: true);
  static DateTime? _$updatedAt(EpisodeEntity v) => v.updatedAt;
  static const Field<EpisodeEntity, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, opt: true);
  static bool _$isComplete(EpisodeEntity v) => v.isComplete;
  static const Field<EpisodeEntity, bool> _f$isComplete =
      Field('isComplete', _$isComplete, opt: true, def: false);
  static double _$percent(EpisodeEntity v) => v.percent;
  static const Field<EpisodeEntity, double> _f$percent =
      Field('percent', _$percent, opt: true, def: 0.0);

  @override
  final MappableFields<EpisodeEntity> fields = const {
    #id: _f$id,
    #position: _f$position,
    #stringID: _f$stringID,
    #title: _f$title,
    #contentStringID: _f$contentStringID,
    #sinopse: _f$sinopse,
    #numberEpisode: _f$numberEpisode,
    #url: _f$url,
    #slugSerie: _f$slugSerie,
    #animeSkipEntity: _f$animeSkipEntity,
    #registrationData: _f$registrationData,
    #pageNumber: _f$pageNumber,
    #generateID: _f$generateID,
    #createdAt: _f$createdAt,
    #thumbnail: _f$thumbnail,
    #updatedAt: _f$updatedAt,
    #isComplete: _f$isComplete,
    #percent: _f$percent,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'EpisodeEntity';
  @override
  late final ClassMapperBase superMapper =
      HistoricEntityMapper.ensureInitialized();

  static EpisodeEntity _instantiate(DecodingData data) {
    return EpisodeEntity(
        id: data.dec(_f$id),
        position: data.dec(_f$position),
        stringID: data.dec(_f$stringID),
        title: data.dec(_f$title),
        contentStringID: data.dec(_f$contentStringID),
        sinopse: data.dec(_f$sinopse),
        numberEpisode: data.dec(_f$numberEpisode),
        url: data.dec(_f$url),
        slugSerie: data.dec(_f$slugSerie),
        animeSkipEntity: data.dec(_f$animeSkipEntity),
        registrationData: data.dec(_f$registrationData),
        pageNumber: data.dec(_f$pageNumber),
        generateID: data.dec(_f$generateID),
        createdAt: data.dec(_f$createdAt),
        thumbnail: data.dec(_f$thumbnail),
        updatedAt: data.dec(_f$updatedAt),
        isComplete: data.dec(_f$isComplete),
        percent: data.dec(_f$percent));
  }

  @override
  final Function instantiate = _instantiate;

  static EpisodeEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EpisodeEntity>(map);
  }

  static EpisodeEntity fromJson(String json) {
    return ensureInitialized().decodeJson<EpisodeEntity>(json);
  }
}

mixin EpisodeEntityMappable {
  String toJson() {
    return EpisodeEntityMapper.ensureInitialized()
        .encodeJson<EpisodeEntity>(this as EpisodeEntity);
  }

  Map<String, dynamic> toMap() {
    return EpisodeEntityMapper.ensureInitialized()
        .encodeMap<EpisodeEntity>(this as EpisodeEntity);
  }

  EpisodeEntityCopyWith<EpisodeEntity, EpisodeEntity, EpisodeEntity>
      get copyWith => _EpisodeEntityCopyWithImpl(
          this as EpisodeEntity, $identity, $identity);
  @override
  String toString() {
    return EpisodeEntityMapper.ensureInitialized()
        .stringifyValue(this as EpisodeEntity);
  }

  @override
  bool operator ==(Object other) {
    return EpisodeEntityMapper.ensureInitialized()
        .equalsValue(this as EpisodeEntity, other);
  }

  @override
  int get hashCode {
    return EpisodeEntityMapper.ensureInitialized()
        .hashValue(this as EpisodeEntity);
  }
}

extension EpisodeEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EpisodeEntity, $Out> {
  EpisodeEntityCopyWith<$R, EpisodeEntity, $Out> get $asEpisodeEntity =>
      $base.as((v, t, t2) => _EpisodeEntityCopyWithImpl(v, t, t2));
}

abstract class EpisodeEntityCopyWith<$R, $In extends EpisodeEntity, $Out>
    implements HistoricEntityCopyWith<$R, $In, $Out> {
  @override
  CurrentPositionCopyWith<$R, CurrentPosition, CurrentPosition>? get position;
  AnimeSkipEntityCopyWith<$R, AnimeSkipEntity, AnimeSkipEntity>?
      get animeSkipEntity;
  @override
  $R call(
      {int? id,
      CurrentPosition? position,
      String? stringID,
      String? title,
      String? contentStringID,
      String? sinopse,
      int? numberEpisode,
      String? url,
      String? slugSerie,
      AnimeSkipEntity? animeSkipEntity,
      DateTime? registrationData,
      int? pageNumber,
      String? generateID,
      DateTime? createdAt,
      String? thumbnail,
      DateTime? updatedAt,
      bool? isComplete,
      double? percent});
  EpisodeEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _EpisodeEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EpisodeEntity, $Out>
    implements EpisodeEntityCopyWith<$R, EpisodeEntity, $Out> {
  _EpisodeEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EpisodeEntity> $mapper =
      EpisodeEntityMapper.ensureInitialized();
  @override
  CurrentPositionCopyWith<$R, CurrentPosition, CurrentPosition>? get position =>
      $value.position?.copyWith.$chain((v) => call(position: v));
  @override
  AnimeSkipEntityCopyWith<$R, AnimeSkipEntity, AnimeSkipEntity>?
      get animeSkipEntity => $value.animeSkipEntity?.copyWith
          .$chain((v) => call(animeSkipEntity: v));
  @override
  $R call(
          {int? id,
          Object? position = $none,
          String? stringID,
          String? title,
          String? contentStringID,
          Object? sinopse = $none,
          int? numberEpisode,
          String? url,
          Object? slugSerie = $none,
          Object? animeSkipEntity = $none,
          Object? registrationData = $none,
          Object? pageNumber = $none,
          Object? generateID = $none,
          Object? createdAt = $none,
          Object? thumbnail = $none,
          Object? updatedAt = $none,
          bool? isComplete,
          double? percent}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (position != $none) #position: position,
        if (stringID != null) #stringID: stringID,
        if (title != null) #title: title,
        if (contentStringID != null) #contentStringID: contentStringID,
        if (sinopse != $none) #sinopse: sinopse,
        if (numberEpisode != null) #numberEpisode: numberEpisode,
        if (url != null) #url: url,
        if (slugSerie != $none) #slugSerie: slugSerie,
        if (animeSkipEntity != $none) #animeSkipEntity: animeSkipEntity,
        if (registrationData != $none) #registrationData: registrationData,
        if (pageNumber != $none) #pageNumber: pageNumber,
        if (generateID != $none) #generateID: generateID,
        if (createdAt != $none) #createdAt: createdAt,
        if (thumbnail != $none) #thumbnail: thumbnail,
        if (updatedAt != $none) #updatedAt: updatedAt,
        if (isComplete != null) #isComplete: isComplete,
        if (percent != null) #percent: percent
      }));
  @override
  EpisodeEntity $make(CopyWithData data) => EpisodeEntity(
      id: data.get(#id, or: $value.id),
      position: data.get(#position, or: $value.position),
      stringID: data.get(#stringID, or: $value.stringID),
      title: data.get(#title, or: $value.title),
      contentStringID: data.get(#contentStringID, or: $value.contentStringID),
      sinopse: data.get(#sinopse, or: $value.sinopse),
      numberEpisode: data.get(#numberEpisode, or: $value.numberEpisode),
      url: data.get(#url, or: $value.url),
      slugSerie: data.get(#slugSerie, or: $value.slugSerie),
      animeSkipEntity: data.get(#animeSkipEntity, or: $value.animeSkipEntity),
      registrationData:
          data.get(#registrationData, or: $value.registrationData),
      pageNumber: data.get(#pageNumber, or: $value.pageNumber),
      generateID: data.get(#generateID, or: $value.generateID),
      createdAt: data.get(#createdAt, or: $value.createdAt),
      thumbnail: data.get(#thumbnail, or: $value.thumbnail),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt),
      isComplete: data.get(#isComplete, or: $value.isComplete),
      percent: data.get(#percent, or: $value.percent));

  @override
  EpisodeEntityCopyWith<$R2, EpisodeEntity, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _EpisodeEntityCopyWithImpl($value, $cast, t);
}

class CurrentPositionMapper extends ClassMapperBase<CurrentPosition> {
  CurrentPositionMapper._();

  static CurrentPositionMapper? _instance;
  static CurrentPositionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CurrentPositionMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CurrentPosition';

  static int _$currentDuration(CurrentPosition v) => v.currentDuration;
  static const Field<CurrentPosition, int> _f$currentDuration =
      Field('currentDuration', _$currentDuration, opt: true, def: 0);
  static String? _$currentPositionBase64(CurrentPosition v) =>
      v.currentPositionBase64;
  static const Field<CurrentPosition, String> _f$currentPositionBase64 =
      Field('currentPositionBase64', _$currentPositionBase64, opt: true);
  static DateTime? _$createdAt(CurrentPosition v) => v.createdAt;
  static const Field<CurrentPosition, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, opt: true);
  static int _$episodeDuration(CurrentPosition v) => v.episodeDuration;
  static const Field<CurrentPosition, int> _f$episodeDuration =
      Field('episodeDuration', _$episodeDuration, opt: true, def: 0);
  static double _$percent(CurrentPosition v) => v.percent;
  static const Field<CurrentPosition, double> _f$percent =
      Field('percent', _$percent, mode: FieldMode.member);

  @override
  final MappableFields<CurrentPosition> fields = const {
    #currentDuration: _f$currentDuration,
    #currentPositionBase64: _f$currentPositionBase64,
    #createdAt: _f$createdAt,
    #episodeDuration: _f$episodeDuration,
    #percent: _f$percent,
  };

  static CurrentPosition _instantiate(DecodingData data) {
    return CurrentPosition(
        currentDuration: data.dec(_f$currentDuration),
        currentPositionBase64: data.dec(_f$currentPositionBase64),
        createdAt: data.dec(_f$createdAt),
        episodeDuration: data.dec(_f$episodeDuration));
  }

  @override
  final Function instantiate = _instantiate;

  static CurrentPosition fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CurrentPosition>(map);
  }

  static CurrentPosition fromJson(String json) {
    return ensureInitialized().decodeJson<CurrentPosition>(json);
  }
}

mixin CurrentPositionMappable {
  String toJson() {
    return CurrentPositionMapper.ensureInitialized()
        .encodeJson<CurrentPosition>(this as CurrentPosition);
  }

  Map<String, dynamic> toMap() {
    return CurrentPositionMapper.ensureInitialized()
        .encodeMap<CurrentPosition>(this as CurrentPosition);
  }

  CurrentPositionCopyWith<CurrentPosition, CurrentPosition, CurrentPosition>
      get copyWith => _CurrentPositionCopyWithImpl(
          this as CurrentPosition, $identity, $identity);
  @override
  String toString() {
    return CurrentPositionMapper.ensureInitialized()
        .stringifyValue(this as CurrentPosition);
  }

  @override
  bool operator ==(Object other) {
    return CurrentPositionMapper.ensureInitialized()
        .equalsValue(this as CurrentPosition, other);
  }

  @override
  int get hashCode {
    return CurrentPositionMapper.ensureInitialized()
        .hashValue(this as CurrentPosition);
  }
}

extension CurrentPositionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CurrentPosition, $Out> {
  CurrentPositionCopyWith<$R, CurrentPosition, $Out> get $asCurrentPosition =>
      $base.as((v, t, t2) => _CurrentPositionCopyWithImpl(v, t, t2));
}

abstract class CurrentPositionCopyWith<$R, $In extends CurrentPosition, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {int? currentDuration,
      String? currentPositionBase64,
      DateTime? createdAt,
      int? episodeDuration});
  CurrentPositionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _CurrentPositionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CurrentPosition, $Out>
    implements CurrentPositionCopyWith<$R, CurrentPosition, $Out> {
  _CurrentPositionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CurrentPosition> $mapper =
      CurrentPositionMapper.ensureInitialized();
  @override
  $R call(
          {int? currentDuration,
          Object? currentPositionBase64 = $none,
          Object? createdAt = $none,
          int? episodeDuration}) =>
      $apply(FieldCopyWithData({
        if (currentDuration != null) #currentDuration: currentDuration,
        if (currentPositionBase64 != $none)
          #currentPositionBase64: currentPositionBase64,
        if (createdAt != $none) #createdAt: createdAt,
        if (episodeDuration != null) #episodeDuration: episodeDuration
      }));
  @override
  CurrentPosition $make(CopyWithData data) => CurrentPosition(
      currentDuration: data.get(#currentDuration, or: $value.currentDuration),
      currentPositionBase64:
          data.get(#currentPositionBase64, or: $value.currentPositionBase64),
      createdAt: data.get(#createdAt, or: $value.createdAt),
      episodeDuration: data.get(#episodeDuration, or: $value.episodeDuration));

  @override
  CurrentPositionCopyWith<$R2, CurrentPosition, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _CurrentPositionCopyWithImpl($value, $cast, t);
}
