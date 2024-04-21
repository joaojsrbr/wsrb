// ignore_for_file: public_member_api_docs, sort_constructors_first
class BookException implements Exception {
  final String message;
  const BookException({
    required this.message,
  });

  @override
  String toString() => message;
}
