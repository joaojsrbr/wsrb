// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../book_entity.dart';

class BookEntityMapper extends SubClassMapperBase<BookEntity> {
  BookEntityMapper._();

  static BookEntityMapper? _instance;
  static BookEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BookEntityMapper._());
      ContentEntityMapper.ensureInitialized().addSubMapper(_instance!);
      SourceMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'BookEntity';

  static int _$id(BookEntity v) => v.id;
  static const Field<BookEntity, int> _f$id =
      Field('id', _$id, opt: true, def: Isar.autoIncrement);
  static String _$stringID(BookEntity v) => v.stringID;
  static const Field<BookEntity, String> _f$stringID =
      Field('stringID', _$stringID);
  static String _$title(BookEntity v) => v.title;
  static const Field<BookEntity, String> _f$title = Field('title', _$title);
  static String _$url(BookEntity v) => v.url;
  static const Field<BookEntity, String> _f$url = Field('url', _$url);
  static Source _$source(BookEntity v) => v.source;
  static const Field<BookEntity, Source> _f$source = Field('source', _$source);
  static String _$originalImage(BookEntity v) => v.originalImage;
  static const Field<BookEntity, String> _f$originalImage =
      Field('originalImage', _$originalImage);
  static DateTime? _$createdAt(BookEntity v) => v.createdAt;
  static const Field<BookEntity, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, opt: true);
  static AniListMedia? _$anilistMedia(BookEntity v) => v.anilistMedia;
  static const Field<BookEntity, AniListMedia> _f$anilistMedia =
      Field('anilistMedia', _$anilistMedia, opt: true);
  static String? _$sinopse(BookEntity v) => v.sinopse;
  static const Field<BookEntity, String> _f$sinopse =
      Field('sinopse', _$sinopse, opt: true);
  static DateTime? _$updatedAt(BookEntity v) => v.updatedAt;
  static const Field<BookEntity, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, opt: true);
  static String? _$alternativeTitle(BookEntity v) => v.alternativeTitle;
  static const Field<BookEntity, String> _f$alternativeTitle =
      Field('alternativeTitle', _$alternativeTitle, opt: true);
  static List<String> _$newReleases(BookEntity v) => v.newReleases;
  static const Field<BookEntity, List<String>> _f$newReleases =
      Field('newReleases', _$newReleases, opt: true, def: const []);
  static String? _$extraLarge(BookEntity v) => v.extraLarge;
  static const Field<BookEntity, String> _f$extraLarge =
      Field('extraLarge', _$extraLarge, opt: true);
  static String? _$largeImage(BookEntity v) => v.largeImage;
  static const Field<BookEntity, String> _f$largeImage =
      Field('largeImage', _$largeImage, opt: true);
  static String? _$mediumImage(BookEntity v) => v.mediumImage;
  static const Field<BookEntity, String> _f$mediumImage =
      Field('mediumImage', _$mediumImage, opt: true);
  static bool _$isFavorite(BookEntity v) => v.isFavorite;
  static const Field<BookEntity, bool> _f$isFavorite =
      Field('isFavorite', _$isFavorite, opt: true, def: false);
  static IsarLinks<ChapterEntity> _$chapters(BookEntity v) => v.chapters;
  static const Field<BookEntity, IsarLinks<ChapterEntity>> _f$chapters =
      Field('chapters', _$chapters, mode: FieldMode.member);

  @override
  final MappableFields<BookEntity> fields = const {
    #id: _f$id,
    #stringID: _f$stringID,
    #title: _f$title,
    #url: _f$url,
    #source: _f$source,
    #originalImage: _f$originalImage,
    #createdAt: _f$createdAt,
    #anilistMedia: _f$anilistMedia,
    #sinopse: _f$sinopse,
    #updatedAt: _f$updatedAt,
    #alternativeTitle: _f$alternativeTitle,
    #newReleases: _f$newReleases,
    #extraLarge: _f$extraLarge,
    #largeImage: _f$largeImage,
    #mediumImage: _f$mediumImage,
    #isFavorite: _f$isFavorite,
    #chapters: _f$chapters,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'BookEntity';
  @override
  late final ClassMapperBase superMapper =
      ContentEntityMapper.ensureInitialized();

  static BookEntity _instantiate(DecodingData data) {
    return BookEntity(
        id: data.dec(_f$id),
        stringID: data.dec(_f$stringID),
        title: data.dec(_f$title),
        url: data.dec(_f$url),
        source: data.dec(_f$source),
        originalImage: data.dec(_f$originalImage),
        createdAt: data.dec(_f$createdAt),
        anilistMedia: data.dec(_f$anilistMedia),
        sinopse: data.dec(_f$sinopse),
        updatedAt: data.dec(_f$updatedAt),
        alternativeTitle: data.dec(_f$alternativeTitle),
        newReleases: data.dec(_f$newReleases),
        extraLarge: data.dec(_f$extraLarge),
        largeImage: data.dec(_f$largeImage),
        mediumImage: data.dec(_f$mediumImage),
        isFavorite: data.dec(_f$isFavorite));
  }

  @override
  final Function instantiate = _instantiate;

  static BookEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BookEntity>(map);
  }

  static BookEntity fromJson(String json) {
    return ensureInitialized().decodeJson<BookEntity>(json);
  }
}

mixin BookEntityMappable {
  String toJson() {
    return BookEntityMapper.ensureInitialized()
        .encodeJson<BookEntity>(this as BookEntity);
  }

  Map<String, dynamic> toMap() {
    return BookEntityMapper.ensureInitialized()
        .encodeMap<BookEntity>(this as BookEntity);
  }

  BookEntityCopyWith<BookEntity, BookEntity, BookEntity> get copyWith =>
      _BookEntityCopyWithImpl(this as BookEntity, $identity, $identity);
  @override
  String toString() {
    return BookEntityMapper.ensureInitialized()
        .stringifyValue(this as BookEntity);
  }

  @override
  bool operator ==(Object other) {
    return BookEntityMapper.ensureInitialized()
        .equalsValue(this as BookEntity, other);
  }

  @override
  int get hashCode {
    return BookEntityMapper.ensureInitialized().hashValue(this as BookEntity);
  }
}

extension BookEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BookEntity, $Out> {
  BookEntityCopyWith<$R, BookEntity, $Out> get $asBookEntity =>
      $base.as((v, t, t2) => _BookEntityCopyWithImpl(v, t, t2));
}

abstract class BookEntityCopyWith<$R, $In extends BookEntity, $Out>
    implements ContentEntityCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get newReleases;
  @override
  $R call(
      {int? id,
      String? stringID,
      String? title,
      String? url,
      Source? source,
      String? originalImage,
      DateTime? createdAt,
      AniListMedia? anilistMedia,
      String? sinopse,
      DateTime? updatedAt,
      String? alternativeTitle,
      List<String>? newReleases,
      String? extraLarge,
      String? largeImage,
      String? mediumImage,
      bool? isFavorite});
  BookEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _BookEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BookEntity, $Out>
    implements BookEntityCopyWith<$R, BookEntity, $Out> {
  _BookEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BookEntity> $mapper =
      BookEntityMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
      get newReleases => ListCopyWith(
          $value.newReleases,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(newReleases: v));
  @override
  $R call(
          {int? id,
          String? stringID,
          String? title,
          String? url,
          Source? source,
          String? originalImage,
          Object? createdAt = $none,
          Object? anilistMedia = $none,
          Object? sinopse = $none,
          Object? updatedAt = $none,
          Object? alternativeTitle = $none,
          List<String>? newReleases,
          Object? extraLarge = $none,
          Object? largeImage = $none,
          Object? mediumImage = $none,
          bool? isFavorite}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (stringID != null) #stringID: stringID,
        if (title != null) #title: title,
        if (url != null) #url: url,
        if (source != null) #source: source,
        if (originalImage != null) #originalImage: originalImage,
        if (createdAt != $none) #createdAt: createdAt,
        if (anilistMedia != $none) #anilistMedia: anilistMedia,
        if (sinopse != $none) #sinopse: sinopse,
        if (updatedAt != $none) #updatedAt: updatedAt,
        if (alternativeTitle != $none) #alternativeTitle: alternativeTitle,
        if (newReleases != null) #newReleases: newReleases,
        if (extraLarge != $none) #extraLarge: extraLarge,
        if (largeImage != $none) #largeImage: largeImage,
        if (mediumImage != $none) #mediumImage: mediumImage,
        if (isFavorite != null) #isFavorite: isFavorite
      }));
  @override
  BookEntity $make(CopyWithData data) => BookEntity(
      id: data.get(#id, or: $value.id),
      stringID: data.get(#stringID, or: $value.stringID),
      title: data.get(#title, or: $value.title),
      url: data.get(#url, or: $value.url),
      source: data.get(#source, or: $value.source),
      originalImage: data.get(#originalImage, or: $value.originalImage),
      createdAt: data.get(#createdAt, or: $value.createdAt),
      anilistMedia: data.get(#anilistMedia, or: $value.anilistMedia),
      sinopse: data.get(#sinopse, or: $value.sinopse),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt),
      alternativeTitle:
          data.get(#alternativeTitle, or: $value.alternativeTitle),
      newReleases: data.get(#newReleases, or: $value.newReleases),
      extraLarge: data.get(#extraLarge, or: $value.extraLarge),
      largeImage: data.get(#largeImage, or: $value.largeImage),
      mediumImage: data.get(#mediumImage, or: $value.mediumImage),
      isFavorite: data.get(#isFavorite, or: $value.isFavorite));

  @override
  BookEntityCopyWith<$R2, BookEntity, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _BookEntityCopyWithImpl($value, $cast, t);
}
