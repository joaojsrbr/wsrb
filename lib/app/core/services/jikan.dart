// import 'package:collection/collection.dart';
// import 'package:jikan_api/jikan_api.dart';

// class JikanService {
//   late final Jikan _jikan;

//   JikanService() {
//     _jikan = Jikan();
//   }

//   Future<BuiltList<Manga>> searchManga({
//     String? query,
//     MangaType? type,
//   }) async {
//     return await _jikan.searchManga(
//       query: query,
//       type: type,
//     );
//   }

//   Future<BuiltList<Anime>> searchAnime({
//     String? query,
//     AnimeType? type,
//   }) async {
//     return await _jikan.searchAnime(
//       query: query,
//       type: type,
//     );
//   }

//   Future<BuiltList<Picture>> getMangaPictures({
//     int? id,
//     String? query,
//   }) async {
//     if (id != null) {
//       return await _jikan.getMangaPictures(id);
//     } else if (query != null) {
//       final searchResponse = await searchManga(query: query).then(
//         (value) => value.firstWhereOrNull(
//           (element) => element.titleSynonyms.any(
//             (element) => element.contains(query),
//           ),
//         ),
//       );
//       if (searchResponse != null) {
//         return await getAnimePictures(id: searchResponse.malId);
//       }
//     }
//     return BuiltList();
//   }

//   Future<BuiltList<Picture>> getAnimePictures({
//     int? id,
//     String? query,
//   }) async {
//     if (id != null) {
//       return await _jikan.getAnimePictures(id);
//     } else if (query != null) {
//       final searchResponse = await searchAnime(query: query).then(
//         (value) => value.firstWhereOrNull(
//           (element) => element.titleSynonyms.any(
//             (element) => element.contains(query),
//           ),
//         ),
//       );
//       if (searchResponse != null) {
//         return await getAnimePictures(id: searchResponse.malId);
//       }
//     }
//     return BuiltList();
//   }
// }
