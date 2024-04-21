class AnrollGetIdException implements Exception {
  final String message =
      'Erro ao conseguir o BUILD ID responsavel pela aquisição posterior';

  @override
  String toString() => message;
}
