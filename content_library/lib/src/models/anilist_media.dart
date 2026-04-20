// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'generated/anilist_media.g.dart';

@Embedded(ignore: {"toJson", "fromJson"})
class AniListMedia {
  final int? idMal;
  final Title? title;
  final String? type;
  final String? format;
  final String? status;
  final String? description;
  final Date? startDate;
  final Date? endDate;
  final String? season;
  final int? episodes;
  final String? countryOfOrigin;
  final bool? isLicensed;
  final String? source;
  final String? hashtag;
  final Trailer? trailer;
  final int? updatedAt;
  final CoverImage? coverImage;
  final BannerImage? bannerImage;
  final List<String> genres;
  final List<String> synonyms;
  final int? averageScore;
  final int? meanScore;
  final int? popularity;
  final bool? isLocked;
  final int? trending;
  final int? favourites;
  final List<Tag> tags;
  final List<Character> characters;
  final List<Staff> staff;

  AniListMedia({
    this.idMal,
    this.title,
    this.type,
    this.format,
    this.status,
    this.description,
    this.startDate,
    this.endDate,
    this.season,
    this.episodes,
    this.countryOfOrigin,
    this.isLicensed,
    this.source,
    this.hashtag,
    this.trailer,
    this.updatedAt,
    this.coverImage,
    this.bannerImage,
    this.genres = const [],
    this.synonyms = const [],
    this.averageScore,
    this.meanScore,
    this.popularity,
    this.isLocked,
    this.trending,
    this.favourites,
    this.tags = const [],
    this.characters = const [],
    this.staff = const [],
  });

  factory AniListMedia.fromJson(Map<String, dynamic> json) {
    return AniListMedia(
      idMal: json['idMal'] as int?,
      title: json['title'] != null
          ? Title.fromJson(json['title'] as Map<String, dynamic>)
          : null,
      type: json['type'] as String?,
      format: json['format'] as String?,
      status: json['status'] as String?,
      description: json['description'] as String?,
      startDate:
          (json['startDate'] is Map && (json['startDate'] as Map).isNotEmpty)
          ? Date.fromJson(json['startDate'] as Map<String, dynamic>)
          : null,
      endDate: (json['endDate'] is Map && (json['endDate'] as Map).isNotEmpty)
          ? Date.fromJson(json['endDate'] as Map<String, dynamic>)
          : null,
      season: json['season'] as String?,
      episodes: json['episodes'] as int?,
      countryOfOrigin: json['countryOfOrigin'] as String?,
      isLicensed: json['isLicensed'] as bool?,
      source: json['source'] as String?,
      hashtag: json['hashtag'] as String?,
      trailer: (json['trailer'] is Map && (json['trailer'] as Map).isNotEmpty)
          ? Trailer.fromJson(json['trailer'] as Map<String, dynamic>)
          : null,
      updatedAt: json['updatedAt'] as int?,
      coverImage:
          (json['coverImage'] is Map && (json['coverImage'] as Map).isNotEmpty)
          ? CoverImage.fromJson(json['coverImage'] as Map<String, dynamic>)
          : null,
      bannerImage:
          (json['bannerImage'] is Map &&
              (json['bannerImage'] as Map).isNotEmpty)
          ? BannerImage.fromJson(json['bannerImage'] as Map<String, dynamic>)
          : (json['bannerImage'] is String)
          ? (BannerImage(extraLarge: json['bannerImage'], isBanner: true))
          : null,
      genres: List<String>.from(json['genres'] as List? ?? []),
      synonyms: List<String>.from(json['synonyms'] as List? ?? []),
      averageScore: json['averageScore'] as int?,
      meanScore: json['meanScore'] as int?,
      popularity: json['popularity'] as int?,
      isLocked: json['isLocked'] as bool?,
      trending: json['trending'] as int?,
      favourites: json['favourites'] as int?,
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      characters:
          ((json['characters'] is List)
                  ? json['characters'] as List?
                  : (json['characters']?['nodes'] as List?))
              ?.map((e) => Character.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      staff:
          ((json['staff'] is List)
                  ? json['staff'] as List?
                  : (json['staff']?['nodes'] as List?))
              ?.map((e) => Staff.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Color getScoreColor(ColorScheme colorScheme) {
    final score = (averageScore ?? 0) / 10;
    if (score >= 8.0) {
      return Colors.green;
    } else if (score >= 5.0) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'idMal': idMal,
      'title': title?.toJson(),
      'type': type,
      'format': format,
      'status': status,
      'description': description,
      'startDate': startDate?.toJson(),
      'endDate': endDate?.toJson(),
      'season': season,
      'episodes': episodes,
      'countryOfOrigin': countryOfOrigin,
      'isLicensed': isLicensed,
      'source': source,
      'hashtag': hashtag,
      'trailer': trailer?.toJson(),
      'updatedAt': updatedAt,
      'coverImage': coverImage?.toJson(),
      'bannerImage': bannerImage?.toJson(),
      'genres': genres,
      'synonyms': synonyms,
      'averageScore': averageScore,
      'meanScore': meanScore,
      'popularity': popularity,
      'isLocked': isLocked,
      'trending': trending,
      'favourites': favourites,
      'tags': tags.map((e) => e.toJson()).toList(),
      'characters': characters.map((e) => e.toJson()).toList(),
      'staff': staff.map((e) => e.toJson()).toList(),
    };
  }
}

@Embedded(ignore: {"toJson", "fromJson"})
class BannerImage {
  final bool isBanner;
  final String? extraLarge;
  final String? large;
  final String? medium;
  final String? color;

  const BannerImage({
    this.isBanner = false,
    this.extraLarge,
    this.large,
    this.medium,
    this.color,
  });

  factory BannerImage.fromJson(Map<String, dynamic> json) {
    return BannerImage(
      extraLarge: json['extraLarge'],
      isBanner: json['isBanner'] ?? false,
      large: json['large'],
      medium: json['medium'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isBanner': isBanner,
      'extraLarge': extraLarge,
      'large': large,
      'medium': medium,
      'color': color,
    };
  }
}

@Embedded(ignore: {"toJson", "fromJson"})
class Title {
  final String? romaji;
  final String? english;
  final String? native;

  Title({this.romaji, this.english, this.native});

  factory Title.fromJson(Map<String, dynamic> json) {
    return Title(
      romaji: json['romaji'],
      english: json['english'],
      native: json['native'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'romaji': romaji, 'english': english, 'native': native};
  }
}

@Embedded(ignore: {"toJson", "fromJson"})
class Date {
  final int year;
  final int month;
  final int day;

  bool get isEmpty => year == -1 && month == -1 && day == -1;

  Date({this.year = -1, this.month = -1, this.day = -1});

  factory Date.fromJson(Map<String, dynamic> json) {
    return Date(year: json['year'], month: json['month'], day: json['day']);
  }

  Map<String, dynamic> toJson() {
    return {'year': year, 'month': month, 'day': day};
  }
}

@Embedded(ignore: {"toJson", "fromJson"})
class Trailer {
  final String? id;
  final String? site;
  final String? thumbnail;

  Trailer({this.id, this.site, this.thumbnail});

  factory Trailer.fromJson(Map<String, dynamic> json) {
    return Trailer(
      id: json['id'],
      site: json['site'],
      thumbnail: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'site': site, 'thumbnail': thumbnail};
  }
}

@Embedded(ignore: {"toJson", "fromJson"})
class CoverImage {
  final String? extraLarge;
  final String? large;
  final String? medium;
  final String? color;

  const CoverImage({this.extraLarge, this.large, this.medium, this.color});

  factory CoverImage.fromJson(Map<String, dynamic> json) {
    return CoverImage(
      extraLarge: json['extraLarge'],
      large: json['large'],
      medium: json['medium'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extraLarge': extraLarge,
      'large': large,
      'medium': medium,
      'color': color,
    };
  }
}

@Embedded(ignore: {"toJson", "fromJson"})
class Tag {
  final int? id;
  final String name;

  const Tag({this.id = -1, this.name = ""});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(id: json['id'], name: json['name'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  @override
  String toString() => name;

  String intanceToString() => 'Tag(id: $id, name: $name)';
}

@Embedded(ignore: {"toJson", "fromJson"})
class Character {
  final CharacterName? name;
  final CharacterImage? image;

  Character({this.image, this.name});

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: (json['name'] as Map).isNotEmpty
          ? CharacterName.fromJson(json['name'])
          : null,
      image: (json['image'] as Map).isNotEmpty
          ? CharacterImage.fromJson(json['image'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name?.toJson(), 'image': image?.toJson()};
  }
}

@Embedded(ignore: {"toJson", "fromJson"})
class CharacterName {
  final String? first;
  final String? full;
  final String? native;
  final List<String> alternative;

  CharacterName({
    this.first,
    this.full,
    this.native,
    this.alternative = const [],
  });

  factory CharacterName.fromJson(Map<String, dynamic> json) {
    return CharacterName(
      first: json['first'],
      full: json['full'],
      native: json['native'],
      alternative: List<String>.from(json['alternative'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first': first,
      'full': full,
      'native': native,
      'alternative': alternative,
    };
  }
}

@Embedded(ignore: {"toJson", "fromJson"})
class CharacterImage {
  final String? large;
  final String? medium;

  CharacterImage({this.large, this.medium});

  factory CharacterImage.fromJson(Map<String, dynamic> json) {
    return CharacterImage(large: json['large'], medium: json['medium']);
  }

  Map<String, dynamic> toJson() {
    return {'large': large, 'medium': medium};
  }
}

@Embedded(ignore: {"toJson", "fromJson"})
class Staff {
  final StaffName? name;
  final StaffImage? image;

  const Staff({this.name, this.image});

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      name: (json['name'] as Map).isNotEmpty
          ? StaffName.fromJson(json['name'])
          : null,
      image: (json['image'] as Map).isNotEmpty
          ? StaffImage.fromJson(json['image'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name?.toJson(), 'image': image?.toJson()};
  }
}

@Embedded(ignore: {"toJson", "fromJson"})
class StaffName {
  final String? first;
  final String? last;
  final String? full;
  final String? native;
  final List<String> alternative;

  StaffName({
    this.first,
    this.last,
    this.full,
    this.native,
    this.alternative = const [],
  });

  factory StaffName.fromJson(Map<String, dynamic> json) {
    return StaffName(
      first: json['first'],
      last: json['last'],
      full: json['full'],
      native: json['native'],
      alternative: List<String>.from(json['alternative'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first': first,
      'last': last,
      'full': full,
      'native': native,
      'alternative': alternative,
    };
  }
}

@Embedded(ignore: {"toJson", "fromJson"})
class StaffImage {
  final String? large;
  final String? medium;

  StaffImage({this.large, this.medium});

  factory StaffImage.fromJson(Map<String, dynamic> json) {
    return StaffImage(large: json['large'], medium: json['medium']);
  }

  Map<String, dynamic> toJson() {
    return {'large': large, 'medium': medium};
  }
}
