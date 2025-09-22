// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../chapter.dart';

class ChapterMapper extends SubClassMapperBase<Chapter> {
  ChapterMapper._();

  static ChapterMapper? _instance;
  static ChapterMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChapterMapper._());
      ReleaseMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'Chapter';

  static bool _$read(Chapter v) => v.read;
  static const Field<Chapter, bool> _f$read =
      Field('read', _$read, opt: true, def: false);
  static String _$url(Chapter v) => v.url;
  static const Field<Chapter, String> _f$url = Field('url', _$url);
  static String _$bookStringID(Chapter v) => v.bookStringID;
  static const Field<Chapter, String> _f$bookStringID =
      Field('bookStringID', _$bookStringID);
  static String _$title(Chapter v) => v.title;
  static const Field<Chapter, String> _f$title = Field('title', _$title);
  static int? _$numberEpisode(Chapter v) => v.numberEpisode;
  static const Field<Chapter, int> _f$numberEpisode =
      Field('numberEpisode', _$numberEpisode, opt: true);

  @override
  final MappableFields<Chapter> fields = const {
    #read: _f$read,
    #url: _f$url,
    #bookStringID: _f$bookStringID,
    #title: _f$title,
    #numberEpisode: _f$numberEpisode,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'Chapter';
  @override
  late final ClassMapperBase superMapper = ReleaseMapper.ensureInitialized();

  static Chapter _instantiate(DecodingData data) {
    return Chapter(
        read: data.dec(_f$read),
        url: data.dec(_f$url),
        bookStringID: data.dec(_f$bookStringID),
        title: data.dec(_f$title),
        numberEpisode: data.dec(_f$numberEpisode));
  }

  @override
  final Function instantiate = _instantiate;

  static Chapter fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Chapter>(map);
  }

  static Chapter fromJson(String json) {
    return ensureInitialized().decodeJson<Chapter>(json);
  }
}

mixin ChapterMappable {
  String toJson() {
    return ChapterMapper.ensureInitialized()
        .encodeJson<Chapter>(this as Chapter);
  }

  Map<String, dynamic> toMap() {
    return ChapterMapper.ensureInitialized()
        .encodeMap<Chapter>(this as Chapter);
  }

  ChapterCopyWith<Chapter, Chapter, Chapter> get copyWith =>
      _ChapterCopyWithImpl(this as Chapter, $identity, $identity);
  @override
  String toString() {
    return ChapterMapper.ensureInitialized().stringifyValue(this as Chapter);
  }

  @override
  bool operator ==(Object other) {
    return ChapterMapper.ensureInitialized()
        .equalsValue(this as Chapter, other);
  }

  @override
  int get hashCode {
    return ChapterMapper.ensureInitialized().hashValue(this as Chapter);
  }
}

extension ChapterValueCopy<$R, $Out> on ObjectCopyWith<$R, Chapter, $Out> {
  ChapterCopyWith<$R, Chapter, $Out> get $asChapter =>
      $base.as((v, t, t2) => _ChapterCopyWithImpl(v, t, t2));
}

abstract class ChapterCopyWith<$R, $In extends Chapter, $Out>
    implements ReleaseCopyWith<$R, $In, $Out> {
  @override
  $R call(
      {bool? read,
      String? url,
      String? bookStringID,
      String? title,
      int? numberEpisode});
  ChapterCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ChapterCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Chapter, $Out>
    implements ChapterCopyWith<$R, Chapter, $Out> {
  _ChapterCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Chapter> $mapper =
      ChapterMapper.ensureInitialized();
  @override
  $R call(
          {bool? read,
          String? url,
          String? bookStringID,
          String? title,
          Object? numberEpisode = $none}) =>
      $apply(FieldCopyWithData({
        if (read != null) #read: read,
        if (url != null) #url: url,
        if (bookStringID != null) #bookStringID: bookStringID,
        if (title != null) #title: title,
        if (numberEpisode != $none) #numberEpisode: numberEpisode
      }));
  @override
  Chapter $make(CopyWithData data) => Chapter(
      read: data.get(#read, or: $value.read),
      url: data.get(#url, or: $value.url),
      bookStringID: data.get(#bookStringID, or: $value.bookStringID),
      title: data.get(#title, or: $value.title),
      numberEpisode: data.get(#numberEpisode, or: $value.numberEpisode));

  @override
  ChapterCopyWith<$R2, Chapter, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ChapterCopyWithImpl($value, $cast, t);
}
