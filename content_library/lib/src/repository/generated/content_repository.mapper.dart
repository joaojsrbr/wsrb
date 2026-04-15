// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../content_repository.dart';

class SourceMapper extends EnumMapper<Source> {
  SourceMapper._();

  static SourceMapper? _instance;
  static SourceMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SourceMapper._());
    }
    return _instance!;
  }

  static Source fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  Source decode(dynamic value) {
    switch (value) {
      case 'GOYABU':
        return Source.GOYABU;
      case 'TOP_ANIMES':
        return Source.TOP_ANIMES;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(Source self) {
    switch (self) {
      case Source.GOYABU:
        return 'GOYABU';
      case Source.TOP_ANIMES:
        return 'TOP_ANIMES';
    }
  }
}

extension SourceMapperExtension on Source {
  String toValue() {
    SourceMapper.ensureInitialized();
    return MapperContainer.globals.toValue<Source>(this) as String;
  }
}
