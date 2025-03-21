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

  static AniListMedia fromJson(Map<String, dynamic> json) {
    return AniListMedia()
      ..idMal = json['idMal']
      ..title = json['title'] != null ? Title.fromJson(json['title']) : null
      ..type = json['type']
      ..format = json['format']
      ..status = json['status']
      ..description = json['description']
      ..startDate = (json['startDate'] as Map).isNotEmpty
          ? Date.fromJson(json['startDate'])
          : null
      ..endDate = (json['endDate'] as Map).isNotEmpty
          ? Date.fromJson(json['endDate'])
          : null
      ..season = json['season']
      ..episodes = json['episodes']
      ..countryOfOrigin = json['countryOfOrigin']
      ..isLicensed = json['isLicensed']
      ..source = json['source']
      ..hashtag = json['hashtag']
      ..trailer = (json['trailer'] as Map).isNotEmpty
          ? Trailer.fromJson(json['trailer'])
          : null
      ..updatedAt = json['updatedAt']
      ..coverImage = (json['coverImage'] as Map).isNotEmpty
          ? CoverImage.fromJson(json['coverImage'])
          : null
      ..genres = List<String>.from(json['genres'] ?? [])
      ..synonyms = List<String>.from(json['synonyms'] ?? [])
      ..averageScore = json['averageScore']
      ..meanScore = json['meanScore']
      ..popularity = json['popularity']
      ..isLocked = json['isLocked']
      ..trending = json['trending']
      ..favourites = json['favourites']
      ..tags = (json['tags'] as List<dynamic>?)
              ?.map((e) => Tag.fromJson(e))
              .toList() ??
          []
      ..characters = (json['characters']['nodes'] as List<dynamic>?)
              ?.map((e) => Character.fromJson(e))
              .toList() ??
          []
      ..staff = (json['staff']['nodes'] as List<dynamic>?)
              ?.map((e) => Staff.fromJson(e))
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

  static Title fromJson(Map<String, dynamic> json) {
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

  static Date fromJson(Map<String, dynamic> json) {
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

  static Trailer fromJson(Map<String, dynamic> json) {
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

  static CoverImage fromJson(Map<String, dynamic> json) {
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

  static Tag fromJson(Map<String, dynamic> json) {
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

  static Character fromJson(Map<String, dynamic> json) {
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

  static CharacterName fromJson(Map<String, dynamic> json) {
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

  static CharacterImage fromJson(Map<String, dynamic> json) {
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

  static Staff fromJson(Map<String, dynamic> json) {
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

  static StaffName fromJson(Map<String, dynamic> json) {
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

  static StaffImage fromJson(Map<String, dynamic> json) {
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
