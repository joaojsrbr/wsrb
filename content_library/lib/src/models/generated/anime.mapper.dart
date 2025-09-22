// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../anime.dart';

class AnimeMapper extends SubClassMapperBase<Anime> {
  AnimeMapper._();

  static AnimeMapper? _instance;
  static AnimeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AnimeMapper._());
      ContentMapper.ensureInitialized().addSubMapper(_instance!);
      SourceMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Anime';

  static String _$url(Anime v) => v.url;
  static const Field<Anime, String> _f$url = Field('url', _$url);
  static String _$title(Anime v) => v.title;
  static const Field<Anime, String> _f$title = Field('title', _$title);
  static AniListMedia? _$anilistMedia(Anime v) => v.anilistMedia;
  static const Field<Anime, AniListMedia> _f$anilistMedia =
      Field('anilistMedia', _$anilistMedia, opt: true);
  static Releases<Release> _$releases(Anime v) => v.releases;
  static dynamic _arg$releases(f) => f<Releases<Release>>();
  static const Field<Anime, EpisodeReleases> _f$releases =
      Field('releases', _$releases, arg: _arg$releases);
  static Source _$source(Anime v) => v.source;
  static const Field<Anime, Source> _f$source = Field('source', _$source);
  static String _$originalImage(Anime v) => v.originalImage;
  static const Field<Anime, String> _f$originalImage =
      Field('originalImage', _$originalImage);
  static String? _$slugSerie(Anime v) => v.slugSerie;
  static const Field<Anime, String> _f$slugSerie =
      Field('slugSerie', _$slugSerie, opt: true);
  static String? _$buildId(Anime v) => v.buildId;
  static const Field<Anime, String> _f$buildId =
      Field('buildId', _$buildId, opt: true);
  static String? _$extraLarge(Anime v) => v.extraLarge;
  static const Field<Anime, String> _f$extraLarge =
      Field('extraLarge', _$extraLarge, opt: true);
  static String? _$mediumImage(Anime v) => v.mediumImage;
  static const Field<Anime, String> _f$mediumImage =
      Field('mediumImage', _$mediumImage, opt: true);
  static String? _$animeID(Anime v) => v.animeID;
  static const Field<Anime, String> _f$animeID =
      Field('animeID', _$animeID, opt: true);
  static int? _$totalOfEpisodes(Anime v) => v.totalOfEpisodes;
  static const Field<Anime, int> _f$totalOfEpisodes =
      Field('totalOfEpisodes', _$totalOfEpisodes, opt: true);
  static AnimeSkip? _$animeSkip(Anime v) => v.animeSkip;
  static const Field<Anime, AnimeSkip> _f$animeSkip =
      Field('animeSkip', _$animeSkip, opt: true);
  static int? _$totalOfPages(Anime v) => v.totalOfPages;
  static const Field<Anime, int> _f$totalOfPages =
      Field('totalOfPages', _$totalOfPages, opt: true);
  static String? _$largeImage(Anime v) => v.largeImage;
  static const Field<Anime, String> _f$largeImage =
      Field('largeImage', _$largeImage, opt: true);
  static String? _$generateID(Anime v) => v.generateID;
  static const Field<Anime, String> _f$generateID =
      Field('generateID', _$generateID, opt: true);
  static bool _$isDublado(Anime v) => v.isDublado;
  static const Field<Anime, bool> _f$isDublado =
      Field('isDublado', _$isDublado, opt: true, def: false);
  static String _$sinopse(Anime v) => v.sinopse;
  static const Field<Anime, String> _f$sinopse =
      Field('sinopse', _$sinopse, opt: true, def: "");
  static List<Genre> _$genres(Anime v) => v.genres;
  static const Field<Anime, List<Genre>> _f$genres =
      Field('genres', _$genres, opt: true, def: const []);

  @override
  final MappableFields<Anime> fields = const {
    #url: _f$url,
    #title: _f$title,
    #anilistMedia: _f$anilistMedia,
    #releases: _f$releases,
    #source: _f$source,
    #originalImage: _f$originalImage,
    #slugSerie: _f$slugSerie,
    #buildId: _f$buildId,
    #extraLarge: _f$extraLarge,
    #mediumImage: _f$mediumImage,
    #animeID: _f$animeID,
    #totalOfEpisodes: _f$totalOfEpisodes,
    #animeSkip: _f$animeSkip,
    #totalOfPages: _f$totalOfPages,
    #largeImage: _f$largeImage,
    #generateID: _f$generateID,
    #isDublado: _f$isDublado,
    #sinopse: _f$sinopse,
    #genres: _f$genres,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'Anime';
  @override
  late final ClassMapperBase superMapper = ContentMapper.ensureInitialized();

  static Anime _instantiate(DecodingData data) {
    return Anime(
        url: data.dec(_f$url),
        title: data.dec(_f$title),
        anilistMedia: data.dec(_f$anilistMedia),
        releases: data.dec(_f$releases),
        source: data.dec(_f$source),
        originalImage: data.dec(_f$originalImage),
        slugSerie: data.dec(_f$slugSerie),
        buildId: data.dec(_f$buildId),
        extraLarge: data.dec(_f$extraLarge),
        mediumImage: data.dec(_f$mediumImage),
        animeID: data.dec(_f$animeID),
        totalOfEpisodes: data.dec(_f$totalOfEpisodes),
        animeSkip: data.dec(_f$animeSkip),
        totalOfPages: data.dec(_f$totalOfPages),
        largeImage: data.dec(_f$largeImage),
        generateID: data.dec(_f$generateID),
        isDublado: data.dec(_f$isDublado),
        sinopse: data.dec(_f$sinopse),
        genres: data.dec(_f$genres));
  }

  @override
  final Function instantiate = _instantiate;

  static Anime fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Anime>(map);
  }

  static Anime fromJson(String json) {
    return ensureInitialized().decodeJson<Anime>(json);
  }
}

mixin AnimeMappable {
  String toJson() {
    return AnimeMapper.ensureInitialized().encodeJson<Anime>(this as Anime);
  }

  Map<String, dynamic> toMap() {
    return AnimeMapper.ensureInitialized().encodeMap<Anime>(this as Anime);
  }

  AnimeCopyWith<Anime, Anime, Anime> get copyWith =>
      _AnimeCopyWithImpl(this as Anime, $identity, $identity);
  @override
  String toString() {
    return AnimeMapper.ensureInitialized().stringifyValue(this as Anime);
  }

  @override
  bool operator ==(Object other) {
    return AnimeMapper.ensureInitialized().equalsValue(this as Anime, other);
  }

  @override
  int get hashCode {
    return AnimeMapper.ensureInitialized().hashValue(this as Anime);
  }
}

extension AnimeValueCopy<$R, $Out> on ObjectCopyWith<$R, Anime, $Out> {
  AnimeCopyWith<$R, Anime, $Out> get $asAnime =>
      $base.as((v, t, t2) => _AnimeCopyWithImpl(v, t, t2));
}

abstract class AnimeCopyWith<$R, $In extends Anime, $Out>
    implements ContentCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, Genre, ObjectCopyWith<$R, Genre, Genre>> get genres;
  @override
  $R call(
      {String? url,
      String? title,
      AniListMedia? anilistMedia,
      covariant EpisodeReleases? releases,
      Source? source,
      String? originalImage,
      String? slugSerie,
      String? buildId,
      String? extraLarge,
      String? mediumImage,
      String? animeID,
      int? totalOfEpisodes,
      AnimeSkip? animeSkip,
      int? totalOfPages,
      String? largeImage,
      String? generateID,
      bool? isDublado,
      String? sinopse,
      List<Genre>? genres});
  AnimeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AnimeCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Anime, $Out>
    implements AnimeCopyWith<$R, Anime, $Out> {
  _AnimeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Anime> $mapper = AnimeMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Genre, ObjectCopyWith<$R, Genre, Genre>> get genres =>
      ListCopyWith($value.genres, (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(genres: v));
  @override
  $R call(
          {String? url,
          String? title,
          Object? anilistMedia = $none,
          EpisodeReleases? releases,
          Source? source,
          String? originalImage,
          Object? slugSerie = $none,
          Object? buildId = $none,
          Object? extraLarge = $none,
          Object? mediumImage = $none,
          Object? animeID = $none,
          Object? totalOfEpisodes = $none,
          Object? animeSkip = $none,
          Object? totalOfPages = $none,
          Object? largeImage = $none,
          Object? generateID = $none,
          bool? isDublado,
          String? sinopse,
          List<Genre>? genres}) =>
      $apply(FieldCopyWithData({
        if (url != null) #url: url,
        if (title != null) #title: title,
        if (anilistMedia != $none) #anilistMedia: anilistMedia,
        if (releases != null) #releases: releases,
        if (source != null) #source: source,
        if (originalImage != null) #originalImage: originalImage,
        if (slugSerie != $none) #slugSerie: slugSerie,
        if (buildId != $none) #buildId: buildId,
        if (extraLarge != $none) #extraLarge: extraLarge,
        if (mediumImage != $none) #mediumImage: mediumImage,
        if (animeID != $none) #animeID: animeID,
        if (totalOfEpisodes != $none) #totalOfEpisodes: totalOfEpisodes,
        if (animeSkip != $none) #animeSkip: animeSkip,
        if (totalOfPages != $none) #totalOfPages: totalOfPages,
        if (largeImage != $none) #largeImage: largeImage,
        if (generateID != $none) #generateID: generateID,
        if (isDublado != null) #isDublado: isDublado,
        if (sinopse != null) #sinopse: sinopse,
        if (genres != null) #genres: genres
      }));
  @override
  Anime $make(CopyWithData data) => Anime(
      url: data.get(#url, or: $value.url),
      title: data.get(#title, or: $value.title),
      anilistMedia: data.get(#anilistMedia, or: $value.anilistMedia),
      releases: data.get(#releases, or: $value.releases),
      source: data.get(#source, or: $value.source),
      originalImage: data.get(#originalImage, or: $value.originalImage),
      slugSerie: data.get(#slugSerie, or: $value.slugSerie),
      buildId: data.get(#buildId, or: $value.buildId),
      extraLarge: data.get(#extraLarge, or: $value.extraLarge),
      mediumImage: data.get(#mediumImage, or: $value.mediumImage),
      animeID: data.get(#animeID, or: $value.animeID),
      totalOfEpisodes: data.get(#totalOfEpisodes, or: $value.totalOfEpisodes),
      animeSkip: data.get(#animeSkip, or: $value.animeSkip),
      totalOfPages: data.get(#totalOfPages, or: $value.totalOfPages),
      largeImage: data.get(#largeImage, or: $value.largeImage),
      generateID: data.get(#generateID, or: $value.generateID),
      isDublado: data.get(#isDublado, or: $value.isDublado),
      sinopse: data.get(#sinopse, or: $value.sinopse),
      genres: data.get(#genres, or: $value.genres));

  @override
  AnimeCopyWith<$R2, Anime, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _AnimeCopyWithImpl($value, $cast, t);
}
