class AnimeGetDataException implements Exception {
  String message = "A instancia content precisa ser do tipo Anime";
  AnimeGetDataException({
    String? message,
  }) {
    if (message != null) this.message = message;
  }

  @override
  String toString() => message;
}

class AnrollGetIdException implements Exception {
  final String message =
      'Erro ao conseguir o BUILD ID responsavel pela aquisição posterior';

  @override
  String toString() => message;
}

class GoyabuLoadDataException implements Exception {
  String message = '';

  GoyabuLoadDataException({String? message}) {
    if (message != null) this.message = message;
  }

  @override
  String toString() => message;
}
