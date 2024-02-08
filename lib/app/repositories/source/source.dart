// ignore_for_file: non_constant_identifier_names

import 'package:app_wsrb_jsr/app/core/constants/source.dart';
import 'package:app_wsrb_jsr/app/models/content.dart';
import 'package:app_wsrb_jsr/app/models/data_content.dart';
import 'package:app_wsrb_jsr/app/utils/result.dart';
import 'package:app_wsrb_jsr/app/models/data.dart';
import 'package:app_wsrb_jsr/app/repositories/content_repository.dart';

abstract class RSource {
  final int initialIndex;

  final ContentRepository contentRepository;

  const RSource(
    this.contentRepository, {
    required this.initialIndex,
  });

  Source get source;

  String get BASE_URL;

  Future<bool> loadData();

  Future<Result<Content>> getData(Content content);

  Future<Result<List<Data>>> getContent(DataContent dataContent);
}
