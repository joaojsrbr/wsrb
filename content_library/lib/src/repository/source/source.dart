// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: non_constant_identifier_names

import 'dart:collection';

import 'package:content_library/content_library.dart';

abstract class RSource {
  final int initialIndex;
  final SourceContext context;

  const RSource(this.context, {required this.initialIndex});

  Source get source;

  Future<bool> loadData();

  Future<Result<Content>> getData(Content content);

  Future<Result<List<Data>>> getContent(Release release);

  Future<Result<Content>> getReleases(Content content, int page);

  Future<Result<SearchResult>> search(SearchFilter filter);

  Future<Result<List<Filter>>> getFilters() => Future.value(Result.success([]));
}

class Filter {
  final String id;
  final String label;
  final FilterType type;
  final List<FilterOption>? options;

  const Filter({required this.id, required this.label, required this.type, this.options});
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
  const SearchResult({required this.contents, required this.page, this.totalOfPages});
}
