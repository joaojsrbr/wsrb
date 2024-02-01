// ignore_for_file: non_constant_identifier_names

import 'package:app_wsrb_jsr/app/core/constants/source.dart';
import 'package:app_wsrb_jsr/app/utils/result.dart';
import 'package:app_wsrb_jsr/app/models/book.dart';
import 'package:app_wsrb_jsr/app/models/chapter.dart';
import 'package:app_wsrb_jsr/app/models/content.dart';
import 'package:app_wsrb_jsr/app/repositories/book_repository.dart';

abstract class RSource {
  final int initialIndex;

  final BookRepository bookRepository;

  const RSource(
    this.bookRepository, {
    required this.initialIndex,
  });

  Source get source;

  String get BASE_URL;

  Future<bool> loadData();
  Future<Result<Book>> bookData(Book book);
  Future<Result<List<ChapterContent>>> getContent(Chapter chapter);
}
