// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: must_be_immutable

import 'package:content_library/src/entities/entity.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'category_entity.g.dart';

@Collection(ignore: {'props', 'imageUrl', 'stringify', 'hashCode'})
final class CategoryEntity extends OtherEntity {
  final String title;
  final String? description;
  final List<String> ids;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @Index(replace: true, unique: true)
  final String stringID;

  CategoryEntity({
    required this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.ids = const [],
  }) : stringID = const Uuid().v5(Namespace.url.value, title);

  @override
  List<Object?> get props => [
    title,
    description,
    ids,
    createdAt,
    updatedAt,
    stringID,
  ];

  CategoryEntity copyWith({
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? stringID,
    List<String>? ids,
  }) {
    final obj = CategoryEntity(
      title: title ?? this.title,
      ids: ids ?? this.ids,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
    obj.id = id;
    return obj;
  }
}
