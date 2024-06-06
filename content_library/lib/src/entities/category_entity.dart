import 'package:content_library/src/entities/entity.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'category_entity.g.dart';

@Collection(ignore: {'props', 'imageUrl', 'stringify', 'hashCode'})
class CategoryEntity extends Entity {
  String title;
  String? description;

  List<String> ids = [];

  DateTime? createdAt;

  DateTime? updatedAt;

  @Index(replace: true, unique: true)
  String get stringID => const Uuid().v5(Uuid.NAMESPACE_URL, title);

  CategoryEntity({
    required this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        ids,
        createdAt,
        updatedAt,
        stringID,
      ];
}
