// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../episode.dart';

class EpisodeMapper extends SubClassMapperBase<Episode> {
  EpisodeMapper._();

  static EpisodeMapper? _instance;
  static EpisodeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EpisodeMapper._());
      ReleaseMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'Episode';

  static String _$url(Episode v) => v.url;
  static const Field<Episode, String> _f$url = Field('url', _$url);
  static String _$title(Episode v) => v.title;
  static const Field<Episode, String> _f$title = Field('title', _$title);
  static String? _$generateID(Episode v) => v.generateID;
  static const Field<Episode, String> _f$generateID =
      Field('generateID', _$generateID, opt: true);
  static String? _$slugSerie(Episode v) => v.slugSerie;
  static const Field<Episode, String> _f$slugSerie =
      Field('slugSerie', _$slugSerie, opt: true);
  static int? _$numberEpisode(Episode v) => v.numberEpisode;
  static const Field<Episode, int> _f$numberEpisode =
      Field('numberEpisode', _$numberEpisode, opt: true);
  static int? _$pageNumber(Episode v) => v.pageNumber;
  static const Field<Episode, int> _f$pageNumber =
      Field('pageNumber', _$pageNumber, opt: true);
  static DateTime? _$registrationData(Episode v) => v.registrationData;
  static const Field<Episode, DateTime> _f$registrationData =
      Field('registrationData', _$registrationData, opt: true);
  static String? _$sinopse(Episode v) => v.sinopse;
  static const Field<Episode, String> _f$sinopse =
      Field('sinopse', _$sinopse, opt: true);
  static String? _$thumbnail(Episode v) => v.thumbnail;
  static const Field<Episode, String> _f$thumbnail =
      Field('thumbnail', _$thumbnail, opt: true);
  static bool _$isDublado(Episode v) => v.isDublado;
  static const Field<Episode, bool> _f$isDublado =
      Field('isDublado', _$isDublado);

  @override
  final MappableFields<Episode> fields = const {
    #url: _f$url,
    #title: _f$title,
    #generateID: _f$generateID,
    #slugSerie: _f$slugSerie,
    #numberEpisode: _f$numberEpisode,
    #pageNumber: _f$pageNumber,
    #registrationData: _f$registrationData,
    #sinopse: _f$sinopse,
    #thumbnail: _f$thumbnail,
    #isDublado: _f$isDublado,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'Episode';
  @override
  late final ClassMapperBase superMapper = ReleaseMapper.ensureInitialized();

  static Episode _instantiate(DecodingData data) {
    return Episode(
        url: data.dec(_f$url),
        title: data.dec(_f$title),
        generateID: data.dec(_f$generateID),
        slugSerie: data.dec(_f$slugSerie),
        numberEpisode: data.dec(_f$numberEpisode),
        pageNumber: data.dec(_f$pageNumber),
        registrationData: data.dec(_f$registrationData),
        sinopse: data.dec(_f$sinopse),
        thumbnail: data.dec(_f$thumbnail),
        isDublado: data.dec(_f$isDublado));
  }

  @override
  final Function instantiate = _instantiate;

  static Episode fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Episode>(map);
  }

  static Episode fromJson(String json) {
    return ensureInitialized().decodeJson<Episode>(json);
  }
}

mixin EpisodeMappable {
  String toJson() {
    return EpisodeMapper.ensureInitialized()
        .encodeJson<Episode>(this as Episode);
  }

  Map<String, dynamic> toMap() {
    return EpisodeMapper.ensureInitialized()
        .encodeMap<Episode>(this as Episode);
  }

  EpisodeCopyWith<Episode, Episode, Episode> get copyWith =>
      _EpisodeCopyWithImpl(this as Episode, $identity, $identity);
  @override
  String toString() {
    return EpisodeMapper.ensureInitialized().stringifyValue(this as Episode);
  }

  @override
  bool operator ==(Object other) {
    return EpisodeMapper.ensureInitialized()
        .equalsValue(this as Episode, other);
  }

  @override
  int get hashCode {
    return EpisodeMapper.ensureInitialized().hashValue(this as Episode);
  }
}

extension EpisodeValueCopy<$R, $Out> on ObjectCopyWith<$R, Episode, $Out> {
  EpisodeCopyWith<$R, Episode, $Out> get $asEpisode =>
      $base.as((v, t, t2) => _EpisodeCopyWithImpl(v, t, t2));
}

abstract class EpisodeCopyWith<$R, $In extends Episode, $Out>
    implements ReleaseCopyWith<$R, $In, $Out> {
  @override
  $R call(
      {String? url,
      String? title,
      String? generateID,
      String? slugSerie,
      int? numberEpisode,
      int? pageNumber,
      DateTime? registrationData,
      String? sinopse,
      String? thumbnail,
      bool? isDublado});
  EpisodeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _EpisodeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Episode, $Out>
    implements EpisodeCopyWith<$R, Episode, $Out> {
  _EpisodeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Episode> $mapper =
      EpisodeMapper.ensureInitialized();
  @override
  $R call(
          {String? url,
          String? title,
          Object? generateID = $none,
          Object? slugSerie = $none,
          Object? numberEpisode = $none,
          Object? pageNumber = $none,
          Object? registrationData = $none,
          Object? sinopse = $none,
          Object? thumbnail = $none,
          bool? isDublado}) =>
      $apply(FieldCopyWithData({
        if (url != null) #url: url,
        if (title != null) #title: title,
        if (generateID != $none) #generateID: generateID,
        if (slugSerie != $none) #slugSerie: slugSerie,
        if (numberEpisode != $none) #numberEpisode: numberEpisode,
        if (pageNumber != $none) #pageNumber: pageNumber,
        if (registrationData != $none) #registrationData: registrationData,
        if (sinopse != $none) #sinopse: sinopse,
        if (thumbnail != $none) #thumbnail: thumbnail,
        if (isDublado != null) #isDublado: isDublado
      }));
  @override
  Episode $make(CopyWithData data) => Episode(
      url: data.get(#url, or: $value.url),
      title: data.get(#title, or: $value.title),
      generateID: data.get(#generateID, or: $value.generateID),
      slugSerie: data.get(#slugSerie, or: $value.slugSerie),
      numberEpisode: data.get(#numberEpisode, or: $value.numberEpisode),
      pageNumber: data.get(#pageNumber, or: $value.pageNumber),
      registrationData:
          data.get(#registrationData, or: $value.registrationData),
      sinopse: data.get(#sinopse, or: $value.sinopse),
      thumbnail: data.get(#thumbnail, or: $value.thumbnail),
      isDublado: data.get(#isDublado, or: $value.isDublado));

  @override
  EpisodeCopyWith<$R2, Episode, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _EpisodeCopyWithImpl($value, $cast, t);
}
