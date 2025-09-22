// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../anime_entity.dart';

class AnimeEntityMapper extends SubClassMapperBase<AnimeEntity> {
  AnimeEntityMapper._();

  static AnimeEntityMapper? _instance;
  static AnimeEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AnimeEntityMapper._());
      ContentEntityMapper.ensureInitialized().addSubMapper(_instance!);
      SourceMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AnimeEntity';

  static int _$id(AnimeEntity v) => v.id;
  static const Field<AnimeEntity, int> _f$id =
      Field('id', _$id, opt: true, def: Isar.autoIncrement);
  static String _$stringID(AnimeEntity v) => v.stringID;
  static const Field<AnimeEntity, String> _f$stringID =
      Field('stringID', _$stringID);
  static String _$url(AnimeEntity v) => v.url;
  static const Field<AnimeEntity, String> _f$url = Field('url', _$url);
  static String _$title(AnimeEntity v) => v.title;
  static const Field<AnimeEntity, String> _f$title = Field('title', _$title);
  static Source _$source(AnimeEntity v) => v.source;
  static const Field<AnimeEntity, Source> _f$source = Field('source', _$source);
  static AniListMedia? _$anilistMedia(AnimeEntity v) => v.anilistMedia;
  static const Field<AnimeEntity, AniListMedia> _f$anilistMedia =
      Field('anilistMedia', _$anilistMedia, opt: true);
  static List<String> _$newReleases(AnimeEntity v) => v.newReleases;
  static const Field<AnimeEntity, List<String>> _f$newReleases =
      Field('newReleases', _$newReleases, opt: true, def: const []);
  static DateTime? _$createdAt(AnimeEntity v) => v.createdAt;
  static const Field<AnimeEntity, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, opt: true);
  static int? _$totalOfEpisodes(AnimeEntity v) => v.totalOfEpisodes;
  static const Field<AnimeEntity, int> _f$totalOfEpisodes =
      Field('totalOfEpisodes', _$totalOfEpisodes, opt: true);
  static String? _$animeID(AnimeEntity v) => v.animeID;
  static const Field<AnimeEntity, String> _f$animeID =
      Field('animeID', _$animeID, opt: true);
  static int? _$totalOfPages(AnimeEntity v) => v.totalOfPages;
  static const Field<AnimeEntity, int> _f$totalOfPages =
      Field('totalOfPages', _$totalOfPages, opt: true);
  static bool _$isDublado(AnimeEntity v) => v.isDublado;
  static const Field<AnimeEntity, bool> _f$isDublado =
      Field('isDublado', _$isDublado, opt: true, def: false);
  static String? _$slugSerie(AnimeEntity v) => v.slugSerie;
  static const Field<AnimeEntity, String> _f$slugSerie =
      Field('slugSerie', _$slugSerie, opt: true);
  static DateTime? _$updatedAt(AnimeEntity v) => v.updatedAt;
  static const Field<AnimeEntity, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, opt: true);
  static String? _$sinopse(AnimeEntity v) => v.sinopse;
  static const Field<AnimeEntity, String> _f$sinopse =
      Field('sinopse', _$sinopse, opt: true);
  static String? _$generateID(AnimeEntity v) => v.generateID;
  static const Field<AnimeEntity, String> _f$generateID =
      Field('generateID', _$generateID, opt: true);
  static bool _$isFavorite(AnimeEntity v) => v.isFavorite;
  static const Field<AnimeEntity, bool> _f$isFavorite =
      Field('isFavorite', _$isFavorite, opt: true, def: false);
  static String _$originalImage(AnimeEntity v) => v.originalImage;
  static const Field<AnimeEntity, String> _f$originalImage =
      Field('originalImage', _$originalImage);
  static String? _$extraLarge(AnimeEntity v) => v.extraLarge;
  static const Field<AnimeEntity, String> _f$extraLarge =
      Field('extraLarge', _$extraLarge, opt: true);
  static String? _$largeImage(AnimeEntity v) => v.largeImage;
  static const Field<AnimeEntity, String> _f$largeImage =
      Field('largeImage', _$largeImage, opt: true);
  static String? _$mediumImage(AnimeEntity v) => v.mediumImage;
  static const Field<AnimeEntity, String> _f$mediumImage =
      Field('mediumImage', _$mediumImage, opt: true);
  static IsarLinks<EpisodeEntity> _$episodes(AnimeEntity v) => v.episodes;
  static const Field<AnimeEntity, IsarLinks<EpisodeEntity>> _f$episodes =
      Field('episodes', _$episodes, mode: FieldMode.member);

  @override
  final MappableFields<AnimeEntity> fields = const {
    #id: _f$id,
    #stringID: _f$stringID,
    #url: _f$url,
    #title: _f$title,
    #source: _f$source,
    #anilistMedia: _f$anilistMedia,
    #newReleases: _f$newReleases,
    #createdAt: _f$createdAt,
    #totalOfEpisodes: _f$totalOfEpisodes,
    #animeID: _f$animeID,
    #totalOfPages: _f$totalOfPages,
    #isDublado: _f$isDublado,
    #slugSerie: _f$slugSerie,
    #updatedAt: _f$updatedAt,
    #sinopse: _f$sinopse,
    #generateID: _f$generateID,
    #isFavorite: _f$isFavorite,
    #originalImage: _f$originalImage,
    #extraLarge: _f$extraLarge,
    #largeImage: _f$largeImage,
    #mediumImage: _f$mediumImage,
    #episodes: _f$episodes,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'AnimeEntity';
  @override
  late final ClassMapperBase superMapper =
      ContentEntityMapper.ensureInitialized();

  static AnimeEntity _instantiate(DecodingData data) {
    return AnimeEntity(
        id: data.dec(_f$id),
        stringID: data.dec(_f$stringID),
        url: data.dec(_f$url),
        title: data.dec(_f$title),
        source: data.dec(_f$source),
        anilistMedia: data.dec(_f$anilistMedia),
        newReleases: data.dec(_f$newReleases),
        createdAt: data.dec(_f$createdAt),
        totalOfEpisodes: data.dec(_f$totalOfEpisodes),
        animeID: data.dec(_f$animeID),
        totalOfPages: data.dec(_f$totalOfPages),
        isDublado: data.dec(_f$isDublado),
        slugSerie: data.dec(_f$slugSerie),
        updatedAt: data.dec(_f$updatedAt),
        sinopse: data.dec(_f$sinopse),
        generateID: data.dec(_f$generateID),
        isFavorite: data.dec(_f$isFavorite),
        originalImage: data.dec(_f$originalImage),
        extraLarge: data.dec(_f$extraLarge),
        largeImage: data.dec(_f$largeImage),
        mediumImage: data.dec(_f$mediumImage));
  }

  @override
  final Function instantiate = _instantiate;

  static AnimeEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AnimeEntity>(map);
  }

  static AnimeEntity fromJson(String json) {
    return ensureInitialized().decodeJson<AnimeEntity>(json);
  }
}

mixin AnimeEntityMappable {
  String toJson() {
    return AnimeEntityMapper.ensureInitialized()
        .encodeJson<AnimeEntity>(this as AnimeEntity);
  }

  Map<String, dynamic> toMap() {
    return AnimeEntityMapper.ensureInitialized()
        .encodeMap<AnimeEntity>(this as AnimeEntity);
  }

  AnimeEntityCopyWith<AnimeEntity, AnimeEntity, AnimeEntity> get copyWith =>
      _AnimeEntityCopyWithImpl(this as AnimeEntity, $identity, $identity);
  @override
  String toString() {
    return AnimeEntityMapper.ensureInitialized()
        .stringifyValue(this as AnimeEntity);
  }

  @override
  bool operator ==(Object other) {
    return AnimeEntityMapper.ensureInitialized()
        .equalsValue(this as AnimeEntity, other);
  }

  @override
  int get hashCode {
    return AnimeEntityMapper.ensureInitialized().hashValue(this as AnimeEntity);
  }
}

extension AnimeEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AnimeEntity, $Out> {
  AnimeEntityCopyWith<$R, AnimeEntity, $Out> get $asAnimeEntity =>
      $base.as((v, t, t2) => _AnimeEntityCopyWithImpl(v, t, t2));
}

abstract class AnimeEntityCopyWith<$R, $In extends AnimeEntity, $Out>
    implements ContentEntityCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get newReleases;
  @override
  $R call(
      {int? id,
      String? stringID,
      String? url,
      String? title,
      Source? source,
      AniListMedia? anilistMedia,
      List<String>? newReleases,
      DateTime? createdAt,
      int? totalOfEpisodes,
      String? animeID,
      int? totalOfPages,
      bool? isDublado,
      String? slugSerie,
      DateTime? updatedAt,
      String? sinopse,
      String? generateID,
      bool? isFavorite,
      String? originalImage,
      String? extraLarge,
      String? largeImage,
      String? mediumImage});
  AnimeEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AnimeEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AnimeEntity, $Out>
    implements AnimeEntityCopyWith<$R, AnimeEntity, $Out> {
  _AnimeEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AnimeEntity> $mapper =
      AnimeEntityMapper.ensureInitialized();
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
          String? url,
          String? title,
          Source? source,
          Object? anilistMedia = $none,
          List<String>? newReleases,
          Object? createdAt = $none,
          Object? totalOfEpisodes = $none,
          Object? animeID = $none,
          Object? totalOfPages = $none,
          bool? isDublado,
          Object? slugSerie = $none,
          Object? updatedAt = $none,
          Object? sinopse = $none,
          Object? generateID = $none,
          bool? isFavorite,
          String? originalImage,
          Object? extraLarge = $none,
          Object? largeImage = $none,
          Object? mediumImage = $none}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (stringID != null) #stringID: stringID,
        if (url != null) #url: url,
        if (title != null) #title: title,
        if (source != null) #source: source,
        if (anilistMedia != $none) #anilistMedia: anilistMedia,
        if (newReleases != null) #newReleases: newReleases,
        if (createdAt != $none) #createdAt: createdAt,
        if (totalOfEpisodes != $none) #totalOfEpisodes: totalOfEpisodes,
        if (animeID != $none) #animeID: animeID,
        if (totalOfPages != $none) #totalOfPages: totalOfPages,
        if (isDublado != null) #isDublado: isDublado,
        if (slugSerie != $none) #slugSerie: slugSerie,
        if (updatedAt != $none) #updatedAt: updatedAt,
        if (sinopse != $none) #sinopse: sinopse,
        if (generateID != $none) #generateID: generateID,
        if (isFavorite != null) #isFavorite: isFavorite,
        if (originalImage != null) #originalImage: originalImage,
        if (extraLarge != $none) #extraLarge: extraLarge,
        if (largeImage != $none) #largeImage: largeImage,
        if (mediumImage != $none) #mediumImage: mediumImage
      }));
  @override
  AnimeEntity $make(CopyWithData data) => AnimeEntity(
      id: data.get(#id, or: $value.id),
      stringID: data.get(#stringID, or: $value.stringID),
      url: data.get(#url, or: $value.url),
      title: data.get(#title, or: $value.title),
      source: data.get(#source, or: $value.source),
      anilistMedia: data.get(#anilistMedia, or: $value.anilistMedia),
      newReleases: data.get(#newReleases, or: $value.newReleases),
      createdAt: data.get(#createdAt, or: $value.createdAt),
      totalOfEpisodes: data.get(#totalOfEpisodes, or: $value.totalOfEpisodes),
      animeID: data.get(#animeID, or: $value.animeID),
      totalOfPages: data.get(#totalOfPages, or: $value.totalOfPages),
      isDublado: data.get(#isDublado, or: $value.isDublado),
      slugSerie: data.get(#slugSerie, or: $value.slugSerie),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt),
      sinopse: data.get(#sinopse, or: $value.sinopse),
      generateID: data.get(#generateID, or: $value.generateID),
      isFavorite: data.get(#isFavorite, or: $value.isFavorite),
      originalImage: data.get(#originalImage, or: $value.originalImage),
      extraLarge: data.get(#extraLarge, or: $value.extraLarge),
      largeImage: data.get(#largeImage, or: $value.largeImage),
      mediumImage: data.get(#mediumImage, or: $value.mediumImage));

  @override
  AnimeEntityCopyWith<$R2, AnimeEntity, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _AnimeEntityCopyWithImpl($value, $cast, t);
}
