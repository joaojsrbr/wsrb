// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEpisodeEntityCollection on Isar {
  IsarCollection<EpisodeEntity> get episodeEntitys => this.collection();
}

const EpisodeEntitySchema = CollectionSchema(
  name: r'EpisodeEntity',
  id: 3638102932149212917,
  properties: {
    r'animeStringID': PropertySchema(
      id: 0,
      name: r'animeStringID',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentDuration': PropertySchema(
      id: 2,
      name: r'currentDuration',
      type: IsarType.long,
    ),
    r'episodeDuration': PropertySchema(
      id: 3,
      name: r'episodeDuration',
      type: IsarType.long,
    ),
    r'isComplete': PropertySchema(
      id: 4,
      name: r'isComplete',
      type: IsarType.bool,
    ),
    r'numberEpisode': PropertySchema(
      id: 5,
      name: r'numberEpisode',
      type: IsarType.long,
    ),
    r'sinopse': PropertySchema(
      id: 6,
      name: r'sinopse',
      type: IsarType.string,
    ),
    r'stringID': PropertySchema(
      id: 7,
      name: r'stringID',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 8,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _episodeEntityEstimateSize,
  serialize: _episodeEntitySerialize,
  deserialize: _episodeEntityDeserialize,
  deserializeProp: _episodeEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'stringID': IndexSchema(
      id: 4366216431004615589,
      name: r'stringID',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'stringID',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _episodeEntityGetId,
  getLinks: _episodeEntityGetLinks,
  attach: _episodeEntityAttach,
  version: '3.1.0+1',
);

int _episodeEntityEstimateSize(
  EpisodeEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.animeStringID.length * 3;
  {
    final value = object.sinopse;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.stringID.length * 3;
  return bytesCount;
}

void _episodeEntitySerialize(
  EpisodeEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.animeStringID);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.currentDuration);
  writer.writeLong(offsets[3], object.episodeDuration);
  writer.writeBool(offsets[4], object.isComplete);
  writer.writeLong(offsets[5], object.numberEpisode);
  writer.writeString(offsets[6], object.sinopse);
  writer.writeString(offsets[7], object.stringID);
  writer.writeDateTime(offsets[8], object.updatedAt);
}

EpisodeEntity _episodeEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EpisodeEntity(
    animeStringID: reader.readString(offsets[0]),
    createdAt: reader.readDateTimeOrNull(offsets[1]),
    currentDuration: reader.readLong(offsets[2]),
    episodeDuration: reader.readLong(offsets[3]),
    isComplete: reader.readBoolOrNull(offsets[4]) ?? false,
    numberEpisode: reader.readLongOrNull(offsets[5]),
    sinopse: reader.readStringOrNull(offsets[6]),
    stringID: reader.readString(offsets[7]),
    updatedAt: reader.readDateTimeOrNull(offsets[8]),
  );
  object.id = id;
  return object;
}

P _episodeEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _episodeEntityGetId(EpisodeEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _episodeEntityGetLinks(EpisodeEntity object) {
  return [];
}

void _episodeEntityAttach(
    IsarCollection<dynamic> col, Id id, EpisodeEntity object) {
  object.id = id;
}

extension EpisodeEntityByIndex on IsarCollection<EpisodeEntity> {
  Future<EpisodeEntity?> getByStringID(String stringID) {
    return getByIndex(r'stringID', [stringID]);
  }

  EpisodeEntity? getByStringIDSync(String stringID) {
    return getByIndexSync(r'stringID', [stringID]);
  }

  Future<bool> deleteByStringID(String stringID) {
    return deleteByIndex(r'stringID', [stringID]);
  }

  bool deleteByStringIDSync(String stringID) {
    return deleteByIndexSync(r'stringID', [stringID]);
  }

  Future<List<EpisodeEntity?>> getAllByStringID(List<String> stringIDValues) {
    final values = stringIDValues.map((e) => [e]).toList();
    return getAllByIndex(r'stringID', values);
  }

  List<EpisodeEntity?> getAllByStringIDSync(List<String> stringIDValues) {
    final values = stringIDValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'stringID', values);
  }

  Future<int> deleteAllByStringID(List<String> stringIDValues) {
    final values = stringIDValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'stringID', values);
  }

  int deleteAllByStringIDSync(List<String> stringIDValues) {
    final values = stringIDValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'stringID', values);
  }

  Future<Id> putByStringID(EpisodeEntity object) {
    return putByIndex(r'stringID', object);
  }

  Id putByStringIDSync(EpisodeEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'stringID', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStringID(List<EpisodeEntity> objects) {
    return putAllByIndex(r'stringID', objects);
  }

  List<Id> putAllByStringIDSync(List<EpisodeEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'stringID', objects, saveLinks: saveLinks);
  }
}

extension EpisodeEntityQueryWhereSort
    on QueryBuilder<EpisodeEntity, EpisodeEntity, QWhere> {
  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension EpisodeEntityQueryWhere
    on QueryBuilder<EpisodeEntity, EpisodeEntity, QWhereClause> {
  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterWhereClause> stringIDEqualTo(
      String stringID) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'stringID',
        value: [stringID],
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterWhereClause>
      stringIDNotEqualTo(String stringID) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stringID',
              lower: [],
              upper: [stringID],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stringID',
              lower: [stringID],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stringID',
              lower: [stringID],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stringID',
              lower: [],
              upper: [stringID],
              includeUpper: false,
            ));
      }
    });
  }
}

extension EpisodeEntityQueryFilter
    on QueryBuilder<EpisodeEntity, EpisodeEntity, QFilterCondition> {
  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      animeStringIDEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animeStringID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      animeStringIDGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'animeStringID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      animeStringIDLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'animeStringID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      animeStringIDBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'animeStringID',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      animeStringIDStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'animeStringID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      animeStringIDEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'animeStringID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      animeStringIDContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'animeStringID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      animeStringIDMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'animeStringID',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      animeStringIDIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animeStringID',
        value: '',
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      animeStringIDIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'animeStringID',
        value: '',
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      currentDurationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      currentDurationGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      currentDurationLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      currentDurationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentDuration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      episodeDurationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'episodeDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      episodeDurationGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'episodeDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      episodeDurationLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'episodeDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      episodeDurationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'episodeDuration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      isCompleteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isComplete',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      numberEpisodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'numberEpisode',
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      numberEpisodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'numberEpisode',
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      numberEpisodeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'numberEpisode',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      numberEpisodeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'numberEpisode',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      numberEpisodeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'numberEpisode',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      numberEpisodeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'numberEpisode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      sinopseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sinopse',
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      sinopseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sinopse',
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      sinopseEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sinopse',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      sinopseGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sinopse',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      sinopseLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sinopse',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      sinopseBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sinopse',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      sinopseStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sinopse',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      sinopseEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sinopse',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      sinopseContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sinopse',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      sinopseMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sinopse',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      sinopseIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sinopse',
        value: '',
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      sinopseIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sinopse',
        value: '',
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      stringIDEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stringID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      stringIDGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stringID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      stringIDLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stringID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      stringIDBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stringID',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      stringIDStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stringID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      stringIDEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stringID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      stringIDContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stringID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      stringIDMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stringID',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      stringIDIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stringID',
        value: '',
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      stringIDIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stringID',
        value: '',
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterFilterCondition>
      updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension EpisodeEntityQueryObject
    on QueryBuilder<EpisodeEntity, EpisodeEntity, QFilterCondition> {}

extension EpisodeEntityQueryLinks
    on QueryBuilder<EpisodeEntity, EpisodeEntity, QFilterCondition> {}

extension EpisodeEntityQuerySortBy
    on QueryBuilder<EpisodeEntity, EpisodeEntity, QSortBy> {
  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      sortByAnimeStringID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeStringID', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      sortByAnimeStringIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeStringID', Sort.desc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      sortByCurrentDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentDuration', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      sortByCurrentDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentDuration', Sort.desc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      sortByEpisodeDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeDuration', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      sortByEpisodeDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeDuration', Sort.desc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy> sortByIsComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isComplete', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      sortByIsCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isComplete', Sort.desc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      sortByNumberEpisode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberEpisode', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      sortByNumberEpisodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberEpisode', Sort.desc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy> sortBySinopse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sinopse', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy> sortBySinopseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sinopse', Sort.desc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy> sortByStringID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringID', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      sortByStringIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringID', Sort.desc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension EpisodeEntityQuerySortThenBy
    on QueryBuilder<EpisodeEntity, EpisodeEntity, QSortThenBy> {
  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      thenByAnimeStringID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeStringID', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      thenByAnimeStringIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeStringID', Sort.desc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      thenByCurrentDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentDuration', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      thenByCurrentDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentDuration', Sort.desc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      thenByEpisodeDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeDuration', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      thenByEpisodeDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeDuration', Sort.desc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy> thenByIsComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isComplete', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      thenByIsCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isComplete', Sort.desc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      thenByNumberEpisode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberEpisode', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      thenByNumberEpisodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberEpisode', Sort.desc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy> thenBySinopse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sinopse', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy> thenBySinopseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sinopse', Sort.desc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy> thenByStringID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringID', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      thenByStringIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringID', Sort.desc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension EpisodeEntityQueryWhereDistinct
    on QueryBuilder<EpisodeEntity, EpisodeEntity, QDistinct> {
  QueryBuilder<EpisodeEntity, EpisodeEntity, QDistinct> distinctByAnimeStringID(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animeStringID',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QDistinct>
      distinctByCurrentDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentDuration');
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QDistinct>
      distinctByEpisodeDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeDuration');
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QDistinct> distinctByIsComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isComplete');
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QDistinct>
      distinctByNumberEpisode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numberEpisode');
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QDistinct> distinctBySinopse(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sinopse', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QDistinct> distinctByStringID(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stringID', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EpisodeEntity, EpisodeEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension EpisodeEntityQueryProperty
    on QueryBuilder<EpisodeEntity, EpisodeEntity, QQueryProperty> {
  QueryBuilder<EpisodeEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EpisodeEntity, String, QQueryOperations>
      animeStringIDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animeStringID');
    });
  }

  QueryBuilder<EpisodeEntity, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<EpisodeEntity, int, QQueryOperations> currentDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentDuration');
    });
  }

  QueryBuilder<EpisodeEntity, int, QQueryOperations> episodeDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeDuration');
    });
  }

  QueryBuilder<EpisodeEntity, bool, QQueryOperations> isCompleteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isComplete');
    });
  }

  QueryBuilder<EpisodeEntity, int?, QQueryOperations> numberEpisodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numberEpisode');
    });
  }

  QueryBuilder<EpisodeEntity, String?, QQueryOperations> sinopseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sinopse');
    });
  }

  QueryBuilder<EpisodeEntity, String, QQueryOperations> stringIDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stringID');
    });
  }

  QueryBuilder<EpisodeEntity, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
