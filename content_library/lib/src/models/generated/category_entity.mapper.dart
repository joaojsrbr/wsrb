// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../category_entity.dart';

class CategoryEntityMapper extends SubClassMapperBase<CategoryEntity> {
  CategoryEntityMapper._();

  static CategoryEntityMapper? _instance;
  static CategoryEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CategoryEntityMapper._());
      OtherEntityMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'CategoryEntity';

  static String _$title(CategoryEntity v) => v.title;
  static const Field<CategoryEntity, String> _f$title = Field('title', _$title);
  static int _$id(CategoryEntity v) => v.id;
  static const Field<CategoryEntity, int> _f$id =
      Field('id', _$id, opt: true, def: Isar.autoIncrement);
  static String? _$description(CategoryEntity v) => v.description;
  static const Field<CategoryEntity, String> _f$description =
      Field('description', _$description, opt: true);
  static DateTime? _$createdAt(CategoryEntity v) => v.createdAt;
  static const Field<CategoryEntity, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, opt: true);
  static DateTime? _$updatedAt(CategoryEntity v) => v.updatedAt;
  static const Field<CategoryEntity, DateTime> _f$updatedAt =
      Field('updatedAt', _$updatedAt, opt: true);
  static List<String> _$ids(CategoryEntity v) => v.ids;
  static const Field<CategoryEntity, List<String>> _f$ids =
      Field('ids', _$ids, opt: true, def: const []);
  static String _$stringID(CategoryEntity v) => v.stringID;
  static const Field<CategoryEntity, String> _f$stringID =
      Field('stringID', _$stringID, mode: FieldMode.member);

  @override
  final MappableFields<CategoryEntity> fields = const {
    #title: _f$title,
    #id: _f$id,
    #description: _f$description,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #ids: _f$ids,
    #stringID: _f$stringID,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'CategoryEntity';
  @override
  late final ClassMapperBase superMapper =
      OtherEntityMapper.ensureInitialized();

  static CategoryEntity _instantiate(DecodingData data) {
    return CategoryEntity(
        title: data.dec(_f$title),
        id: data.dec(_f$id),
        description: data.dec(_f$description),
        createdAt: data.dec(_f$createdAt),
        updatedAt: data.dec(_f$updatedAt),
        ids: data.dec(_f$ids));
  }

  @override
  final Function instantiate = _instantiate;

  static CategoryEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CategoryEntity>(map);
  }

  static CategoryEntity fromJson(String json) {
    return ensureInitialized().decodeJson<CategoryEntity>(json);
  }
}

mixin CategoryEntityMappable {
  String toJson() {
    return CategoryEntityMapper.ensureInitialized()
        .encodeJson<CategoryEntity>(this as CategoryEntity);
  }

  Map<String, dynamic> toMap() {
    return CategoryEntityMapper.ensureInitialized()
        .encodeMap<CategoryEntity>(this as CategoryEntity);
  }

  CategoryEntityCopyWith<CategoryEntity, CategoryEntity, CategoryEntity>
      get copyWith => _CategoryEntityCopyWithImpl(
          this as CategoryEntity, $identity, $identity);
  @override
  String toString() {
    return CategoryEntityMapper.ensureInitialized()
        .stringifyValue(this as CategoryEntity);
  }

  @override
  bool operator ==(Object other) {
    return CategoryEntityMapper.ensureInitialized()
        .equalsValue(this as CategoryEntity, other);
  }

  @override
  int get hashCode {
    return CategoryEntityMapper.ensureInitialized()
        .hashValue(this as CategoryEntity);
  }
}

extension CategoryEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CategoryEntity, $Out> {
  CategoryEntityCopyWith<$R, CategoryEntity, $Out> get $asCategoryEntity =>
      $base.as((v, t, t2) => _CategoryEntityCopyWithImpl(v, t, t2));
}

abstract class CategoryEntityCopyWith<$R, $In extends CategoryEntity, $Out>
    implements OtherEntityCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get ids;
  @override
  $R call(
      {String? title,
      int? id,
      String? description,
      DateTime? createdAt,
      DateTime? updatedAt,
      List<String>? ids});
  CategoryEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _CategoryEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CategoryEntity, $Out>
    implements CategoryEntityCopyWith<$R, CategoryEntity, $Out> {
  _CategoryEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CategoryEntity> $mapper =
      CategoryEntityMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get ids =>
      ListCopyWith($value.ids, (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(ids: v));
  @override
  $R call(
          {String? title,
          int? id,
          Object? description = $none,
          Object? createdAt = $none,
          Object? updatedAt = $none,
          List<String>? ids}) =>
      $apply(FieldCopyWithData({
        if (title != null) #title: title,
        if (id != null) #id: id,
        if (description != $none) #description: description,
        if (createdAt != $none) #createdAt: createdAt,
        if (updatedAt != $none) #updatedAt: updatedAt,
        if (ids != null) #ids: ids
      }));
  @override
  CategoryEntity $make(CopyWithData data) => CategoryEntity(
      title: data.get(#title, or: $value.title),
      id: data.get(#id, or: $value.id),
      description: data.get(#description, or: $value.description),
      createdAt: data.get(#createdAt, or: $value.createdAt),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt),
      ids: data.get(#ids, or: $value.ids));

  @override
  CategoryEntityCopyWith<$R2, CategoryEntity, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _CategoryEntityCopyWithImpl($value, $cast, t);
}
