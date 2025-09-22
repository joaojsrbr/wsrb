// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../book.dart';

class BookMapper extends SubClassMapperBase<Book> {
  BookMapper._();

  static BookMapper? _instance;
  static BookMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BookMapper._());
      ContentMapper.ensureInitialized().addSubMapper(_instance!);
      SourceMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Book';

  static AniListMedia? _$anilistMedia(Book v) => v.anilistMedia;
  static const Field<Book, AniListMedia> _f$anilistMedia =
      Field('anilistMedia', _$anilistMedia, opt: true);
  static Releases<Release> _$releases(Book v) => v.releases;
  static dynamic _arg$releases(f) => f<Releases<Release>>();
  static const Field<Book, ChapterReleases> _f$releases =
      Field('releases', _$releases, arg: _arg$releases);
  static String _$title(Book v) => v.title;
  static const Field<Book, String> _f$title = Field('title', _$title);
  static Source _$source(Book v) => v.source;
  static const Field<Book, Source> _f$source = Field('source', _$source);
  static String _$originalImage(Book v) => v.originalImage;
  static const Field<Book, String> _f$originalImage =
      Field('originalImage', _$originalImage);
  static String _$url(Book v) => v.url;
  static const Field<Book, String> _f$url = Field('url', _$url);
  static List<Genre> _$genres(Book v) => v.genres;
  static const Field<Book, List<Genre>> _f$genres =
      Field('genres', _$genres, opt: true, def: const []);
  static String? _$alternativeTitle(Book v) => v.alternativeTitle;
  static const Field<Book, String> _f$alternativeTitle =
      Field('alternativeTitle', _$alternativeTitle, opt: true);
  static String _$sinopse(Book v) => v.sinopse;
  static const Field<Book, String> _f$sinopse =
      Field('sinopse', _$sinopse, opt: true, def: "");
  static String? _$extraLarge(Book v) => v.extraLarge;
  static const Field<Book, String> _f$extraLarge =
      Field('extraLarge', _$extraLarge, opt: true);
  static bool _$nsfw(Book v) => v.nsfw;
  static const Field<Book, bool> _f$nsfw =
      Field('nsfw', _$nsfw, opt: true, def: false);
  static String? _$bookId(Book v) => v.bookId;
  static const Field<Book, String> _f$bookId =
      Field('bookId', _$bookId, opt: true);
  static String? _$slugId(Book v) => v.slugId;
  static const Field<Book, String> _f$slugId =
      Field('slugId', _$slugId, opt: true);
  static String? _$type(Book v) => v.type;
  static const Field<Book, String> _f$type = Field('type', _$type, opt: true);
  static List<String> _$authors(Book v) => v.authors;
  static const Field<Book, List<String>> _f$authors =
      Field('authors', _$authors, opt: true, def: const []);
  static double? _$score(Book v) => v.score;
  static const Field<Book, double> _f$score =
      Field('score', _$score, opt: true);
  static String? _$status(Book v) => v.status;
  static const Field<Book, String> _f$status =
      Field('status', _$status, opt: true);
  static String? _$largeImage(Book v) => v.largeImage;
  static const Field<Book, String> _f$largeImage =
      Field('largeImage', _$largeImage, opt: true);
  static String? _$mediumImage(Book v) => v.mediumImage;
  static const Field<Book, String> _f$mediumImage =
      Field('mediumImage', _$mediumImage, opt: true);
  static List<String> _$artists(Book v) => v.artists;
  static const Field<Book, List<String>> _f$artists =
      Field('artists', _$artists, opt: true, def: const []);

  @override
  final MappableFields<Book> fields = const {
    #anilistMedia: _f$anilistMedia,
    #releases: _f$releases,
    #title: _f$title,
    #source: _f$source,
    #originalImage: _f$originalImage,
    #url: _f$url,
    #genres: _f$genres,
    #alternativeTitle: _f$alternativeTitle,
    #sinopse: _f$sinopse,
    #extraLarge: _f$extraLarge,
    #nsfw: _f$nsfw,
    #bookId: _f$bookId,
    #slugId: _f$slugId,
    #type: _f$type,
    #authors: _f$authors,
    #score: _f$score,
    #status: _f$status,
    #largeImage: _f$largeImage,
    #mediumImage: _f$mediumImage,
    #artists: _f$artists,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'Book';
  @override
  late final ClassMapperBase superMapper = ContentMapper.ensureInitialized();

  static Book _instantiate(DecodingData data) {
    return Book(
        anilistMedia: data.dec(_f$anilistMedia),
        releases: data.dec(_f$releases),
        title: data.dec(_f$title),
        source: data.dec(_f$source),
        originalImage: data.dec(_f$originalImage),
        url: data.dec(_f$url),
        genres: data.dec(_f$genres),
        alternativeTitle: data.dec(_f$alternativeTitle),
        sinopse: data.dec(_f$sinopse),
        extraLarge: data.dec(_f$extraLarge),
        nsfw: data.dec(_f$nsfw),
        bookId: data.dec(_f$bookId),
        slugId: data.dec(_f$slugId),
        type: data.dec(_f$type),
        authors: data.dec(_f$authors),
        score: data.dec(_f$score),
        status: data.dec(_f$status),
        largeImage: data.dec(_f$largeImage),
        mediumImage: data.dec(_f$mediumImage),
        artists: data.dec(_f$artists));
  }

  @override
  final Function instantiate = _instantiate;

  static Book fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Book>(map);
  }

  static Book fromJson(String json) {
    return ensureInitialized().decodeJson<Book>(json);
  }
}

mixin BookMappable {
  String toJson() {
    return BookMapper.ensureInitialized().encodeJson<Book>(this as Book);
  }

  Map<String, dynamic> toMap() {
    return BookMapper.ensureInitialized().encodeMap<Book>(this as Book);
  }

  BookCopyWith<Book, Book, Book> get copyWith =>
      _BookCopyWithImpl(this as Book, $identity, $identity);
  @override
  String toString() {
    return BookMapper.ensureInitialized().stringifyValue(this as Book);
  }

  @override
  bool operator ==(Object other) {
    return BookMapper.ensureInitialized().equalsValue(this as Book, other);
  }

  @override
  int get hashCode {
    return BookMapper.ensureInitialized().hashValue(this as Book);
  }
}

extension BookValueCopy<$R, $Out> on ObjectCopyWith<$R, Book, $Out> {
  BookCopyWith<$R, Book, $Out> get $asBook =>
      $base.as((v, t, t2) => _BookCopyWithImpl(v, t, t2));
}

abstract class BookCopyWith<$R, $In extends Book, $Out>
    implements ContentCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, Genre, ObjectCopyWith<$R, Genre, Genre>> get genres;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get authors;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get artists;
  @override
  $R call(
      {AniListMedia? anilistMedia,
      covariant ChapterReleases? releases,
      String? title,
      Source? source,
      String? originalImage,
      String? url,
      List<Genre>? genres,
      String? alternativeTitle,
      String? sinopse,
      String? extraLarge,
      bool? nsfw,
      String? bookId,
      String? slugId,
      String? type,
      List<String>? authors,
      double? score,
      String? status,
      String? largeImage,
      String? mediumImage,
      List<String>? artists});
  BookCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _BookCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Book, $Out>
    implements BookCopyWith<$R, Book, $Out> {
  _BookCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Book> $mapper = BookMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Genre, ObjectCopyWith<$R, Genre, Genre>> get genres =>
      ListCopyWith($value.genres, (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(genres: v));
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get authors =>
      ListCopyWith($value.authors, (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(authors: v));
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get artists =>
      ListCopyWith($value.artists, (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(artists: v));
  @override
  $R call(
          {Object? anilistMedia = $none,
          ChapterReleases? releases,
          String? title,
          Source? source,
          String? originalImage,
          String? url,
          List<Genre>? genres,
          Object? alternativeTitle = $none,
          String? sinopse,
          Object? extraLarge = $none,
          bool? nsfw,
          Object? bookId = $none,
          Object? slugId = $none,
          Object? type = $none,
          List<String>? authors,
          Object? score = $none,
          Object? status = $none,
          Object? largeImage = $none,
          Object? mediumImage = $none,
          List<String>? artists}) =>
      $apply(FieldCopyWithData({
        if (anilistMedia != $none) #anilistMedia: anilistMedia,
        if (releases != null) #releases: releases,
        if (title != null) #title: title,
        if (source != null) #source: source,
        if (originalImage != null) #originalImage: originalImage,
        if (url != null) #url: url,
        if (genres != null) #genres: genres,
        if (alternativeTitle != $none) #alternativeTitle: alternativeTitle,
        if (sinopse != null) #sinopse: sinopse,
        if (extraLarge != $none) #extraLarge: extraLarge,
        if (nsfw != null) #nsfw: nsfw,
        if (bookId != $none) #bookId: bookId,
        if (slugId != $none) #slugId: slugId,
        if (type != $none) #type: type,
        if (authors != null) #authors: authors,
        if (score != $none) #score: score,
        if (status != $none) #status: status,
        if (largeImage != $none) #largeImage: largeImage,
        if (mediumImage != $none) #mediumImage: mediumImage,
        if (artists != null) #artists: artists
      }));
  @override
  Book $make(CopyWithData data) => Book(
      anilistMedia: data.get(#anilistMedia, or: $value.anilistMedia),
      releases: data.get(#releases, or: $value.releases),
      title: data.get(#title, or: $value.title),
      source: data.get(#source, or: $value.source),
      originalImage: data.get(#originalImage, or: $value.originalImage),
      url: data.get(#url, or: $value.url),
      genres: data.get(#genres, or: $value.genres),
      alternativeTitle:
          data.get(#alternativeTitle, or: $value.alternativeTitle),
      sinopse: data.get(#sinopse, or: $value.sinopse),
      extraLarge: data.get(#extraLarge, or: $value.extraLarge),
      nsfw: data.get(#nsfw, or: $value.nsfw),
      bookId: data.get(#bookId, or: $value.bookId),
      slugId: data.get(#slugId, or: $value.slugId),
      type: data.get(#type, or: $value.type),
      authors: data.get(#authors, or: $value.authors),
      score: data.get(#score, or: $value.score),
      status: data.get(#status, or: $value.status),
      largeImage: data.get(#largeImage, or: $value.largeImage),
      mediumImage: data.get(#mediumImage, or: $value.mediumImage),
      artists: data.get(#artists, or: $value.artists));

  @override
  BookCopyWith<$R2, Book, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _BookCopyWithImpl($value, $cast, t);
}
