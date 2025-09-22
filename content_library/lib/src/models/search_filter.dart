class SearchFilter {
  final String query;
  final int page;
  final String? genre;
  final String? year;
  final String? season;
  final String? format;
  final String? airingStatus;

  const SearchFilter({
    required this.query,
    this.page = 1,
    this.genre,
    this.year,
    this.season,
    this.format,
    this.airingStatus,
  });

  SearchFilter copyWith({
    String? genre,
    String? year,
    int? page,
    String? query,
    String? season,
    String? format,
    String? airingStatus,
  }) {
    return SearchFilter(
      page: page ?? this.page,
      genre: genre ?? this.genre,
      query: query ?? this.query,
      year: year ?? this.year,
      season: season ?? this.season,
      format: format ?? this.format,
      airingStatus: airingStatus ?? this.airingStatus,
    );
  }

  Map<String, dynamic> toMap() => {
    "genre": genre,
    "year": year,
    "season": season,
    "format": format,
    "airingStatus": airingStatus,
  }..removeWhere((_, v) => v == null || v == "Any");
}
