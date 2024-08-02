import 'package:content_library/src/utils/object_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

abstract class Entity with EquatableMixin {
  Id id = Isar.autoIncrement;
}

abstract class ContentEntity extends Entity
    with MergeClassEntity<ContentEntity> {}

abstract class HistoryEntity extends Entity
    implements Comparable<HistoryEntity> {}
