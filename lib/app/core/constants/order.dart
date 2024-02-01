// ignore_for_file: constant_identifier_names

enum OrderBy {
  RELEVANCE('', 'Relevância'),
  LATEST('latest', 'Mais recentes'),
  ALPHABET('alphabet', 'A-Z'),
  RATING('rating', 'Avaliação'),
  TRENDING('trending', 'Em alta'),
  MOST_READ('views', 'Mais lidos'),
  NEW_MANGA('new-manga', 'Novo');

  final String label;
  final String name;

  const OrderBy(this.label, this.name);
}
