// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: non_constant_identifier_names

import 'dart:collection';

import 'package:content_library/content_library.dart';

abstract class RSource {
  final int initialIndex;
  final SourceContext context;

  const RSource(this.context, {required this.initialIndex});

  Source get source;

  /// Loads a page of content. Returns true if more pages exist.
  Future<bool> loadPage([int page]);

  /// Fetches full details for a content item (anime/manga).
  Future<Result<Content>> getDetails(Content content);

  /// Fetches the video/data URL for a specific release (episode/chapter).
  Future<Result<List<Data>>> getReleaseData(Release release);

  /// Fetches the list of releases for a content item.
  Future<Result<Content>> getContentReleases(Content content, int page);

  /// Searches content by filter criteria.
  Future<Result<SearchResult>> search(SearchFilter filter);

  /// Returns available filters for this source.
  Future<Result<List<Filter>>> getFilters() => Future.value(Result.success([]));

  /// Whether this source supports search.
  bool get supportsSearch => true;

  /// Whether this source supports filters.
  bool get supportsFilters => false;

  /// Convenience: check if source has more content to load.
  bool get hasMore => context.state.hasMore;

  /// Current page index.
  int get currentPage => context.state.index;
}

class Filter {
  final String id;
  final String label;
  final FilterType type;
  final List<FilterOption>? options;

  const Filter({
    required this.id,
    required this.label,
    required this.type,
    this.options,
  });
}

enum FilterType { genre, year, status, type, order, letter, search }

class FilterOption {
  final String id;
  final String label;
  final String? value;

  const FilterOption({required this.id, required this.label, this.value});
}

class SearchResult {
  final SplayTreeSet<Content> contents;
  final int page;
  final int? totalOfPages;
  const SearchResult({
    required this.contents,
    required this.page,
    this.totalOfPages,
  });
}
