import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

abstract class Entity with EquatableMixin {
  Id id = Isar.autoIncrement;

  String? get imageUrl => null;
}
