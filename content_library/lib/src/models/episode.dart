import 'package:content_library/content_library.dart';

import 'release.dart';

class Episode extends Release {
  const Episode({
    required super.url,
    required super.title,
    this.generateID,
    this.slugSerie,
    this.numberEpisode,
    this.pageNumber,
    this.sinopse,
    this.thumbnail,
    required this.isDublado,
  });

  final String? sinopse;
  final int? pageNumber;
  final int? numberEpisode;
  final String? generateID;
  final String? thumbnail;
  final bool isDublado;
  final String? slugSerie;

  @override
  List<Object?> get props => [
        stringID,
        title,
        url,
        pageNumber,
        generateID,
        isDublado,
        thumbnail,
        numberEpisode,
        sinopse,
        slugSerie,
      ];

  @override
  String get number {
    return numberEpisode?.toString() ??
        title.replaceAll(RegExp(r'[^0-9]'), '').trim();
  }
}
