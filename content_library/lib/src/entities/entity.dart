// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

abstract class Entity with EquatableMixin {
  Id id = Isar.autoIncrement;
}

abstract class ContentEntity extends Entity {
  final String stringID;
  ContentEntity({required this.stringID});
}

abstract class HistoryEntity extends Entity
    implements Comparable<HistoryEntity> {
  double get percent;
  bool get isComplete;
}
