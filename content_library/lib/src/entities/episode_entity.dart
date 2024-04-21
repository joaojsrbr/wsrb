import 'package:content_library/src/entities/entity.dart';
import 'package:isar/isar.dart';

part 'episode_entity.g.dart';

@Collection(ignore: {'props', 'imageUrl', 'stringify', 'hashCode'})
class EpisodeEntity extends Entity {
  int episodeDuration;

  int currentDuration;

  bool isComplete;

  @Index(replace: true, unique: true)
  String stringID;

  DateTime? createdAt;
  DateTime? updatedAt;

  EpisodeEntity({
    required this.currentDuration,
    required this.episodeDuration,
    required this.stringID,
    this.createdAt,
    this.updatedAt,
    this.isComplete = false,
  });

  @override
  List<Object?> get props => [
        stringID,
        isComplete,
        currentDuration,
        episodeDuration,
      ];

  @override
  String get imageUrl => '';
}
