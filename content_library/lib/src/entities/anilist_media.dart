// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:isar/isar.dart';

part 'anilist_media.g.dart';

@Embedded(ignore: {"toJson", "fromJson"})
class AniListMedia {
  int? idMal;
  Title? title;
  String? type;
  String? format;
  String? status;
  String? description;
  Date? startDate;
  Date? endDate;
  String? season;
  int? episodes;
  String? countryOfOrigin;
  bool? isLicensed;
  String? source;
  String? hashtag;
  Trailer? trailer;
  int? updatedAt;
  CoverImage? coverImage;
  List<String> genres = const [];
  List<String> synonyms = const [];
  int? averageScore;
  int? meanScore;
  int? popularity;
  bool? isLocked;
  int? trending;
  int? favourites;
  List<Tag> tags = const [];
  List<Character> characters = const [];
  List<Staff> staff = const [];

  AniListMedia();

  factory AniListMedia.fromJson(Map<String, dynamic> json) {
    return AniListMedia()
      ..idMal = json['idMal'] as int?
      ..title = json['title'] != null
          ? Title.fromJson(json['title'] as Map<String, dynamic>)
          : null
      ..type = json['type'] as String?
      ..format = json['format'] as String?
      ..status = json['status'] as String?
      ..description = json['description'] as String?
      ..startDate =
          (json['startDate'] is Map && (json['startDate'] as Map).isNotEmpty)
              ? Date.fromJson(json['startDate'] as Map<String, dynamic>)
              : null
      ..endDate =
          (json['endDate'] is Map && (json['endDate'] as Map).isNotEmpty)
              ? Date.fromJson(json['endDate'] as Map<String, dynamic>)
              : null
      ..season = json['season'] as String?
      ..episodes = json['episodes'] as int?
      ..countryOfOrigin = json['countryOfOrigin'] as String?
      ..isLicensed = json['isLicensed'] as bool?
      ..source = json['source'] as String?
      ..hashtag = json['hashtag'] as String?
      ..trailer =
          (json['trailer'] is Map && (json['trailer'] as Map).isNotEmpty)
              ? Trailer.fromJson(json['trailer'] as Map<String, dynamic>)
              : null
      ..updatedAt = json['updatedAt'] as int?
      ..coverImage =
          (json['coverImage'] is Map && (json['coverImage'] as Map).isNotEmpty)
              ? CoverImage.fromJson(json['coverImage'] as Map<String, dynamic>)
              : null
      ..genres = List<String>.from(json['genres'] as List? ?? [])
      ..synonyms = List<String>.from(json['synonyms'] as List? ?? [])
      ..averageScore = json['averageScore'] as int?
      ..meanScore = json['meanScore'] as int?
      ..popularity = json['popularity'] as int?
      ..isLocked = json['isLocked'] as bool?
      ..trending = json['trending'] as int?
      ..favourites = json['favourites'] as int?
      ..tags = (json['tags'] as List<dynamic>?)
              ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..characters = ((json['characters'] is List)
                  ? json['characters'] as List?
                  : (json['characters']?['nodes'] as List?))
              ?.map((e) => Character.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..staff = ((json['staff'] is List)
                  ? json['staff'] as List?
                  : (json['staff']?['nodes'] as List?))
              ?.map((e) => Staff.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
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
class Title {
  String? romaji;
  String? english;
  String? native;

  Title();

  factory Title.fromJson(Map<String, dynamic> json) {
    return Title()
      ..romaji = json['romaji']
      ..english = json['english']
      ..native = json['native'];
  }

  Map<String, dynamic> toJson() {
    return {
      'romaji': romaji,
      'english': english,
      'native': native,
    };
  }
}

@Embedded(ignore: {"toJson", "fromJson"})
class Date {
  int year = -1;
  int month = -1;
  int day = -1;

  bool get isEmpty => year == -1 && month == -1 && day == -1;

  Date();

  factory Date.fromJson(Map<String, dynamic> json) {
    return Date()
      ..year = json['year']
      ..month = json['month']
      ..day = json['day'];
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'day': day,
    };
  }
}

@Embedded(ignore: {"toJson", "fromJson"})
class Trailer {
  String? id;
  String? site;
  String? thumbnail;

  Trailer();

  factory Trailer.fromJson(Map<String, dynamic> json) {
    return Trailer()
      ..id = json['id']
      ..site = json['site']
      ..thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'site': site,
      'thumbnail': thumbnail,
    };
  }
}

@Embedded(ignore: {"toJson", "fromJson"})
class CoverImage {
  String? extraLarge;
  String? large;
  String? medium;
  String? color;

  CoverImage();

  factory CoverImage.fromJson(Map<String, dynamic> json) {
    return CoverImage()
      ..extraLarge = json['extraLarge']
      ..large = json['large']
      ..medium = json['medium']
      ..color = json['color'];
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
  int id = -1;
  String? name;

  Tag();

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag()
      ..id = json['id']
      ..name = json['name'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() => 'Tag(id: $id, name: $name)';
}

@Embedded(ignore: {"toJson", "fromJson"})
class Character {
  CharacterName? name;
  CharacterImage? image;

  Character();

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character()
      ..name = (json['name'] as Map).isNotEmpty
          ? CharacterName.fromJson(json['name'])
          : null
      ..image = (json['image'] as Map).isNotEmpty
          ? CharacterImage.fromJson(json['image'])
          : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name?.toJson(),
      'image': image?.toJson(),
    };
  }
}

@Embedded(ignore: {"toJson", "fromJson"})
class CharacterName {
  String? first;
  String? full;
  String? native;
  List<String> alternative = const [];

  CharacterName();

  factory CharacterName.fromJson(Map<String, dynamic> json) {
    return CharacterName()
      ..first = json['first']
      ..full = json['full']
      ..native = json['native']
      ..alternative = List<String>.from(json['alternative'] ?? []);
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
  String? large;
  String? medium;

  CharacterImage();

  factory CharacterImage.fromJson(Map<String, dynamic> json) {
    return CharacterImage()
      ..large = json['large']
      ..medium = json['medium'];
  }

  Map<String, dynamic> toJson() {
    return {
      'large': large,
      'medium': medium,
    };
  }
}

@Embedded(ignore: {"toJson", "fromJson"})
class Staff {
  StaffName? name;
  StaffImage? image;

  Staff();

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff()
      ..name = (json['name'] as Map).isNotEmpty
          ? StaffName.fromJson(json['name'])
          : null
      ..image = (json['image'] as Map).isNotEmpty
          ? StaffImage.fromJson(json['image'])
          : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name?.toJson(),
      'image': image?.toJson(),
    };
  }
}

@Embedded(ignore: {"toJson", "fromJson"})
class StaffName {
  String? first;
  String? last;
  String? full;
  String? native;
  List<String> alternative = const [];

  StaffName();

  factory StaffName.fromJson(Map<String, dynamic> json) {
    return StaffName()
      ..first = json['first']
      ..last = json['last']
      ..full = json['full']
      ..native = json['native']
      ..alternative = List<String>.from(json['alternative'] ?? []);
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
  String? large;
  String? medium;

  StaffImage();

  factory StaffImage.fromJson(Map<String, dynamic> json) {
    return StaffImage()
      ..large = json['large']
      ..medium = json['medium'];
  }

  Map<String, dynamic> toJson() {
    return {
      'large': large,
      'medium': medium,
    };
  }
}
