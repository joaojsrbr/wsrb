// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_skip_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAnimeSkipEntityCollection on Isar {
  IsarCollection<AnimeSkipEntity> get animeSkipEntitys => this.collection();
}

const AnimeSkipEntitySchema = CollectionSchema(
  name: r'AnimeSkipEntity',
  id: 1608482136271696636,
  properties: {
    r'animeSkipId': PropertySchema(
      id: 0,
      name: r'animeSkipId',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    ),
    r'times': PropertySchema(
      id: 2,
      name: r'times',
      type: IsarType.objectList,
      target: r'AnimeTimeStampEntity',
    )
  },
  estimateSize: _animeSkipEntityEstimateSize,
  serialize: _animeSkipEntitySerialize,
  deserialize: _animeSkipEntityDeserialize,
  deserializeProp: _animeSkipEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'AnimeTimeStampEntity': AnimeTimeStampEntitySchema},
  getId: _animeSkipEntityGetId,
  getLinks: _animeSkipEntityGetLinks,
  attach: _animeSkipEntityAttach,
  version: '3.1.0+1',
);

int _animeSkipEntityEstimateSize(
  AnimeSkipEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.animeSkipId.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.times.length * 3;
  {
    final offsets = allOffsets[AnimeTimeStampEntity]!;
    for (var i = 0; i < object.times.length; i++) {
      final value = object.times[i];
      bytesCount +=
          AnimeTimeStampEntitySchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _animeSkipEntitySerialize(
  AnimeSkipEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.animeSkipId);
  writer.writeString(offsets[1], object.name);
  writer.writeObjectList<AnimeTimeStampEntity>(
    offsets[2],
    allOffsets,
    AnimeTimeStampEntitySchema.serialize,
    object.times,
  );
}

AnimeSkipEntity _animeSkipEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AnimeSkipEntity();
  object.animeSkipId = reader.readString(offsets[0]);
  object.id = id;
  object.name = reader.readString(offsets[1]);
  object.times = reader.readObjectList<AnimeTimeStampEntity>(
        offsets[2],
        AnimeTimeStampEntitySchema.deserialize,
        allOffsets,
        AnimeTimeStampEntity(),
      ) ??
      [];
  return object;
}

P _animeSkipEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readObjectList<AnimeTimeStampEntity>(
            offset,
            AnimeTimeStampEntitySchema.deserialize,
            allOffsets,
            AnimeTimeStampEntity(),
          ) ??
          []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _animeSkipEntityGetId(AnimeSkipEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _animeSkipEntityGetLinks(AnimeSkipEntity object) {
  return [];
}

void _animeSkipEntityAttach(
    IsarCollection<dynamic> col, Id id, AnimeSkipEntity object) {
  object.id = id;
}

extension AnimeSkipEntityQueryWhereSort
    on QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QWhere> {
  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AnimeSkipEntityQueryWhere
    on QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QWhereClause> {
  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterWhereClause> idBetween(
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
}

extension AnimeSkipEntityQueryFilter
    on QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QFilterCondition> {
  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      animeSkipIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animeSkipId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      animeSkipIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'animeSkipId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      animeSkipIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'animeSkipId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      animeSkipIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'animeSkipId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      animeSkipIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'animeSkipId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      animeSkipIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'animeSkipId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      animeSkipIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'animeSkipId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      animeSkipIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'animeSkipId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      animeSkipIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animeSkipId',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      animeSkipIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'animeSkipId',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
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

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      timesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'times',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      timesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'times',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      timesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'times',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      timesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'times',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      timesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'times',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      timesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'times',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension AnimeSkipEntityQueryObject
    on QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QFilterCondition> {
  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterFilterCondition>
      timesElement(FilterQuery<AnimeTimeStampEntity> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'times');
    });
  }
}

extension AnimeSkipEntityQueryLinks
    on QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QFilterCondition> {}

extension AnimeSkipEntityQuerySortBy
    on QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QSortBy> {
  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterSortBy>
      sortByAnimeSkipId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeSkipId', Sort.asc);
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterSortBy>
      sortByAnimeSkipIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeSkipId', Sort.desc);
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension AnimeSkipEntityQuerySortThenBy
    on QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QSortThenBy> {
  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterSortBy>
      thenByAnimeSkipId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeSkipId', Sort.asc);
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterSortBy>
      thenByAnimeSkipIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeSkipId', Sort.desc);
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension AnimeSkipEntityQueryWhereDistinct
    on QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QDistinct> {
  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QDistinct>
      distinctByAnimeSkipId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animeSkipId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension AnimeSkipEntityQueryProperty
    on QueryBuilder<AnimeSkipEntity, AnimeSkipEntity, QQueryProperty> {
  QueryBuilder<AnimeSkipEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AnimeSkipEntity, String, QQueryOperations>
      animeSkipIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animeSkipId');
    });
  }

  QueryBuilder<AnimeSkipEntity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<AnimeSkipEntity, List<AnimeTimeStampEntity>, QQueryOperations>
      timesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'times');
    });
  }
}
