// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBookEntityCollection on Isar {
  IsarCollection<BookEntity> get bookEntitys => this.collection();
}

const BookEntitySchema = CollectionSchema(
  name: r'BookEntity',
  id: 8847647309143832400,
  properties: {
    r'alternativeTitle': PropertySchema(
      id: 0,
      name: r'alternativeTitle',
      type: IsarType.string,
    ),
    r'anilistMedia': PropertySchema(
      id: 1,
      name: r'anilistMedia',
      type: IsarType.object,
      target: r'AniListMedia',
    ),
    r'createdAt': PropertySchema(id: 2, name: r'createdAt', type: IsarType.dateTime),
    r'extraLarge': PropertySchema(id: 3, name: r'extraLarge', type: IsarType.string),
    r'isFavorite': PropertySchema(id: 4, name: r'isFavorite', type: IsarType.bool),
    r'largeImage': PropertySchema(id: 5, name: r'largeImage', type: IsarType.string),
    r'mediumImage': PropertySchema(id: 6, name: r'mediumImage', type: IsarType.string),
    r'originalImage': PropertySchema(
      id: 7,
      name: r'originalImage',
      type: IsarType.string,
    ),
    r'sinopse': PropertySchema(id: 8, name: r'sinopse', type: IsarType.string),
    r'source': PropertySchema(
      id: 9,
      name: r'source',
      type: IsarType.byte,
      enumMap: _BookEntitysourceEnumValueMap,
    ),
    r'stringID': PropertySchema(id: 10, name: r'stringID', type: IsarType.string),
    r'title': PropertySchema(id: 11, name: r'title', type: IsarType.string),
    r'updatedAt': PropertySchema(id: 12, name: r'updatedAt', type: IsarType.dateTime),
    r'url': PropertySchema(id: 13, name: r'url', type: IsarType.string),
  },
  estimateSize: _bookEntityEstimateSize,
  serialize: _bookEntitySerialize,
  deserialize: _bookEntityDeserialize,
  deserializeProp: _bookEntityDeserializeProp,
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
  links: {
    r'chapters': LinkSchema(
      id: 3864337466129374837,
      name: r'chapters',
      target: r'ChapterEntity',
      single: false,
    ),
  },
  embeddedSchemas: {
    r'AniListMedia': AniListMediaSchema,
    r'Title': TitleSchema,
    r'Date': DateSchema,
    r'Trailer': TrailerSchema,
    r'CoverImage': CoverImageSchema,
    r'BannerImage': BannerImageSchema,
    r'Tag': TagSchema,
    r'Character': CharacterSchema,
    r'CharacterName': CharacterNameSchema,
    r'CharacterImage': CharacterImageSchema,
    r'Staff': StaffSchema,
    r'StaffName': StaffNameSchema,
    r'StaffImage': StaffImageSchema,
  },
  getId: _bookEntityGetId,
  getLinks: _bookEntityGetLinks,
  attach: _bookEntityAttach,
  version: '3.1.0+1',
);

int _bookEntityEstimateSize(
  BookEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.alternativeTitle;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.anilistMedia;
    if (value != null) {
      bytesCount +=
          3 +
          AniListMediaSchema.estimateSize(value, allOffsets[AniListMedia]!, allOffsets);
    }
  }
  {
    final value = object.extraLarge;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.largeImage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.mediumImage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.originalImage.length * 3;
  {
    final value = object.sinopse;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.stringID.length * 3;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _bookEntitySerialize(
  BookEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.alternativeTitle);
  writer.writeObject<AniListMedia>(
    offsets[1],
    allOffsets,
    AniListMediaSchema.serialize,
    object.anilistMedia,
  );
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.extraLarge);
  writer.writeBool(offsets[4], object.isFavorite);
  writer.writeString(offsets[5], object.largeImage);
  writer.writeString(offsets[6], object.mediumImage);
  writer.writeString(offsets[7], object.originalImage);
  writer.writeString(offsets[8], object.sinopse);
  writer.writeByte(offsets[9], object.source.index);
  writer.writeString(offsets[10], object.stringID);
  writer.writeString(offsets[11], object.title);
  writer.writeDateTime(offsets[12], object.updatedAt);
  writer.writeString(offsets[13], object.url);
}

BookEntity _bookEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BookEntity(
    alternativeTitle: reader.readStringOrNull(offsets[0]),
    anilistMedia: reader.readObjectOrNull<AniListMedia>(
      offsets[1],
      AniListMediaSchema.deserialize,
      allOffsets,
    ),
    createdAt: reader.readDateTimeOrNull(offsets[2]),
    extraLarge: reader.readStringOrNull(offsets[3]),
    isFavorite: reader.readBoolOrNull(offsets[4]) ?? false,
    largeImage: reader.readStringOrNull(offsets[5]),
    mediumImage: reader.readStringOrNull(offsets[6]),
    originalImage: reader.readString(offsets[7]),
    sinopse: reader.readStringOrNull(offsets[8]),
    source:
        _BookEntitysourceValueEnumMap[reader.readByteOrNull(offsets[9])] ?? Source.ANROLL,
    stringID: reader.readString(offsets[10]),
    title: reader.readString(offsets[11]),
    updatedAt: reader.readDateTimeOrNull(offsets[12]),
    url: reader.readString(offsets[13]),
  );
  object.id = id;
  return object;
}

P _bookEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readObjectOrNull<AniListMedia>(
            offset,
            AniListMediaSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (_BookEntitysourceValueEnumMap[reader.readByteOrNull(offset)] ??
              Source.ANROLL)
          as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BookEntitysourceEnumValueMap = {
  'ANROLL': 0,
  'NEOX_SCANS': 1,
  'DEMON_SECT': 2,
  'GOYABU': 3,
  'BETTER_ANIME': 4,
  'SLIMEREAD': 5,
};
const _BookEntitysourceValueEnumMap = {
  0: Source.ANROLL,
  1: Source.NEOX_SCANS,
  2: Source.DEMON_SECT,
  3: Source.GOYABU,
  4: Source.BETTER_ANIME,
  5: Source.SLIMEREAD,
};

Id _bookEntityGetId(BookEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bookEntityGetLinks(BookEntity object) {
  return [object.chapters];
}

void _bookEntityAttach(IsarCollection<dynamic> col, Id id, BookEntity object) {
  object.id = id;
  object.chapters.attach(col, col.isar.collection<ChapterEntity>(), r'chapters', id);
}

extension BookEntityByIndex on IsarCollection<BookEntity> {
  Future<BookEntity?> getByStringID(String stringID) {
    return getByIndex(r'stringID', [stringID]);
  }

  BookEntity? getByStringIDSync(String stringID) {
    return getByIndexSync(r'stringID', [stringID]);
  }

  Future<bool> deleteByStringID(String stringID) {
    return deleteByIndex(r'stringID', [stringID]);
  }

  bool deleteByStringIDSync(String stringID) {
    return deleteByIndexSync(r'stringID', [stringID]);
  }

  Future<List<BookEntity?>> getAllByStringID(List<String> stringIDValues) {
    final values = stringIDValues.map((e) => [e]).toList();
    return getAllByIndex(r'stringID', values);
  }

  List<BookEntity?> getAllByStringIDSync(List<String> stringIDValues) {
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

  Future<Id> putByStringID(BookEntity object) {
    return putByIndex(r'stringID', object);
  }

  Id putByStringIDSync(BookEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'stringID', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStringID(List<BookEntity> objects) {
    return putAllByIndex(r'stringID', objects);
  }

  List<Id> putAllByStringIDSync(List<BookEntity> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'stringID', objects, saveLinks: saveLinks);
  }
}

extension BookEntityQueryWhereSort on QueryBuilder<BookEntity, BookEntity, QWhere> {
  QueryBuilder<BookEntity, BookEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BookEntityQueryWhere on QueryBuilder<BookEntity, BookEntity, QWhereClause> {
  QueryBuilder<BookEntity, BookEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<BookEntity, BookEntity, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<BookEntity, BookEntity, QAfterWhereClause> stringIDEqualTo(
    String stringID,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'stringID', value: [stringID]),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterWhereClause> stringIDNotEqualTo(
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

extension BookEntityQueryFilter
    on QueryBuilder<BookEntity, BookEntity, QFilterCondition> {
  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> alternativeTitleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'alternativeTitle'),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition>
  alternativeTitleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'alternativeTitle'),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> alternativeTitleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'alternativeTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> alternativeTitleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'alternativeTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> alternativeTitleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'alternativeTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> alternativeTitleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'alternativeTitle',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> alternativeTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'alternativeTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> alternativeTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'alternativeTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> alternativeTitleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'alternativeTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> alternativeTitleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'alternativeTitle',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> alternativeTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'alternativeTitle', value: ''),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition>
  alternativeTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'alternativeTitle', value: ''),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> anilistMediaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'anilistMedia'),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> anilistMediaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'anilistMedia'),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> createdAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> extraLargeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'extraLarge'),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> extraLargeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'extraLarge'),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> extraLargeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'extraLarge',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> extraLargeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'extraLarge',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> extraLargeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'extraLarge',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> extraLargeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'extraLarge',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> extraLargeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'extraLarge',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> extraLargeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'extraLarge',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> extraLargeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'extraLarge',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> extraLargeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'extraLarge',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> extraLargeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'extraLarge', value: ''),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> extraLargeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'extraLarge', value: ''),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'id', value: value),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'id', value: value),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> isFavoriteEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isFavorite', value: value),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> largeImageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'largeImage'),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> largeImageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'largeImage'),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> largeImageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'largeImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> largeImageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'largeImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> largeImageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'largeImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> largeImageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'largeImage',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> largeImageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'largeImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> largeImageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'largeImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> largeImageContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'largeImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> largeImageMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'largeImage',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> largeImageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'largeImage', value: ''),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> largeImageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'largeImage', value: ''),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> mediumImageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'mediumImage'),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> mediumImageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'mediumImage'),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> mediumImageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'mediumImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> mediumImageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mediumImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> mediumImageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mediumImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> mediumImageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mediumImage',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> mediumImageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'mediumImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> mediumImageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'mediumImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> mediumImageContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'mediumImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> mediumImageMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'mediumImage',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> mediumImageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mediumImage', value: ''),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> mediumImageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'mediumImage', value: ''),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> originalImageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'originalImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> originalImageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'originalImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> originalImageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'originalImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> originalImageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'originalImage',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> originalImageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'originalImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> originalImageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'originalImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> originalImageContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'originalImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> originalImageMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'originalImage',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> originalImageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'originalImage', value: ''),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> originalImageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'originalImage', value: ''),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> sinopseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'sinopse'));
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> sinopseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sinopse'),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> sinopseEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sinopse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> sinopseGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sinopse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> sinopseLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sinopse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> sinopseBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sinopse',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> sinopseStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sinopse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> sinopseEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sinopse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> sinopseContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sinopse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> sinopseMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sinopse',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> sinopseIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sinopse', value: ''),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> sinopseIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sinopse', value: ''),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> sourceEqualTo(
    Source value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'source', value: value),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> sourceGreaterThan(
    Source value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'source', value: value),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> sourceLessThan(
    Source value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'source', value: value),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> sourceBetween(
    Source lower,
    Source upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'source',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> stringIDEqualTo(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> stringIDGreaterThan(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> stringIDLessThan(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> stringIDBetween(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> stringIDStartsWith(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> stringIDEndsWith(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> stringIDContains(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> stringIDMatches(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> stringIDIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stringID', value: ''),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> stringIDIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'stringID', value: ''),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> titleEqualTo(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> titleGreaterThan(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> titleStartsWith(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> titleEndsWith(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> titleContains(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> titleMatches(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> updatedAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> updatedAtGreaterThan(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> updatedAtBetween(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> urlEqualTo(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> urlGreaterThan(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> urlLessThan(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> urlBetween(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> urlStartsWith(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> urlEndsWith(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> urlContains(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> urlMatches(
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

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'url', value: ''),
      );
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'url', value: ''),
      );
    });
  }
}

extension BookEntityQueryObject
    on QueryBuilder<BookEntity, BookEntity, QFilterCondition> {
  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> anilistMedia(
    FilterQuery<AniListMedia> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'anilistMedia');
    });
  }
}

extension BookEntityQueryLinks on QueryBuilder<BookEntity, BookEntity, QFilterCondition> {
  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> chapters(
    FilterQuery<ChapterEntity> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'chapters');
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> chaptersLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'chapters', length, true, length, true);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> chaptersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'chapters', 0, true, 0, true);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> chaptersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'chapters', 0, false, 999999, true);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> chaptersLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'chapters', 0, true, length, include);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> chaptersLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'chapters', length, include, 999999, true);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterFilterCondition> chaptersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'chapters', lower, includeLower, upper, includeUpper);
    });
  }
}

extension BookEntityQuerySortBy on QueryBuilder<BookEntity, BookEntity, QSortBy> {
  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByAlternativeTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alternativeTitle', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByAlternativeTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alternativeTitle', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByExtraLarge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraLarge', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByExtraLargeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraLarge', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByLargeImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'largeImage', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByLargeImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'largeImage', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByMediumImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediumImage', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByMediumImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediumImage', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByOriginalImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalImage', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByOriginalImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalImage', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortBySinopse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sinopse', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortBySinopseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sinopse', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByStringID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringID', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByStringIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringID', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension BookEntityQuerySortThenBy on QueryBuilder<BookEntity, BookEntity, QSortThenBy> {
  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByAlternativeTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alternativeTitle', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByAlternativeTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alternativeTitle', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByExtraLarge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraLarge', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByExtraLargeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraLarge', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByLargeImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'largeImage', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByLargeImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'largeImage', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByMediumImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediumImage', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByMediumImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediumImage', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByOriginalImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalImage', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByOriginalImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalImage', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenBySinopse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sinopse', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenBySinopseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sinopse', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByStringID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringID', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByStringIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringID', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension BookEntityQueryWhereDistinct
    on QueryBuilder<BookEntity, BookEntity, QDistinct> {
  QueryBuilder<BookEntity, BookEntity, QDistinct> distinctByAlternativeTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alternativeTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BookEntity, BookEntity, QDistinct> distinctByExtraLarge({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'extraLarge', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QDistinct> distinctByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFavorite');
    });
  }

  QueryBuilder<BookEntity, BookEntity, QDistinct> distinctByLargeImage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'largeImage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QDistinct> distinctByMediumImage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediumImage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QDistinct> distinctByOriginalImage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalImage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QDistinct> distinctBySinopse({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sinopse', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QDistinct> distinctBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source');
    });
  }

  QueryBuilder<BookEntity, BookEntity, QDistinct> distinctByStringID({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stringID', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookEntity, BookEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<BookEntity, BookEntity, QDistinct> distinctByUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension BookEntityQueryProperty
    on QueryBuilder<BookEntity, BookEntity, QQueryProperty> {
  QueryBuilder<BookEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BookEntity, String?, QQueryOperations> alternativeTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alternativeTitle');
    });
  }

  QueryBuilder<BookEntity, AniListMedia?, QQueryOperations> anilistMediaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'anilistMedia');
    });
  }

  QueryBuilder<BookEntity, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BookEntity, String?, QQueryOperations> extraLargeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'extraLarge');
    });
  }

  QueryBuilder<BookEntity, bool, QQueryOperations> isFavoriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFavorite');
    });
  }

  QueryBuilder<BookEntity, String?, QQueryOperations> largeImageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'largeImage');
    });
  }

  QueryBuilder<BookEntity, String?, QQueryOperations> mediumImageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediumImage');
    });
  }

  QueryBuilder<BookEntity, String, QQueryOperations> originalImageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalImage');
    });
  }

  QueryBuilder<BookEntity, String?, QQueryOperations> sinopseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sinopse');
    });
  }

  QueryBuilder<BookEntity, Source, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<BookEntity, String, QQueryOperations> stringIDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stringID');
    });
  }

  QueryBuilder<BookEntity, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<BookEntity, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<BookEntity, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}
