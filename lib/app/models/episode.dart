import 'package:app_wsrb_jsr/app/models/data_content.dart';

class Episode extends DataContent implements Comparable<Episode> {
  const Episode({
    required super.url,
    required super.title,
    this.generateID,
    this.slugSerie,
    this.thumbnail,
  });

  final String? generateID;
  final String? thumbnail;
  final String? slugSerie;

  @override
  List<Object?> get props => [
        id,
        title,
        url,
        generateID,
        thumbnail,
        slugSerie,
      ];

  @override
  Map<String, dynamic> get toMap {
    return <String, dynamic>{
      'title': title,
      'url': url,
      'slugSerie': slugSerie,
      'generateID': generateID,
      'thumbnail': thumbnail,
    };
  }

  factory Episode.fromMap(Map<dynamic, dynamic> map) {
    return Episode(
      url: map['url'] as String,
      slugSerie: map['slugSerie'] != null ? map['slugSerie'] as String : null,
      title: map['title'] as String,
      generateID:
          map['generateID'] != null ? map['generateID'] as String : null,
      thumbnail: map['thumbnail'] != null ? map['thumbnail'] as String : null,
    );
  }

  @override
  String get number {
    return title.replaceAll(RegExp(r'[^0-9]'), '').trim();
    // final rgx = RegExp(r'Cap.+[0-9].-');
    // final rgx2 = RegExp(r'Cap.+[0-9]');

    // final match = rgx.stringMatch(title) ?? rgx2.stringMatch(title) ?? '';

    // return match
    //     .replaceAll(RegExp(r'\([0-9]\)|\(\)|\([0-9]'), '')
    //     .replaceFirst('-', '')
    //     .replaceAll(RegExp('[^0-9]'), '')
    //     .trim();
  }

  @override
  int compareTo(Episode other) {
    return number.compareTo(other.number);
  }
}
