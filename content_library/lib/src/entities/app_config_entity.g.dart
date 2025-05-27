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
    r'orderBy': PropertySchema(
      id: 0,
      name: r'orderBy',
      type: IsarType.byte,
      enumMap: _AppConfigEntityorderByEnumValueMap,
    ),
    r'reverseContents': PropertySchema(
      id: 1,
      name: r'reverseContents',
      type: IsarType.bool,
    ),
    r'source': PropertySchema(
      id: 2,
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
  embeddedSchemas: {},
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
  return bytesCount;
}

void _appConfigEntitySerialize(
  AppConfigEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.orderBy.index);
  writer.writeBool(offsets[1], object.reverseContents);
  writer.writeByte(offsets[2], object.source.index);
}

AppConfigEntity _appConfigEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppConfigEntity(
    orderBy: _AppConfigEntityorderByValueEnumMap[
            reader.readByteOrNull(offsets[0])] ??
        OrderBy.LATEST,
    reverseContents: reader.readBool(offsets[1]),
    source:
        _AppConfigEntitysourceValueEnumMap[reader.readByteOrNull(offsets[2])] ??
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
      return (_AppConfigEntityorderByValueEnumMap[
              reader.readByteOrNull(offset)] ??
          OrderBy.LATEST) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
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
  'SLIMEREAD': 4,
};
const _AppConfigEntitysourceValueEnumMap = {
  0: Source.ANROLL,
  1: Source.NEOX_SCANS,
  2: Source.DEMON_SECT,
  3: Source.GOYABU,
  4: Source.SLIMEREAD,
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
    on QueryBuilder<AppConfigEntity, AppConfigEntity, QFilterCondition> {}

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
