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
      RepositoryStatusMapper.ensureInitialized();
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
  static bool _$isMovie(Content v) => v.isMovie;
  static const Field<Content, bool> _f$isMovie =
      Field('isMovie', _$isMovie, opt: true, def: false);
  static String _$sinopse(Content v) => v.sinopse;
  static const Field<Content, String> _f$sinopse =
      Field('sinopse', _$sinopse, opt: true, def: "");
  static AniListMedia? _$anilistMedia(Content v) => v.anilistMedia;
  static const Field<Content, AniListMedia> _f$anilistMedia =
      Field('anilistMedia', _$anilistMedia, opt: true);
  static RepositoryStatus _$repoStatus(Content v) => v.repoStatus;
  static const Field<Content, RepositoryStatus> _f$repoStatus = Field(
      'repoStatus', _$repoStatus,
      opt: true, def: const RepositoryStatus());

  @override
  final MappableFields<Content> fields = const {
    #releases: _f$releases,
    #genres: _f$genres,
    #url: _f$url,
    #source: _f$source,
    #title: _f$title,
    #isMovie: _f$isMovie,
    #sinopse: _f$sinopse,
    #anilistMedia: _f$anilistMedia,
    #repoStatus: _f$repoStatus,
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
  RepositoryStatusCopyWith<$R, RepositoryStatus, RepositoryStatus>
      get repoStatus;
  $R call(
      {Releases<Release>? releases,
      List<Genre>? genres,
      String? url,
      Source? source,
      String? title,
      bool? isMovie,
      String? sinopse,
      AniListMedia? anilistMedia,
      RepositoryStatus? repoStatus});
  ContentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class RepositoryStatusMapper extends ClassMapperBase<RepositoryStatus> {
  RepositoryStatusMapper._();

  static RepositoryStatusMapper? _instance;
  static RepositoryStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RepositoryStatusMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'RepositoryStatus';

  static bool _$loadData(RepositoryStatus v) => v.loadData;
  static const Field<RepositoryStatus, bool> _f$loadData =
      Field('loadData', _$loadData, opt: true, def: false);
  static bool _$getData(RepositoryStatus v) => v.getData;
  static const Field<RepositoryStatus, bool> _f$getData =
      Field('getData', _$getData, opt: true, def: false);
  static bool _$getReleases(RepositoryStatus v) => v.getReleases;
  static const Field<RepositoryStatus, bool> _f$getReleases =
      Field('getReleases', _$getReleases, opt: true, def: false);
  static bool _$searchContents(RepositoryStatus v) => v.searchContents;
  static const Field<RepositoryStatus, bool> _f$searchContents =
      Field('searchContents', _$searchContents, opt: true, def: false);

  @override
  final MappableFields<RepositoryStatus> fields = const {
    #loadData: _f$loadData,
    #getData: _f$getData,
    #getReleases: _f$getReleases,
    #searchContents: _f$searchContents,
  };

  static RepositoryStatus _instantiate(DecodingData data) {
    return RepositoryStatus(
        loadData: data.dec(_f$loadData),
        getData: data.dec(_f$getData),
        getReleases: data.dec(_f$getReleases),
        searchContents: data.dec(_f$searchContents));
  }

  @override
  final Function instantiate = _instantiate;

  static RepositoryStatus fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RepositoryStatus>(map);
  }

  static RepositoryStatus fromJson(String json) {
    return ensureInitialized().decodeJson<RepositoryStatus>(json);
  }
}

mixin RepositoryStatusMappable {
  String toJson() {
    return RepositoryStatusMapper.ensureInitialized()
        .encodeJson<RepositoryStatus>(this as RepositoryStatus);
  }

  Map<String, dynamic> toMap() {
    return RepositoryStatusMapper.ensureInitialized()
        .encodeMap<RepositoryStatus>(this as RepositoryStatus);
  }

  RepositoryStatusCopyWith<RepositoryStatus, RepositoryStatus, RepositoryStatus>
      get copyWith => _RepositoryStatusCopyWithImpl(
          this as RepositoryStatus, $identity, $identity);
  @override
  String toString() {
    return RepositoryStatusMapper.ensureInitialized()
        .stringifyValue(this as RepositoryStatus);
  }

  @override
  bool operator ==(Object other) {
    return RepositoryStatusMapper.ensureInitialized()
        .equalsValue(this as RepositoryStatus, other);
  }

  @override
  int get hashCode {
    return RepositoryStatusMapper.ensureInitialized()
        .hashValue(this as RepositoryStatus);
  }
}

extension RepositoryStatusValueCopy<$R, $Out>
    on ObjectCopyWith<$R, RepositoryStatus, $Out> {
  RepositoryStatusCopyWith<$R, RepositoryStatus, $Out>
      get $asRepositoryStatus =>
          $base.as((v, t, t2) => _RepositoryStatusCopyWithImpl(v, t, t2));
}

abstract class RepositoryStatusCopyWith<$R, $In extends RepositoryStatus, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {bool? loadData, bool? getData, bool? getReleases, bool? searchContents});
  RepositoryStatusCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _RepositoryStatusCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RepositoryStatus, $Out>
    implements RepositoryStatusCopyWith<$R, RepositoryStatus, $Out> {
  _RepositoryStatusCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RepositoryStatus> $mapper =
      RepositoryStatusMapper.ensureInitialized();
  @override
  $R call(
          {bool? loadData,
          bool? getData,
          bool? getReleases,
          bool? searchContents}) =>
      $apply(FieldCopyWithData({
        if (loadData != null) #loadData: loadData,
        if (getData != null) #getData: getData,
        if (getReleases != null) #getReleases: getReleases,
        if (searchContents != null) #searchContents: searchContents
      }));
  @override
  RepositoryStatus $make(CopyWithData data) => RepositoryStatus(
      loadData: data.get(#loadData, or: $value.loadData),
      getData: data.get(#getData, or: $value.getData),
      getReleases: data.get(#getReleases, or: $value.getReleases),
      searchContents: data.get(#searchContents, or: $value.searchContents));

  @override
  RepositoryStatusCopyWith<$R2, RepositoryStatus, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _RepositoryStatusCopyWithImpl($value, $cast, t);
}
