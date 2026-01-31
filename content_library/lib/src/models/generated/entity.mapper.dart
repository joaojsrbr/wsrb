// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../entity.dart';

class EntityMapper extends ClassMapperBase<Entity> {
  EntityMapper._();

  static EntityMapper? _instance;
  static EntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EntityMapper._());
      OtherEntityMapper.ensureInitialized();
      ContentEntityMapper.ensureInitialized();
      HistoricEntityMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Entity';

  static int _$id(Entity v) => v.id;
  static const Field<Entity, int> _f$id =
      Field('id', _$id, opt: true, def: Isar.autoIncrement);

  @override
  final MappableFields<Entity> fields = const {
    #id: _f$id,
  };

  static Entity _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
        'Entity', 'type', '${data.value['type']}');
  }

  @override
  final Function instantiate = _instantiate;

  static Entity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Entity>(map);
  }

  static Entity fromJson(String json) {
    return ensureInitialized().decodeJson<Entity>(json);
  }
}

mixin EntityMappable {
  String toJson();
  Map<String, dynamic> toMap();
  EntityCopyWith<Entity, Entity, Entity> get copyWith;
}

abstract class EntityCopyWith<$R, $In extends Entity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? id});
  EntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class OtherEntityMapper extends SubClassMapperBase<OtherEntity> {
  OtherEntityMapper._();

  static OtherEntityMapper? _instance;
  static OtherEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OtherEntityMapper._());
      EntityMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'OtherEntity';

  static int _$id(OtherEntity v) => v.id;
  static const Field<OtherEntity, int> _f$id =
      Field('id', _$id, opt: true, def: Isar.autoIncrement);

  @override
  final MappableFields<OtherEntity> fields = const {
    #id: _f$id,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'OtherEntity';
  @override
  late final ClassMapperBase superMapper = EntityMapper.ensureInitialized();

  static OtherEntity _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('OtherEntity');
  }

  @override
  final Function instantiate = _instantiate;

  static OtherEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OtherEntity>(map);
  }

  static OtherEntity fromJson(String json) {
    return ensureInitialized().decodeJson<OtherEntity>(json);
  }
}

mixin OtherEntityMappable {
  String toJson();
  Map<String, dynamic> toMap();
  OtherEntityCopyWith<OtherEntity, OtherEntity, OtherEntity> get copyWith;
}

abstract class OtherEntityCopyWith<$R, $In extends OtherEntity, $Out>
    implements EntityCopyWith<$R, $In, $Out> {
  @override
  $R call({int? id});
  OtherEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class ContentEntityMapper extends SubClassMapperBase<ContentEntity> {
  ContentEntityMapper._();

  static ContentEntityMapper? _instance;
  static ContentEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ContentEntityMapper._());
      EntityMapper.ensureInitialized().addSubMapper(_instance!);
      SourceMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ContentEntity';

  static String _$title(ContentEntity v) => v.title;
  static const Field<ContentEntity, String> _f$title = Field('title', _$title);
  static String _$stringID(ContentEntity v) => v.stringID;
  static const Field<ContentEntity, String> _f$stringID =
      Field('stringID', _$stringID);
  static String _$url(ContentEntity v) => v.url;
  static const Field<ContentEntity, String> _f$url = Field('url', _$url);
  static Source _$source(ContentEntity v) => v.source;
  static const Field<ContentEntity, Source> _f$source =
      Field('source', _$source);
  static bool _$isFavorite(ContentEntity v) => v.isFavorite;
  static const Field<ContentEntity, bool> _f$isFavorite =
      Field('isFavorite', _$isFavorite);
  static AniListMedia? _$anilistMedia(ContentEntity v) => v.anilistMedia;
  static const Field<ContentEntity, AniListMedia> _f$anilistMedia =
      Field('anilistMedia', _$anilistMedia, opt: true);
  static bool _$isMovie(ContentEntity v) => v.isMovie;
  static const Field<ContentEntity, bool> _f$isMovie =
      Field('isMovie', _$isMovie, opt: true, def: false);
  static String? _$sinopse(ContentEntity v) => v.sinopse;
  static const Field<ContentEntity, String> _f$sinopse =
      Field('sinopse', _$sinopse, opt: true);
  static List<String> _$newReleases(ContentEntity v) => v.newReleases;
  static const Field<ContentEntity, List<String>> _f$newReleases =
      Field('newReleases', _$newReleases, opt: true, def: const []);
  static DateTime? _$createdAt(ContentEntity v) => v.createdAt;
  static const Field<ContentEntity, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, opt: true);
  static DateTime? _$updatedAt(ContentEntity v) => v.updatedAt;
  static const Field<ContentEntity, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, opt: true);
  static int _$id(ContentEntity v) => v.id;
  static const Field<ContentEntity, int> _f$id =
      Field('id', _$id, opt: true, def: Isar.autoIncrement);

  @override
  final MappableFields<ContentEntity> fields = const {
    #title: _f$title,
    #stringID: _f$stringID,
    #url: _f$url,
    #source: _f$source,
    #isFavorite: _f$isFavorite,
    #anilistMedia: _f$anilistMedia,
    #isMovie: _f$isMovie,
    #sinopse: _f$sinopse,
    #newReleases: _f$newReleases,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #id: _f$id,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'ContentEntity';
  @override
  late final ClassMapperBase superMapper = EntityMapper.ensureInitialized();

  static ContentEntity _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('ContentEntity');
  }

  @override
  final Function instantiate = _instantiate;

  static ContentEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ContentEntity>(map);
  }

  static ContentEntity fromJson(String json) {
    return ensureInitialized().decodeJson<ContentEntity>(json);
  }
}

mixin ContentEntityMappable {
  String toJson();
  Map<String, dynamic> toMap();
  ContentEntityCopyWith<ContentEntity, ContentEntity, ContentEntity>
      get copyWith;
}

abstract class ContentEntityCopyWith<$R, $In extends ContentEntity, $Out>
    implements EntityCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get newReleases;
  @override
  $R call(
      {String? title,
      String? stringID,
      String? url,
      Source? source,
      bool? isFavorite,
      AniListMedia? anilistMedia,
      bool? isMovie,
      String? sinopse,
      List<String>? newReleases,
      DateTime? createdAt,
      DateTime? updatedAt,
      int? id});
  ContentEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class HistoricEntityMapper extends SubClassMapperBase<HistoricEntity> {
  HistoricEntityMapper._();

  static HistoricEntityMapper? _instance;
  static HistoricEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HistoricEntityMapper._());
      EntityMapper.ensureInitialized().addSubMapper(_instance!);
      CurrentPositionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'HistoricEntity';

  static String _$url(HistoricEntity v) => v.url;
  static const Field<HistoricEntity, String> _f$url = Field('url', _$url);
  static String _$title(HistoricEntity v) => v.title;
  static const Field<HistoricEntity, String> _f$title = Field('title', _$title);
  static String _$contentStringID(HistoricEntity v) => v.contentStringID;
  static const Field<HistoricEntity, String> _f$contentStringID =
      Field('contentStringID', _$contentStringID);
  static String? _$thumbnail(HistoricEntity v) => v.thumbnail;
  static const Field<HistoricEntity, String> _f$thumbnail =
      Field('thumbnail', _$thumbnail, opt: true);
  static DateTime? _$createdAt(HistoricEntity v) => v.createdAt;
  static const Field<HistoricEntity, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, opt: true);
  static DateTime? _$updatedAt(HistoricEntity v) => v.updatedAt;
  static const Field<HistoricEntity, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, opt: true);
  static bool _$isComplete(HistoricEntity v) => v.isComplete;
  static const Field<HistoricEntity, bool> _f$isComplete =
      Field('isComplete', _$isComplete, opt: true, def: false);
  static double _$percent(HistoricEntity v) => v.percent;
  static const Field<HistoricEntity, double> _f$percent =
      Field('percent', _$percent, opt: true, def: 0.0);
  static int _$numberEpisode(HistoricEntity v) => v.numberEpisode;
  static const Field<HistoricEntity, int> _f$numberEpisode =
      Field('numberEpisode', _$numberEpisode, opt: true, def: 0);
  static CurrentPosition? _$position(HistoricEntity v) => v.position;
  static const Field<HistoricEntity, CurrentPosition> _f$position =
      Field('position', _$position, opt: true);
  static int _$id(HistoricEntity v) => v.id;
  static const Field<HistoricEntity, int> _f$id =
      Field('id', _$id, opt: true, def: Isar.autoIncrement);

  @override
  final MappableFields<HistoricEntity> fields = const {
    #url: _f$url,
    #title: _f$title,
    #contentStringID: _f$contentStringID,
    #thumbnail: _f$thumbnail,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #isComplete: _f$isComplete,
    #percent: _f$percent,
    #numberEpisode: _f$numberEpisode,
    #position: _f$position,
    #id: _f$id,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'HistoricEntity';
  @override
  late final ClassMapperBase superMapper = EntityMapper.ensureInitialized();

  static HistoricEntity _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('HistoricEntity');
  }

  @override
  final Function instantiate = _instantiate;

  static HistoricEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HistoricEntity>(map);
  }

  static HistoricEntity fromJson(String json) {
    return ensureInitialized().decodeJson<HistoricEntity>(json);
  }
}

mixin HistoricEntityMappable {
  String toJson();
  Map<String, dynamic> toMap();
  HistoricEntityCopyWith<HistoricEntity, HistoricEntity, HistoricEntity>
      get copyWith;
}

abstract class HistoricEntityCopyWith<$R, $In extends HistoricEntity, $Out>
    implements EntityCopyWith<$R, $In, $Out> {
  CurrentPositionCopyWith<$R, CurrentPosition, CurrentPosition>? get position;
  @override
  $R call(
      {String? url,
      String? title,
      String? contentStringID,
      String? thumbnail,
      DateTime? createdAt,
      DateTime? updatedAt,
      bool? isComplete,
      double? percent,
      int? numberEpisode,
      CurrentPosition? position,
      int? id});
  HistoricEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}
