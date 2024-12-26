import 'package:content_library/content_library.dart';

class SlimeReadBookResponse {
  final int total;
  final int pages;
  final int page;
  final List<SlimeReadBook> data;

  const SlimeReadBookResponse({
    required this.total,
    required this.pages,
    required this.page,
    required this.data,
  });

  factory SlimeReadBookResponse.fromJson(Map<String, dynamic> json) {
    return SlimeReadBookResponse(
      total: json['total'],
      pages: json['pages'],
      page: json['page'],
      data: (json['data'] as List).mapIndexed((index, e) {
        return SlimeReadBook.fromJson(e);
      }).toList(),
    );
  }
}

class SlimeReadBook {
  final String bookNameOriginal;
  final String bookName;
  final int? bookNsfw;
  final String bookImage;
  final int bookId;
  final int? bookPublicationYear;
  final int? bookFlagged;
  final String? bookRedirectLink;
  final List<BookTag> bookTag;
  final String bookDateCreated;
  final List<BookCategory> bookCategories;
  final List<BookTemp> bookTemp;
  final int bookGenreId;
  final int? bookLanguageId;
  final String bookNameAlternatives;
  final bool nsfw;

  const SlimeReadBook({
    required this.bookNameOriginal,
    required this.bookName,
    this.bookNsfw,
    required this.bookImage,
    required this.bookId,
    required this.bookTag,
    required this.bookDateCreated,
    required this.bookCategories,
    required this.bookTemp,
    required this.bookGenreId,
    required this.bookNameAlternatives,
    required this.nsfw,
    this.bookLanguageId,
    this.bookPublicationYear,
    this.bookFlagged,
    this.bookRedirectLink,
  });

  factory SlimeReadBook.fromJson(Map<String, dynamic> json) {
    return SlimeReadBook(
      bookNameOriginal: json['book_name_original'],
      bookName: json['book_name'],
      bookNsfw: json['book_nsfw'],
      bookImage: json['book_image'],
      bookId: json['book_id'],
      bookPublicationYear: json['book_publication_year'],
      bookFlagged: json['book_flagged'],
      bookRedirectLink: json['book_redirect_link'],
      bookTag: (json['book_tag'] as List?)
              ?.map((e) => BookTag.fromJson(e))
              .toList() ??
          [],
      bookDateCreated: json['book_date_created'],
      bookCategories: (json['book_categories'] as List?)
              ?.map((e) => BookCategory.fromJson(e))
              .toList() ??
          [],
      bookTemp: (json['book_temp'] as List?)
              ?.map((e) => BookTemp.fromJson(e))
              .toList() ??
          [],
      bookGenreId: json['book_genre_id'],
      bookLanguageId: json['book_language_id'],
      bookNameAlternatives: json['book_name_alternatives'],
      nsfw: json['nsfw'],
    );
  }
}

class BookTag {
  final Tag tag;

  const BookTag({required this.tag});

  factory BookTag.fromJson(Map<String, dynamic> json) {
    return BookTag(tag: Tag.fromJson(json['tag']));
  }
}

class Tag {
  final bool tagNsfw;
  final String tagName;
  final String tagNamePtBR;

  const Tag({
    required this.tagNsfw,
    required this.tagName,
    required this.tagNamePtBR,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      tagNsfw: json['tag_nsfw'],
      tagName: json['tag_name'],
      tagNamePtBR: json['tag_name_ptBR'],
    );
  }
}

class BookCategory {
  final Categories categories;

  const BookCategory({required this.categories});

  factory BookCategory.fromJson(Map<String, dynamic> json) {
    return BookCategory(categories: Categories.fromJson(json['categories']));
  }
}

class Categories {
  final String catName;
  final bool catNsfw;
  final String catNamePtBR;

  const Categories({
    required this.catName,
    required this.catNsfw,
    required this.catNamePtBR,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      catName: json['cat_name'],
      catNsfw: json['cat_nsfw'],
      catNamePtBR: json['cat_name_ptBR'],
    );
  }
}

class BookTemp {
  final List<BookTempCap> bookTempCaps;

  const BookTemp({required this.bookTempCaps});

  factory BookTemp.fromJson(Map<String, dynamic> json) {
    return BookTemp(
      bookTempCaps: (json['book_temp_caps'] as List?)
              ?.map((e) => BookTempCap.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class BookTempCap {
  final double btcCap;
  final String btcDateCreated;
  final String btcDateUpdated;
  final String? btcName;
  final Scan scan;

  const BookTempCap({
    required this.btcCap,
    required this.btcDateCreated,
    required this.btcDateUpdated,
    this.btcName,
    required this.scan,
  });

  factory BookTempCap.fromJson(Map<String, dynamic> json) {
    return BookTempCap(
      btcCap: double.parse(json['btc_cap'].toString()),
      btcDateCreated: json['btc_date_created'],
      btcDateUpdated: json['btc_date_updated'],
      btcName: json['btc_name'],
      scan: Scan.fromJson(json['scan']),
    );
  }
}

class Scan {
  final bool scanAutoUpdate;
  final int scanId;
  final String scanName;

  const Scan({
    required this.scanAutoUpdate,
    required this.scanId,
    required this.scanName,
  });

  factory Scan.fromJson(Map<String, dynamic> json) {
    return Scan(
      scanAutoUpdate: json['scan_auto_update'],
      scanId: json['scan_id'],
      scanName: json['scan_name'],
    );
  }
}
