import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

abstract class Entity with EquatableMixin {
  Id id = Isar.autoIncrement;
}

abstract class ContentEntity extends Entity {}

abstract class HistoryEntity extends Entity
    implements Comparable<HistoryEntity> {}
