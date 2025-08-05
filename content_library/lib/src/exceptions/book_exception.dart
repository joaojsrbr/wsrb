// ignore_for_file: public_member_api_docs, sort_constructors_first

class BookGetDataException implements Exception {
  String message = "A instancia content precisa ser do tipo Book";
  BookGetDataException({String? message}) {
    if (message != null) this.message = message;
  }

  @override
  String toString() => message;
}
