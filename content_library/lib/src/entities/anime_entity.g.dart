// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAnimeEntityCollection on Isar {
  IsarCollection<AnimeEntity> get animeEntitys => this.collection();
}

const AnimeEntitySchema = CollectionSchema(
  name: r'AnimeEntity',
  id: 2165130097224532509,
  properties: {
    r'anilistMedia': PropertySchema(
      id: 0,
      name: r'anilistMedia',
      type: IsarType.object,
      target: r'AniListMedia',
    ),
    r'animeID': PropertySchema(id: 1, name: r'animeID', type: IsarType.string),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'extraLarge': PropertySchema(
      id: 3,
      name: r'extraLarge',
      type: IsarType.string,
    ),
    r'generateID': PropertySchema(
      id: 4,
      name: r'generateID',
      type: IsarType.string,
    ),
    r'isDublado': PropertySchema(
      id: 5,
      name: r'isDublado',
      type: IsarType.bool,
    ),
    r'isFavorite': PropertySchema(
      id: 6,
      name: r'isFavorite',
      type: IsarType.bool,
    ),
    r'largeImage': PropertySchema(
      id: 7,
      name: r'largeImage',
      type: IsarType.string,
    ),
    r'mediumImage': PropertySchema(
      id: 8,
      name: r'mediumImage',
      type: IsarType.string,
    ),
    r'originalImage': PropertySchema(
      id: 9,
      name: r'originalImage',
      type: IsarType.string,
    ),
    r'sinopse': PropertySchema(id: 10, name: r'sinopse', type: IsarType.string),
    r'slugSerie': PropertySchema(
      id: 11,
      name: r'slugSerie',
      type: IsarType.string,
    ),
    r'source': PropertySchema(
      id: 12,
      name: r'source',
      type: IsarType.byte,
      enumMap: _AnimeEntitysourceEnumValueMap,
    ),
    r'stringID': PropertySchema(
      id: 13,
      name: r'stringID',
      type: IsarType.string,
    ),
    r'title': PropertySchema(id: 14, name: r'title', type: IsarType.string),
    r'totalOfEpisodes': PropertySchema(
      id: 15,
      name: r'totalOfEpisodes',
      type: IsarType.long,
    ),
    r'totalOfPages': PropertySchema(
      id: 16,
      name: r'totalOfPages',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 17,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'url': PropertySchema(id: 18, name: r'url', type: IsarType.string),
  },
  estimateSize: _animeEntityEstimateSize,
  serialize: _animeEntitySerialize,
  deserialize: _animeEntityDeserialize,
  deserializeProp: _animeEntityDeserializeProp,
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
        ),
      ],
    ),
  },
  links: {
    r'episodes': LinkSchema(
      id: 3675573322536156541,
      name: r'episodes',
      target: r'EpisodeEntity',
      single: false,
    ),
    r'animeSkip': LinkSchema(
      id: 3444031402569074064,
      name: r'animeSkip',
      target: r'AnimeSkipEntity',
      single: true,
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
  getId: _animeEntityGetId,
  getLinks: _animeEntityGetLinks,
  attach: _animeEntityAttach,
  version: '3.1.0+1',
);

int _animeEntityEstimateSize(
  AnimeEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.anilistMedia;
    if (value != null) {
      bytesCount +=
          3 +
          AniListMediaSchema.estimateSize(
            value,
            allOffsets[AniListMedia]!,
            allOffsets,
          );
    }
  }
  {
    final value = object.animeID;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.extraLarge;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.generateID;
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
  {
    final value = object.slugSerie;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.stringID.length * 3;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _animeEntitySerialize(
  AnimeEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObject<AniListMedia>(
    offsets[0],
    allOffsets,
    AniListMediaSchema.serialize,
    object.anilistMedia,
  );
  writer.writeString(offsets[1], object.animeID);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.extraLarge);
  writer.writeString(offsets[4], object.generateID);
  writer.writeBool(offsets[5], object.isDublado);
  writer.writeBool(offsets[6], object.isFavorite);
  writer.writeString(offsets[7], object.largeImage);
  writer.writeString(offsets[8], object.mediumImage);
  writer.writeString(offsets[9], object.originalImage);
  writer.writeString(offsets[10], object.sinopse);
  writer.writeString(offsets[11], object.slugSerie);
  writer.writeByte(offsets[12], object.source.index);
  writer.writeString(offsets[13], object.stringID);
  writer.writeString(offsets[14], object.title);
  writer.writeLong(offsets[15], object.totalOfEpisodes);
  writer.writeLong(offsets[16], object.totalOfPages);
  writer.writeDateTime(offsets[17], object.updatedAt);
  writer.writeString(offsets[18], object.url);
}

AnimeEntity _animeEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AnimeEntity(
    anilistMedia: reader.readObjectOrNull<AniListMedia>(
      offsets[0],
      AniListMediaSchema.deserialize,
      allOffsets,
    ),
    animeID: reader.readStringOrNull(offsets[1]),
    createdAt: reader.readDateTimeOrNull(offsets[2]),
    extraLarge: reader.readStringOrNull(offsets[3]),
    generateID: reader.readStringOrNull(offsets[4]),
    isDublado: reader.readBoolOrNull(offsets[5]) ?? false,
    isFavorite: reader.readBoolOrNull(offsets[6]) ?? false,
    largeImage: reader.readStringOrNull(offsets[7]),
    mediumImage: reader.readStringOrNull(offsets[8]),
    originalImage: reader.readString(offsets[9]),
    sinopse: reader.readStringOrNull(offsets[10]),
    slugSerie: reader.readStringOrNull(offsets[11]),
    source:
        _AnimeEntitysourceValueEnumMap[reader.readByteOrNull(offsets[12])] ??
        Source.ANROLL,
    stringID: reader.readString(offsets[13]),
    title: reader.readString(offsets[14]),
    totalOfEpisodes: reader.readLongOrNull(offsets[15]),
    totalOfPages: reader.readLongOrNull(offsets[16]),
    updatedAt: reader.readDateTimeOrNull(offsets[17]),
    url: reader.readString(offsets[18]),
  );
  object.id = id;
  return object;
}

P _animeEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectOrNull<AniListMedia>(
            offset,
            AniListMediaSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (_AnimeEntitysourceValueEnumMap[reader.readByteOrNull(offset)] ??
              Source.ANROLL)
          as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readLongOrNull(offset)) as P;
    case 16:
      return (reader.readLongOrNull(offset)) as P;
    case 17:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AnimeEntitysourceEnumValueMap = {
  'ANROLL': 0,
  'NEOX_SCANS': 1,
  'DEMON_SECT': 2,
  'GOYABU': 3,
  'BETTER_ANIME': 4,
  'SLIMEREAD': 5,
};
const _AnimeEntitysourceValueEnumMap = {
  0: Source.ANROLL,
  1: Source.NEOX_SCANS,
  2: Source.DEMON_SECT,
  3: Source.GOYABU,
  4: Source.BETTER_ANIME,
  5: Source.SLIMEREAD,
};

Id _animeEntityGetId(AnimeEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _animeEntityGetLinks(AnimeEntity object) {
  return [object.episodes, object.animeSkip];
}

void _animeEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  AnimeEntity object,
) {
  object.id = id;
  object.episodes.attach(
    col,
    col.isar.collection<EpisodeEntity>(),
    r'episodes',
    id,
  );
  object.animeSkip.attach(
    col,
    col.isar.collection<AnimeSkipEntity>(),
    r'animeSkip',
    id,
  );
}

extension AnimeEntityByIndex on IsarCollection<AnimeEntity> {
  Future<AnimeEntity?> getByStringID(String stringID) {
    return getByIndex(r'stringID', [stringID]);
  }

  AnimeEntity? getByStringIDSync(String stringID) {
    return getByIndexSync(r'stringID', [stringID]);
  }

  Future<bool> deleteByStringID(String stringID) {
    return deleteByIndex(r'stringID', [stringID]);
  }

  bool deleteByStringIDSync(String stringID) {
    return deleteByIndexSync(r'stringID', [stringID]);
  }

  Future<List<AnimeEntity?>> getAllByStringID(List<String> stringIDValues) {
    final values = stringIDValues.map((e) => [e]).toList();
    return getAllByIndex(r'stringID', values);
  }

  List<AnimeEntity?> getAllByStringIDSync(List<String> stringIDValues) {
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

  Future<Id> putByStringID(AnimeEntity object) {
    return putByIndex(r'stringID', object);
  }

  Id putByStringIDSync(AnimeEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'stringID', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStringID(List<AnimeEntity> objects) {
    return putAllByIndex(r'stringID', objects);
  }

  List<Id> putAllByStringIDSync(
    List<AnimeEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'stringID', objects, saveLinks: saveLinks);
  }
}

extension AnimeEntityQueryWhereSort
    on QueryBuilder<AnimeEntity, AnimeEntity, QWhere> {
  QueryBuilder<AnimeEntity, AnimeEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AnimeEntityQueryWhere
    on QueryBuilder<AnimeEntity, AnimeEntity, QWhereClause> {
  QueryBuilder<AnimeEntity, AnimeEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterWhereClause> stringIDEqualTo(
    String stringID,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'stringID', value: [stringID]),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterWhereClause> stringIDNotEqualTo(
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

extension AnimeEntityQueryFilter
    on QueryBuilder<AnimeEntity, AnimeEntity, QFilterCondition> {
  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  anilistMediaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'anilistMedia'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  anilistMediaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'anilistMedia'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  animeIDIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'animeID'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  animeIDIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'animeID'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> animeIDEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'animeID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  animeIDGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'animeID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> animeIDLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'animeID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> animeIDBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'animeID',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  animeIDStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'animeID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> animeIDEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'animeID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> animeIDContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'animeID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> animeIDMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'animeID',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  animeIDIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'animeID', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  animeIDIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'animeID', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  createdAtGreaterThan(DateTime? value, {bool include = false}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  createdAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  createdAtBetween(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  extraLargeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'extraLarge'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  extraLargeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'extraLarge'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  extraLargeEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  extraLargeGreaterThan(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  extraLargeLessThan(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  extraLargeBetween(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  extraLargeStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  extraLargeEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  extraLargeContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  extraLargeMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  extraLargeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'extraLarge', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  extraLargeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'extraLarge', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  generateIDIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'generateID'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  generateIDIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'generateID'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  generateIDEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'generateID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  generateIDGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'generateID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  generateIDLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'generateID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  generateIDBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'generateID',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  generateIDStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'generateID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  generateIDEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'generateID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  generateIDContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'generateID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  generateIDMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'generateID',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  generateIDIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'generateID', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  generateIDIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'generateID', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  isDubladoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isDublado', value: value),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  isFavoriteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isFavorite', value: value),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  largeImageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'largeImage'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  largeImageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'largeImage'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  largeImageEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  largeImageGreaterThan(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  largeImageLessThan(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  largeImageBetween(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  largeImageStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  largeImageEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  largeImageContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  largeImageMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  largeImageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'largeImage', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  largeImageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'largeImage', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  mediumImageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'mediumImage'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  mediumImageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'mediumImage'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  mediumImageEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  mediumImageGreaterThan(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  mediumImageLessThan(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  mediumImageBetween(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  mediumImageStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  mediumImageEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  mediumImageContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  mediumImageMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  mediumImageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mediumImage', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  mediumImageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'mediumImage', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  originalImageEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  originalImageGreaterThan(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  originalImageLessThan(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  originalImageBetween(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  originalImageStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  originalImageEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  originalImageContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  originalImageMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  originalImageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'originalImage', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  originalImageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'originalImage', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  sinopseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sinopse'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  sinopseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sinopse'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> sinopseEqualTo(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  sinopseGreaterThan(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> sinopseLessThan(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> sinopseBetween(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  sinopseStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> sinopseEndsWith(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> sinopseContains(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> sinopseMatches(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  sinopseIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sinopse', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  sinopseIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sinopse', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  slugSerieIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'slugSerie'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  slugSerieIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'slugSerie'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  slugSerieEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'slugSerie',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  slugSerieGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'slugSerie',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  slugSerieLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'slugSerie',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  slugSerieBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'slugSerie',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  slugSerieStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'slugSerie',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  slugSerieEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'slugSerie',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  slugSerieContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'slugSerie',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  slugSerieMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'slugSerie',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  slugSerieIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'slugSerie', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  slugSerieIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'slugSerie', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> sourceEqualTo(
    Source value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'source', value: value),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  sourceGreaterThan(Source value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'source',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> sourceLessThan(
    Source value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'source',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> sourceBetween(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> stringIDEqualTo(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  stringIDGreaterThan(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  stringIDLessThan(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> stringIDBetween(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  stringIDStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  stringIDEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  stringIDContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> stringIDMatches(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  stringIDIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stringID', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  stringIDIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'stringID', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> titleEqualTo(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  titleGreaterThan(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> titleStartsWith(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> titleEndsWith(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> titleContains(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> titleMatches(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  totalOfEpisodesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'totalOfEpisodes'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  totalOfEpisodesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'totalOfEpisodes'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  totalOfEpisodesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalOfEpisodes', value: value),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  totalOfEpisodesGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalOfEpisodes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  totalOfEpisodesLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalOfEpisodes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  totalOfEpisodesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalOfEpisodes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  totalOfPagesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'totalOfPages'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  totalOfPagesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'totalOfPages'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  totalOfPagesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalOfPages', value: value),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  totalOfPagesGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalOfPages',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  totalOfPagesLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalOfPages',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  totalOfPagesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalOfPages',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime? value, {bool include = false}) {
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  updatedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  updatedAtBetween(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> urlEqualTo(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> urlGreaterThan(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> urlLessThan(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> urlBetween(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> urlStartsWith(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> urlEndsWith(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> urlContains(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> urlMatches(
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

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'url', value: ''),
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'url', value: ''),
      );
    });
  }
}

extension AnimeEntityQueryObject
    on QueryBuilder<AnimeEntity, AnimeEntity, QFilterCondition> {
  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> anilistMedia(
    FilterQuery<AniListMedia> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'anilistMedia');
    });
  }
}

extension AnimeEntityQueryLinks
    on QueryBuilder<AnimeEntity, AnimeEntity, QFilterCondition> {
  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> episodes(
    FilterQuery<EpisodeEntity> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'episodes');
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  episodesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'episodes', length, true, length, true);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  episodesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'episodes', 0, true, 0, true);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  episodesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'episodes', 0, false, 999999, true);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  episodesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'episodes', 0, true, length, include);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  episodesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'episodes', length, include, 999999, true);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  episodesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'episodes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition> animeSkip(
    FilterQuery<AnimeSkipEntity> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'animeSkip');
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterFilterCondition>
  animeSkipIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'animeSkip', 0, true, 0, true);
    });
  }
}

extension AnimeEntityQuerySortBy
    on QueryBuilder<AnimeEntity, AnimeEntity, QSortBy> {
  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByAnimeID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeID', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByAnimeIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeID', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByExtraLarge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraLarge', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByExtraLargeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraLarge', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByGenerateID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generateID', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByGenerateIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generateID', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByIsDublado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDublado', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByIsDubladoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDublado', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByLargeImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'largeImage', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByLargeImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'largeImage', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByMediumImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediumImage', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByMediumImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediumImage', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByOriginalImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalImage', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy>
  sortByOriginalImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalImage', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortBySinopse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sinopse', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortBySinopseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sinopse', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortBySlugSerie() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slugSerie', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortBySlugSerieDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slugSerie', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByStringID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringID', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByStringIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringID', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByTotalOfEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalOfEpisodes', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy>
  sortByTotalOfEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalOfEpisodes', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByTotalOfPages() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalOfPages', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy>
  sortByTotalOfPagesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalOfPages', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension AnimeEntityQuerySortThenBy
    on QueryBuilder<AnimeEntity, AnimeEntity, QSortThenBy> {
  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByAnimeID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeID', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByAnimeIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeID', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByExtraLarge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraLarge', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByExtraLargeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraLarge', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByGenerateID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generateID', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByGenerateIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generateID', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByIsDublado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDublado', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByIsDubladoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDublado', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByLargeImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'largeImage', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByLargeImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'largeImage', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByMediumImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediumImage', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByMediumImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediumImage', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByOriginalImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalImage', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy>
  thenByOriginalImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalImage', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenBySinopse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sinopse', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenBySinopseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sinopse', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenBySlugSerie() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slugSerie', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenBySlugSerieDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slugSerie', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByStringID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringID', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByStringIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringID', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByTotalOfEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalOfEpisodes', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy>
  thenByTotalOfEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalOfEpisodes', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByTotalOfPages() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalOfPages', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy>
  thenByTotalOfPagesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalOfPages', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension AnimeEntityQueryWhereDistinct
    on QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> {
  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> distinctByAnimeID({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animeID', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> distinctByExtraLarge({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'extraLarge', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> distinctByGenerateID({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'generateID', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> distinctByIsDublado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDublado');
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> distinctByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFavorite');
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> distinctByLargeImage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'largeImage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> distinctByMediumImage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediumImage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> distinctByOriginalImage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'originalImage',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> distinctBySinopse({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sinopse', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> distinctBySlugSerie({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'slugSerie', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> distinctBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source');
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> distinctByStringID({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stringID', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct>
  distinctByTotalOfEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalOfEpisodes');
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> distinctByTotalOfPages() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalOfPages');
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<AnimeEntity, AnimeEntity, QDistinct> distinctByUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension AnimeEntityQueryProperty
    on QueryBuilder<AnimeEntity, AnimeEntity, QQueryProperty> {
  QueryBuilder<AnimeEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AnimeEntity, AniListMedia?, QQueryOperations>
  anilistMediaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'anilistMedia');
    });
  }

  QueryBuilder<AnimeEntity, String?, QQueryOperations> animeIDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animeID');
    });
  }

  QueryBuilder<AnimeEntity, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AnimeEntity, String?, QQueryOperations> extraLargeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'extraLarge');
    });
  }

  QueryBuilder<AnimeEntity, String?, QQueryOperations> generateIDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'generateID');
    });
  }

  QueryBuilder<AnimeEntity, bool, QQueryOperations> isDubladoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDublado');
    });
  }

  QueryBuilder<AnimeEntity, bool, QQueryOperations> isFavoriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFavorite');
    });
  }

  QueryBuilder<AnimeEntity, String?, QQueryOperations> largeImageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'largeImage');
    });
  }

  QueryBuilder<AnimeEntity, String?, QQueryOperations> mediumImageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediumImage');
    });
  }

  QueryBuilder<AnimeEntity, String, QQueryOperations> originalImageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalImage');
    });
  }

  QueryBuilder<AnimeEntity, String?, QQueryOperations> sinopseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sinopse');
    });
  }

  QueryBuilder<AnimeEntity, String?, QQueryOperations> slugSerieProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'slugSerie');
    });
  }

  QueryBuilder<AnimeEntity, Source, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<AnimeEntity, String, QQueryOperations> stringIDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stringID');
    });
  }

  QueryBuilder<AnimeEntity, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<AnimeEntity, int?, QQueryOperations> totalOfEpisodesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalOfEpisodes');
    });
  }

  QueryBuilder<AnimeEntity, int?, QQueryOperations> totalOfPagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalOfPages');
    });
  }

  QueryBuilder<AnimeEntity, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<AnimeEntity, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}
