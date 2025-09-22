// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../content.dart';

class ContentMapper extends ClassMapperBase<Content> {
  ContentMapper._();

  static ContentMapper? _instance;
  static ContentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ContentMapper._());
      ReleaseMapper.ensureInitialized();
      SourceMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Content';

  static Releases<Release> _$releases(Content v) => v.releases;
  static const Field<Content, Releases<Release>> _f$releases =
      Field('releases', _$releases);
  static List<Genre> _$genres(Content v) => v.genres;
  static const Field<Content, List<Genre>> _f$genres =
      Field('genres', _$genres, opt: true, def: const []);
  static String _$url(Content v) => v.url;
  static const Field<Content, String> _f$url = Field('url', _$url);
  static Source _$source(Content v) => v.source;
  static const Field<Content, Source> _f$source = Field('source', _$source);
  static String _$title(Content v) => v.title;
  static const Field<Content, String> _f$title = Field('title', _$title);
  static String _$sinopse(Content v) => v.sinopse;
  static const Field<Content, String> _f$sinopse =
      Field('sinopse', _$sinopse, opt: true, def: "");
  static AniListMedia? _$anilistMedia(Content v) => v.anilistMedia;
  static const Field<Content, AniListMedia> _f$anilistMedia =
      Field('anilistMedia', _$anilistMedia, opt: true);

  @override
  final MappableFields<Content> fields = const {
    #releases: _f$releases,
    #genres: _f$genres,
    #url: _f$url,
    #source: _f$source,
    #title: _f$title,
    #sinopse: _f$sinopse,
    #anilistMedia: _f$anilistMedia,
  };

  static Content _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('Content');
  }

  @override
  final Function instantiate = _instantiate;

  static Content fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Content>(map);
  }

  static Content fromJson(String json) {
    return ensureInitialized().decodeJson<Content>(json);
  }
}

mixin ContentMappable {
  String toJson();
  Map<String, dynamic> toMap();
  ContentCopyWith<Content, Content, Content> get copyWith;
}

abstract class ContentCopyWith<$R, $In extends Content, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Genre, ObjectCopyWith<$R, Genre, Genre>> get genres;
  $R call(
      {Releases<Release>? releases,
      List<Genre>? genres,
      String? url,
      Source? source,
      String? title,
      String? sinopse,
      AniListMedia? anilistMedia});
  ContentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}
