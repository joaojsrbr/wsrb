// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppConfigEntityCollection on Isar {
  IsarCollection<AppConfigEntity> get appConfigEntitys => this.collection();
}

const AppConfigEntitySchema = CollectionSchema(
  name: r'AppConfigEntity',
  id: -6817184198876440529,
  properties: {
    r'filterWatching': PropertySchema(
      id: 0,
      name: r'filterWatching',
      type: IsarType.object,
      target: r'FilterWatching',
    ),
    r'orderBy': PropertySchema(
      id: 1,
      name: r'orderBy',
      type: IsarType.byte,
      enumMap: _AppConfigEntityorderByEnumValueMap,
    ),
    r'reverseContents': PropertySchema(
      id: 2,
      name: r'reverseContents',
      type: IsarType.bool,
    ),
    r'source': PropertySchema(
      id: 3,
      name: r'source',
      type: IsarType.byte,
      enumMap: _AppConfigEntitysourceEnumValueMap,
    )
  },
  estimateSize: _appConfigEntityEstimateSize,
  serialize: _appConfigEntitySerialize,
  deserialize: _appConfigEntityDeserialize,
  deserializeProp: _appConfigEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'FilterWatching': FilterWatchingSchema},
  getId: _appConfigEntityGetId,
  getLinks: _appConfigEntityGetLinks,
  attach: _appConfigEntityAttach,
  version: '3.1.0+1',
);

int _appConfigEntityEstimateSize(
  AppConfigEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      FilterWatchingSchema.estimateSize(
          object.filterWatching, allOffsets[FilterWatching]!, allOffsets);
  return bytesCount;
}

void _appConfigEntitySerialize(
  AppConfigEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObject<FilterWatching>(
    offsets[0],
    allOffsets,
    FilterWatchingSchema.serialize,
    object.filterWatching,
  );
  writer.writeByte(offsets[1], object.orderBy.index);
  writer.writeBool(offsets[2], object.reverseContents);
  writer.writeByte(offsets[3], object.source.index);
}

AppConfigEntity _appConfigEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppConfigEntity(
    filterWatching: reader.readObjectOrNull<FilterWatching>(
          offsets[0],
          FilterWatchingSchema.deserialize,
          allOffsets,
        ) ??
        FilterWatching(),
    orderBy: _AppConfigEntityorderByValueEnumMap[
            reader.readByteOrNull(offsets[1])] ??
        OrderBy.LATEST,
    reverseContents: reader.readBool(offsets[2]),
    source:
        _AppConfigEntitysourceValueEnumMap[reader.readByteOrNull(offsets[3])] ??
            Source.ANROLL,
  );
  object.id = id;
  return object;
}

P _appConfigEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectOrNull<FilterWatching>(
            offset,
            FilterWatchingSchema.deserialize,
            allOffsets,
          ) ??
          FilterWatching()) as P;
    case 1:
      return (_AppConfigEntityorderByValueEnumMap[
              reader.readByteOrNull(offset)] ??
          OrderBy.LATEST) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (_AppConfigEntitysourceValueEnumMap[
              reader.readByteOrNull(offset)] ??
          Source.ANROLL) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AppConfigEntityorderByEnumValueMap = {
  'LATEST': 0,
  'RELEVANCE': 1,
  'ALPHABET': 2,
  'RATING': 3,
  'TRENDING': 4,
  'MOST_READ': 5,
  'NEW_MANGA': 6,
};
const _AppConfigEntityorderByValueEnumMap = {
  0: OrderBy.LATEST,
  1: OrderBy.RELEVANCE,
  2: OrderBy.ALPHABET,
  3: OrderBy.RATING,
  4: OrderBy.TRENDING,
  5: OrderBy.MOST_READ,
  6: OrderBy.NEW_MANGA,
};
const _AppConfigEntitysourceEnumValueMap = {
  'ANROLL': 0,
  'NEOX_SCANS': 1,
  'DEMON_SECT': 2,
  'GOYABU': 3,
  'BETTER_ANIME': 4,
  'SLIMEREAD': 5,
};
const _AppConfigEntitysourceValueEnumMap = {
  0: Source.ANROLL,
  1: Source.NEOX_SCANS,
  2: Source.DEMON_SECT,
  3: Source.GOYABU,
  4: Source.BETTER_ANIME,
  5: Source.SLIMEREAD,
};

Id _appConfigEntityGetId(AppConfigEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appConfigEntityGetLinks(AppConfigEntity object) {
  return [];
}

void _appConfigEntityAttach(
    IsarCollection<dynamic> col, Id id, AppConfigEntity object) {
  object.id = id;
}

extension AppConfigEntityQueryWhereSort
    on QueryBuilder<AppConfigEntity, AppConfigEntity, QWhere> {
  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppConfigEntityQueryWhere
    on QueryBuilder<AppConfigEntity, AppConfigEntity, QWhereClause> {
  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterWhereClause>
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

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterWhereClause> idBetween(
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

extension AppConfigEntityQueryFilter
    on QueryBuilder<AppConfigEntity, AppConfigEntity, QFilterCondition> {
  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterFilterCondition>
      orderByEqualTo(OrderBy value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderBy',
        value: value,
      ));
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterFilterCondition>
      orderByGreaterThan(
    OrderBy value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'orderBy',
        value: value,
      ));
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterFilterCondition>
      orderByLessThan(
    OrderBy value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'orderBy',
        value: value,
      ));
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterFilterCondition>
      orderByBetween(
    OrderBy lower,
    OrderBy upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'orderBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterFilterCondition>
      reverseContentsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reverseContents',
        value: value,
      ));
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterFilterCondition>
      sourceEqualTo(Source value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
      ));
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterFilterCondition>
      sourceGreaterThan(
    Source value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
      ));
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterFilterCondition>
      sourceLessThan(
    Source value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
      ));
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterFilterCondition>
      sourceBetween(
    Source lower,
    Source upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AppConfigEntityQueryObject
    on QueryBuilder<AppConfigEntity, AppConfigEntity, QFilterCondition> {
  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterFilterCondition>
      filterWatching(FilterQuery<FilterWatching> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'filterWatching');
    });
  }
}

extension AppConfigEntityQueryLinks
    on QueryBuilder<AppConfigEntity, AppConfigEntity, QFilterCondition> {}

extension AppConfigEntityQuerySortBy
    on QueryBuilder<AppConfigEntity, AppConfigEntity, QSortBy> {
  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterSortBy> sortByOrderBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderBy', Sort.asc);
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterSortBy>
      sortByOrderByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderBy', Sort.desc);
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterSortBy>
      sortByReverseContents() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reverseContents', Sort.asc);
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterSortBy>
      sortByReverseContentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reverseContents', Sort.desc);
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterSortBy>
      sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }
}

extension AppConfigEntityQuerySortThenBy
    on QueryBuilder<AppConfigEntity, AppConfigEntity, QSortThenBy> {
  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterSortBy> thenByOrderBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderBy', Sort.asc);
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterSortBy>
      thenByOrderByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderBy', Sort.desc);
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterSortBy>
      thenByReverseContents() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reverseContents', Sort.asc);
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterSortBy>
      thenByReverseContentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reverseContents', Sort.desc);
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QAfterSortBy>
      thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }
}

extension AppConfigEntityQueryWhereDistinct
    on QueryBuilder<AppConfigEntity, AppConfigEntity, QDistinct> {
  QueryBuilder<AppConfigEntity, AppConfigEntity, QDistinct>
      distinctByOrderBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderBy');
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QDistinct>
      distinctByReverseContents() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reverseContents');
    });
  }

  QueryBuilder<AppConfigEntity, AppConfigEntity, QDistinct> distinctBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source');
    });
  }
}

extension AppConfigEntityQueryProperty
    on QueryBuilder<AppConfigEntity, AppConfigEntity, QQueryProperty> {
  QueryBuilder<AppConfigEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppConfigEntity, FilterWatching, QQueryOperations>
      filterWatchingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filterWatching');
    });
  }

  QueryBuilder<AppConfigEntity, OrderBy, QQueryOperations> orderByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderBy');
    });
  }

  QueryBuilder<AppConfigEntity, bool, QQueryOperations>
      reverseContentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reverseContents');
    });
  }

  QueryBuilder<AppConfigEntity, Source, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const FilterWatchingSchema = Schema(
  name: r'FilterWatching',
  id: 3284857918384764146,
  properties: {
    r'end': PropertySchema(
      id: 0,
      name: r'end',
      type: IsarType.dateTime,
    ),
    r'filterSources': PropertySchema(
      id: 1,
      name: r'filterSources',
      type: IsarType.byteList,
      enumMap: _FilterWatchingfilterSourcesEnumValueMap,
    ),
    r'genresFilter': PropertySchema(
      id: 2,
      name: r'genresFilter',
      type: IsarType.stringList,
    ),
    r'infiniteDate': PropertySchema(
      id: 3,
      name: r'infiniteDate',
      type: IsarType.bool,
    ),
    r'start': PropertySchema(
      id: 4,
      name: r'start',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _filterWatchingEstimateSize,
  serialize: _filterWatchingSerialize,
  deserialize: _filterWatchingDeserialize,
  deserializeProp: _filterWatchingDeserializeProp,
);

int _filterWatchingEstimateSize(
  FilterWatching object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.filterSources.length;
  bytesCount += 3 + object.genresFilter.length * 3;
  {
    for (var i = 0; i < object.genresFilter.length; i++) {
      final value = object.genresFilter[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _filterWatchingSerialize(
  FilterWatching object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.end);
  writer.writeByteList(
      offsets[1], object.filterSources.map((e) => e.index).toList());
  writer.writeStringList(offsets[2], object.genresFilter);
  writer.writeBool(offsets[3], object.infiniteDate);
  writer.writeDateTime(offsets[4], object.start);
}

FilterWatching _filterWatchingDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FilterWatching(
    end: reader.readDateTimeOrNull(offsets[0]),
    filterSources: reader
            .readByteList(offsets[1])
            ?.map((e) =>
                _FilterWatchingfilterSourcesValueEnumMap[e] ?? Source.ANROLL)
            .toList() ??
        const [],
    genresFilter: reader.readStringList(offsets[2]) ?? const [],
    infiniteDate: reader.readBoolOrNull(offsets[3]) ?? false,
    start: reader.readDateTimeOrNull(offsets[4]),
  );
  return object;
}

P _filterWatchingDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader
              .readByteList(offset)
              ?.map((e) =>
                  _FilterWatchingfilterSourcesValueEnumMap[e] ?? Source.ANROLL)
              .toList() ??
          const []) as P;
    case 2:
      return (reader.readStringList(offset) ?? const []) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _FilterWatchingfilterSourcesEnumValueMap = {
  'ANROLL': 0,
  'NEOX_SCANS': 1,
  'DEMON_SECT': 2,
  'GOYABU': 3,
  'BETTER_ANIME': 4,
  'SLIMEREAD': 5,
};
const _FilterWatchingfilterSourcesValueEnumMap = {
  0: Source.ANROLL,
  1: Source.NEOX_SCANS,
  2: Source.DEMON_SECT,
  3: Source.GOYABU,
  4: Source.BETTER_ANIME,
  5: Source.SLIMEREAD,
};

extension FilterWatchingQueryFilter
    on QueryBuilder<FilterWatching, FilterWatching, QFilterCondition> {
  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      endIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'end',
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      endIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'end',
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      endEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'end',
        value: value,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      endGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'end',
        value: value,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      endLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'end',
        value: value,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      endBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'end',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      filterSourcesElementEqualTo(Source value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filterSources',
        value: value,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      filterSourcesElementGreaterThan(
    Source value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filterSources',
        value: value,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      filterSourcesElementLessThan(
    Source value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filterSources',
        value: value,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      filterSourcesElementBetween(
    Source lower,
    Source upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filterSources',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      filterSourcesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'filterSources',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      filterSourcesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'filterSources',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      filterSourcesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'filterSources',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      filterSourcesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'filterSources',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      filterSourcesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'filterSources',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      filterSourcesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'filterSources',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      genresFilterElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genresFilter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      genresFilterElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'genresFilter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      genresFilterElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'genresFilter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      genresFilterElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'genresFilter',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      genresFilterElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'genresFilter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      genresFilterElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'genresFilter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      genresFilterElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'genresFilter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      genresFilterElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'genresFilter',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      genresFilterElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genresFilter',
        value: '',
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      genresFilterElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'genresFilter',
        value: '',
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      genresFilterLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genresFilter',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      genresFilterIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genresFilter',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      genresFilterIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genresFilter',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      genresFilterLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genresFilter',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      genresFilterLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genresFilter',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      genresFilterLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genresFilter',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      infiniteDateEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'infiniteDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      startIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'start',
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      startIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'start',
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      startEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'start',
        value: value,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      startGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'start',
        value: value,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      startLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'start',
        value: value,
      ));
    });
  }

  QueryBuilder<FilterWatching, FilterWatching, QAfterFilterCondition>
      startBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'start',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FilterWatchingQueryObject
    on QueryBuilder<FilterWatching, FilterWatching, QFilterCondition> {}
