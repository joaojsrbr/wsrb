// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../release.dart';

class ReleaseMapper extends ClassMapperBase<Release> {
  ReleaseMapper._();

  static ReleaseMapper? _instance;
  static ReleaseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ReleaseMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Release';

  static String _$url(Release v) => v.url;
  static const Field<Release, String> _f$url = Field('url', _$url);
  static String _$title(Release v) => v.title;
  static const Field<Release, String> _f$title = Field('title', _$title);
  static int? _$numberEpisode(Release v) => v.numberEpisode;
  static const Field<Release, int> _f$numberEpisode =
      Field('numberEpisode', _$numberEpisode, opt: true);

  @override
  final MappableFields<Release> fields = const {
    #url: _f$url,
    #title: _f$title,
    #numberEpisode: _f$numberEpisode,
  };

  static Release _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('Release');
  }

  @override
  final Function instantiate = _instantiate;

  static Release fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Release>(map);
  }

  static Release fromJson(String json) {
    return ensureInitialized().decodeJson<Release>(json);
  }
}

mixin ReleaseMappable {
  String toJson();
  Map<String, dynamic> toMap();
  ReleaseCopyWith<Release, Release, Release> get copyWith;
}

abstract class ReleaseCopyWith<$R, $In extends Release, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? url, String? title, int? numberEpisode});
  ReleaseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}
