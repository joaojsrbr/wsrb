// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChapterEntityCollection on Isar {
  IsarCollection<ChapterEntity> get chapterEntitys => this.collection();
}

const ChapterEntitySchema = CollectionSchema(
  name: r'ChapterEntity',
  id: 6656881136352185615,
  properties: {
    r'bookStringID': PropertySchema(id: 0, name: r'bookStringID', type: IsarType.string),
    r'createdAt': PropertySchema(id: 1, name: r'createdAt', type: IsarType.dateTime),
    r'isComplete': PropertySchema(id: 2, name: r'isComplete', type: IsarType.bool),
    r'percent': PropertySchema(id: 3, name: r'percent', type: IsarType.double),
    r'positions': PropertySchema(
      id: 4,
      name: r'positions',
      type: IsarType.objectList,
      target: r'CurrentPosition',
    ),
    r'readPercent': PropertySchema(id: 5, name: r'readPercent', type: IsarType.double),
    r'stringID': PropertySchema(id: 6, name: r'stringID', type: IsarType.string),
    r'thumbnail': PropertySchema(id: 7, name: r'thumbnail', type: IsarType.string),
    r'title': PropertySchema(id: 8, name: r'title', type: IsarType.string),
    r'updatedAt': PropertySchema(id: 9, name: r'updatedAt', type: IsarType.dateTime),
    r'url': PropertySchema(id: 10, name: r'url', type: IsarType.string),
  },
  estimateSize: _chapterEntityEstimateSize,
  serialize: _chapterEntitySerialize,
  deserialize: _chapterEntityDeserialize,
  deserializeProp: _chapterEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'stringID': IndexSchema(
      id: 4366216431004615589,
      name: r'stringID',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(name: r'stringID', type: IndexType.hash, caseSensitive: true),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'CurrentPosition': CurrentPositionSchema},
  getId: _chapterEntityGetId,
  getLinks: _chapterEntityGetLinks,
  attach: _chapterEntityAttach,
  version: '3.1.0+1',
);

int _chapterEntityEstimateSize(
  ChapterEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bookStringID.length * 3;
  bytesCount += 3 + object.positions.length * 3;
  {
    final offsets = allOffsets[CurrentPosition]!;
    for (var i = 0; i < object.positions.length; i++) {
      final value = object.positions[i];
      bytesCount += CurrentPositionSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.stringID.length * 3;
  {
    final value = object.thumbnail;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _chapterEntitySerialize(
  ChapterEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bookStringID);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeBool(offsets[2], object.isComplete);
  writer.writeDouble(offsets[3], object.percent);
  writer.writeObjectList<CurrentPosition>(
    offsets[4],
    allOffsets,
    CurrentPositionSchema.serialize,
    object.positions,
  );
  writer.writeDouble(offsets[5], object.readPercent);
  writer.writeString(offsets[6], object.stringID);
  writer.writeString(offsets[7], object.thumbnail);
  writer.writeString(offsets[8], object.title);
  writer.writeDateTime(offsets[9], object.updatedAt);
  writer.writeString(offsets[10], object.url);
}

ChapterEntity _chapterEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ChapterEntity(
    bookStringID: reader.readString(offsets[0]),
    createdAt: reader.readDateTimeOrNull(offsets[1]),
    isComplete: reader.readBoolOrNull(offsets[2]) ?? false,
    percent: reader.readDoubleOrNull(offsets[3]) ?? 0.0,
    positions:
        reader.readObjectList<CurrentPosition>(
          offsets[4],
          CurrentPositionSchema.deserialize,
          allOffsets,
          CurrentPosition(),
        ) ??
        const [],
    readPercent: reader.readDouble(offsets[5]),
    stringID: reader.readString(offsets[6]),
    title: reader.readString(offsets[8]),
    updatedAt: reader.readDateTimeOrNull(offsets[9]),
    url: reader.readString(offsets[10]),
  );
  object.id = id;
  return object;
}

P _chapterEntityDeserializeProp<P>(
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
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 4:
      return (reader.readObjectList<CurrentPosition>(
                offset,
                CurrentPositionSchema.deserialize,
                allOffsets,
                CurrentPosition(),
              ) ??
              const [])
          as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _chapterEntityGetId(ChapterEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _chapterEntityGetLinks(ChapterEntity object) {
  return [];
}

void _chapterEntityAttach(IsarCollection<dynamic> col, Id id, ChapterEntity object) {
  object.id = id;
}

extension ChapterEntityByIndex on IsarCollection<ChapterEntity> {
  Future<ChapterEntity?> getByStringID(String stringID) {
    return getByIndex(r'stringID', [stringID]);
  }

  ChapterEntity? getByStringIDSync(String stringID) {
    return getByIndexSync(r'stringID', [stringID]);
  }

  Future<bool> deleteByStringID(String stringID) {
    return deleteByIndex(r'stringID', [stringID]);
  }

  bool deleteByStringIDSync(String stringID) {
    return deleteByIndexSync(r'stringID', [stringID]);
  }

  Future<List<ChapterEntity?>> getAllByStringID(List<String> stringIDValues) {
    final values = stringIDValues.map((e) => [e]).toList();
    return getAllByIndex(r'stringID', values);
  }

  List<ChapterEntity?> getAllByStringIDSync(List<String> stringIDValues) {
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

  Future<Id> putByStringID(ChapterEntity object) {
    return putByIndex(r'stringID', object);
  }

  Id putByStringIDSync(ChapterEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'stringID', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStringID(List<ChapterEntity> objects) {
    return putAllByIndex(r'stringID', objects);
  }

  List<Id> putAllByStringIDSync(List<ChapterEntity> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'stringID', objects, saveLinks: saveLinks);
  }
}

extension ChapterEntityQueryWhereSort
    on QueryBuilder<ChapterEntity, ChapterEntity, QWhere> {
  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ChapterEntityQueryWhere
    on QueryBuilder<ChapterEntity, ChapterEntity, QWhereClause> {
  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: false))
            .addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: false));
      } else {
        return query
            .addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: false))
            .addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: false));
      }
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause> stringIDEqualTo(
    String stringID,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'stringID', value: [stringID]),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause> stringIDNotEqualTo(
    String stringID,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stringID',
                lower: [],
                upper: [stringID],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stringID',
                lower: [stringID],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stringID',
                lower: [stringID],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stringID',
                lower: [],
                upper: [stringID],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension ChapterEntityQueryFilter
    on QueryBuilder<ChapterEntity, ChapterEntity, QFilterCondition> {
  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> bookStringIDEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'bookStringID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
  bookStringIDGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bookStringID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> bookStringIDLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bookStringID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> bookStringIDBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bookStringID',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
  bookStringIDStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'bookStringID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> bookStringIDEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'bookStringID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> bookStringIDContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'bookStringID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> bookStringIDMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'bookStringID',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
  bookStringIDIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'bookStringID', value: ''),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
  bookStringIDIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'bookStringID', value: ''),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> createdAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> isCompleteEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isComplete', value: value),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> percentEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'percent', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> percentGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'percent',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> percentLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'percent',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> percentBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'percent',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
  positionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'positions', length, true, length, true);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> positionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'positions', 0, true, 0, true);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
  positionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'positions', 0, false, 999999, true);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
  positionsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'positions', 0, true, length, include);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
  positionsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'positions', length, include, 999999, true);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
  positionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'positions', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> readPercentEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'readPercent', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
  readPercentGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'readPercent',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> readPercentLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'readPercent',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> readPercentBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'readPercent',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> stringIDEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'stringID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> stringIDGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stringID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> stringIDLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stringID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> stringIDBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stringID',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> stringIDStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'stringID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> stringIDEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'stringID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> stringIDContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'stringID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> stringIDMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'stringID',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> stringIDIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stringID', value: ''),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> stringIDIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'stringID', value: ''),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> thumbnailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'thumbnail'),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> thumbnailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'thumbnail'),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> thumbnailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'thumbnail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> thumbnailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'thumbnail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> thumbnailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'thumbnail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> thumbnailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'thumbnail',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> thumbnailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'thumbnail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> thumbnailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'thumbnail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> thumbnailContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'thumbnail',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> thumbnailMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'thumbnail',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> thumbnailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'thumbnail', value: ''),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
  thumbnailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'thumbnail', value: ''),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> updatedAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> urlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> urlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'url',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> urlContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> urlMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'url',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'url', value: ''),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'url', value: ''),
      );
    });
  }
}

extension ChapterEntityQueryObject
    on QueryBuilder<ChapterEntity, ChapterEntity, QFilterCondition> {
  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> positionsElement(
    FilterQuery<CurrentPosition> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'positions');
    });
  }
}

extension ChapterEntityQueryLinks
    on QueryBuilder<ChapterEntity, ChapterEntity, QFilterCondition> {}

extension ChapterEntityQuerySortBy
    on QueryBuilder<ChapterEntity, ChapterEntity, QSortBy> {
  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByBookStringID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookStringID', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByBookStringIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookStringID', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByIsComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isComplete', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByIsCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isComplete', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percent', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percent', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByReadPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readPercent', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByReadPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readPercent', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByStringID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringID', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByStringIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringID', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByThumbnail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnail', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByThumbnailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnail', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension ChapterEntityQuerySortThenBy
    on QueryBuilder<ChapterEntity, ChapterEntity, QSortThenBy> {
  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByBookStringID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookStringID', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByBookStringIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookStringID', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByIsComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isComplete', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByIsCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isComplete', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percent', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percent', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByReadPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readPercent', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByReadPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readPercent', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByStringID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringID', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByStringIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringID', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByThumbnail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnail', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByThumbnailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnail', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension ChapterEntityQueryWhereDistinct
    on QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> {
  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> distinctByBookStringID({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookStringID', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> distinctByIsComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isComplete');
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> distinctByPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'percent');
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> distinctByReadPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'readPercent');
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> distinctByStringID({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stringID', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> distinctByThumbnail({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbnail', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> distinctByUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension ChapterEntityQueryProperty
    on QueryBuilder<ChapterEntity, ChapterEntity, QQueryProperty> {
  QueryBuilder<ChapterEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ChapterEntity, String, QQueryOperations> bookStringIDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookStringID');
    });
  }

  QueryBuilder<ChapterEntity, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ChapterEntity, bool, QQueryOperations> isCompleteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isComplete');
    });
  }

  QueryBuilder<ChapterEntity, double, QQueryOperations> percentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'percent');
    });
  }

  QueryBuilder<ChapterEntity, List<CurrentPosition>, QQueryOperations>
  positionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positions');
    });
  }

  QueryBuilder<ChapterEntity, double, QQueryOperations> readPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'readPercent');
    });
  }

  QueryBuilder<ChapterEntity, String, QQueryOperations> stringIDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stringID');
    });
  }

  QueryBuilder<ChapterEntity, String?, QQueryOperations> thumbnailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnail');
    });
  }

  QueryBuilder<ChapterEntity, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<ChapterEntity, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<ChapterEntity, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}
