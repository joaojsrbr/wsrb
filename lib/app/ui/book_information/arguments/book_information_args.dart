// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:app_wsrb_jsr/app/models/book.dart';
import 'package:equatable/equatable.dart';

class BookInformationArgs extends Equatable {
  final Book book;

  const BookInformationArgs({required this.book});

  @override
  List<Object?> get props => [book];
}
