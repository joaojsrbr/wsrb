import 'package:app_wsrb_jsr/app/models/release.dart';

class Episode extends Release implements Comparable<Episode> {
  const Episode({
    required super.url,
    required super.title,
    this.generateID,
    this.slugSerie,
    this.thumbnail,
    required this.isDublado,
  });

  final String? generateID;
  final String? thumbnail;
  final bool isDublado;
  final String? slugSerie;

  @override
  List<Object?> get props => [
        id,
        title,
        url,
        generateID,
        isDublado,
        thumbnail,
        slugSerie,
      ];

  @override
  Map<String, dynamic> get toMap {
    return <String, dynamic>{
      'title': title,
      'url': url,
      'isDublado': isDublado,
      'slugSerie': slugSerie,
      'generateID': generateID,
      'thumbnail': thumbnail,
    };
  }

  factory Episode.fromMap(Map<dynamic, dynamic> map) {
    return Episode(
      isDublado: map['isDublado'] as bool,
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
  }

  @override
  int compareTo(Episode other) => number.compareTo(other.number);
}
