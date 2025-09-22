// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../chapter_entity.dart';

class ChapterEntityMapper extends SubClassMapperBase<ChapterEntity> {
  ChapterEntityMapper._();

  static ChapterEntityMapper? _instance;
  static ChapterEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChapterEntityMapper._());
      HistoricEntityMapper.ensureInitialized().addSubMapper(_instance!);
      CurrentPositionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ChapterEntity';

  static DateTime? _$createdAt(ChapterEntity v) => v.createdAt;
  static const Field<ChapterEntity, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, opt: true);
  static bool _$isComplete(ChapterEntity v) => v.isComplete;
  static const Field<ChapterEntity, bool> _f$isComplete =
      Field('isComplete', _$isComplete, opt: true, def: false);
  static int _$id(ChapterEntity v) => v.id;
  static const Field<ChapterEntity, int> _f$id =
      Field('id', _$id, opt: true, def: Isar.autoIncrement);
  static String? _$thumbnail(ChapterEntity v) => v.thumbnail;
  static const Field<ChapterEntity, String> _f$thumbnail =
      Field('thumbnail', _$thumbnail, opt: true);
  static double _$percent(ChapterEntity v) => v.percent;
  static const Field<ChapterEntity, double> _f$percent =
      Field('percent', _$percent, opt: true, def: 0.0);
  static CurrentPosition? _$position(ChapterEntity v) => v.position;
  static const Field<ChapterEntity, CurrentPosition> _f$position =
      Field('position', _$position, opt: true);
  static int _$numberEpisode(ChapterEntity v) => v.numberEpisode;
  static const Field<ChapterEntity, int> _f$numberEpisode =
      Field('numberEpisode', _$numberEpisode, opt: true, def: 0);
  static double _$readPercent(ChapterEntity v) => v.readPercent;
  static const Field<ChapterEntity, double> _f$readPercent =
      Field('readPercent', _$readPercent);
  static String _$stringID(ChapterEntity v) => v.stringID;
  static const Field<ChapterEntity, String> _f$stringID =
      Field('stringID', _$stringID);
  static String _$bookStringID(ChapterEntity v) => v.bookStringID;
  static const Field<ChapterEntity, String> _f$bookStringID =
      Field('bookStringID', _$bookStringID);
  static String _$url(ChapterEntity v) => v.url;
  static const Field<ChapterEntity, String> _f$url = Field('url', _$url);
  static String _$contentStringID(ChapterEntity v) => v.contentStringID;
  static const Field<ChapterEntity, String> _f$contentStringID =
      Field('contentStringID', _$contentStringID);
  static String _$title(ChapterEntity v) => v.title;
  static const Field<ChapterEntity, String> _f$title = Field('title', _$title);
  static DateTime? _$updatedAt(ChapterEntity v) => v.updatedAt;
  static const Field<ChapterEntity, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, opt: true);

  @override
  final MappableFields<ChapterEntity> fields = const {
    #createdAt: _f$createdAt,
    #isComplete: _f$isComplete,
    #id: _f$id,
    #thumbnail: _f$thumbnail,
    #percent: _f$percent,
    #position: _f$position,
    #numberEpisode: _f$numberEpisode,
    #readPercent: _f$readPercent,
    #stringID: _f$stringID,
    #bookStringID: _f$bookStringID,
    #url: _f$url,
    #contentStringID: _f$contentStringID,
    #title: _f$title,
    #updatedAt: _f$updatedAt,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'ChapterEntity';
  @override
  late final ClassMapperBase superMapper =
      HistoricEntityMapper.ensureInitialized();

  static ChapterEntity _instantiate(DecodingData data) {
    return ChapterEntity(
        createdAt: data.dec(_f$createdAt),
        isComplete: data.dec(_f$isComplete),
        id: data.dec(_f$id),
        thumbnail: data.dec(_f$thumbnail),
        percent: data.dec(_f$percent),
        position: data.dec(_f$position),
        numberEpisode: data.dec(_f$numberEpisode),
        readPercent: data.dec(_f$readPercent),
        stringID: data.dec(_f$stringID),
        bookStringID: data.dec(_f$bookStringID),
        url: data.dec(_f$url),
        contentStringID: data.dec(_f$contentStringID),
        title: data.dec(_f$title),
        updatedAt: data.dec(_f$updatedAt));
  }

  @override
  final Function instantiate = _instantiate;

  static ChapterEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ChapterEntity>(map);
  }

  static ChapterEntity fromJson(String json) {
    return ensureInitialized().decodeJson<ChapterEntity>(json);
  }
}

mixin ChapterEntityMappable {
  String toJson() {
    return ChapterEntityMapper.ensureInitialized()
        .encodeJson<ChapterEntity>(this as ChapterEntity);
  }

  Map<String, dynamic> toMap() {
    return ChapterEntityMapper.ensureInitialized()
        .encodeMap<ChapterEntity>(this as ChapterEntity);
  }

  ChapterEntityCopyWith<ChapterEntity, ChapterEntity, ChapterEntity>
      get copyWith => _ChapterEntityCopyWithImpl(
          this as ChapterEntity, $identity, $identity);
  @override
  String toString() {
    return ChapterEntityMapper.ensureInitialized()
        .stringifyValue(this as ChapterEntity);
  }

  @override
  bool operator ==(Object other) {
    return ChapterEntityMapper.ensureInitialized()
        .equalsValue(this as ChapterEntity, other);
  }

  @override
  int get hashCode {
    return ChapterEntityMapper.ensureInitialized()
        .hashValue(this as ChapterEntity);
  }
}

extension ChapterEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ChapterEntity, $Out> {
  ChapterEntityCopyWith<$R, ChapterEntity, $Out> get $asChapterEntity =>
      $base.as((v, t, t2) => _ChapterEntityCopyWithImpl(v, t, t2));
}

abstract class ChapterEntityCopyWith<$R, $In extends ChapterEntity, $Out>
    implements HistoricEntityCopyWith<$R, $In, $Out> {
  @override
  CurrentPositionCopyWith<$R, CurrentPosition, CurrentPosition>? get position;
  @override
  $R call(
      {DateTime? createdAt,
      bool? isComplete,
      int? id,
      String? thumbnail,
      double? percent,
      CurrentPosition? position,
      int? numberEpisode,
      double? readPercent,
      String? stringID,
      String? bookStringID,
      String? url,
      String? contentStringID,
      String? title,
      DateTime? updatedAt});
  ChapterEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ChapterEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ChapterEntity, $Out>
    implements ChapterEntityCopyWith<$R, ChapterEntity, $Out> {
  _ChapterEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ChapterEntity> $mapper =
      ChapterEntityMapper.ensureInitialized();
  @override
  CurrentPositionCopyWith<$R, CurrentPosition, CurrentPosition>? get position =>
      $value.position?.copyWith.$chain((v) => call(position: v));
  @override
  $R call(
          {Object? createdAt = $none,
          bool? isComplete,
          int? id,
          Object? thumbnail = $none,
          double? percent,
          Object? position = $none,
          int? numberEpisode,
          double? readPercent,
          String? stringID,
          String? bookStringID,
          String? url,
          String? contentStringID,
          String? title,
          Object? updatedAt = $none}) =>
      $apply(FieldCopyWithData({
        if (createdAt != $none) #createdAt: createdAt,
        if (isComplete != null) #isComplete: isComplete,
        if (id != null) #id: id,
        if (thumbnail != $none) #thumbnail: thumbnail,
        if (percent != null) #percent: percent,
        if (position != $none) #position: position,
        if (numberEpisode != null) #numberEpisode: numberEpisode,
        if (readPercent != null) #readPercent: readPercent,
        if (stringID != null) #stringID: stringID,
        if (bookStringID != null) #bookStringID: bookStringID,
        if (url != null) #url: url,
        if (contentStringID != null) #contentStringID: contentStringID,
        if (title != null) #title: title,
        if (updatedAt != $none) #updatedAt: updatedAt
      }));
  @override
  ChapterEntity $make(CopyWithData data) => ChapterEntity(
      createdAt: data.get(#createdAt, or: $value.createdAt),
      isComplete: data.get(#isComplete, or: $value.isComplete),
      id: data.get(#id, or: $value.id),
      thumbnail: data.get(#thumbnail, or: $value.thumbnail),
      percent: data.get(#percent, or: $value.percent),
      position: data.get(#position, or: $value.position),
      numberEpisode: data.get(#numberEpisode, or: $value.numberEpisode),
      readPercent: data.get(#readPercent, or: $value.readPercent),
      stringID: data.get(#stringID, or: $value.stringID),
      bookStringID: data.get(#bookStringID, or: $value.bookStringID),
      url: data.get(#url, or: $value.url),
      contentStringID: data.get(#contentStringID, or: $value.contentStringID),
      title: data.get(#title, or: $value.title),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt));

  @override
  ChapterEntityCopyWith<$R2, ChapterEntity, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _ChapterEntityCopyWithImpl($value, $cast, t);
}
