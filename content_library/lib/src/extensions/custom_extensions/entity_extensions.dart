import 'package:content_library/content_library.dart';

extension EntityExtensions on HistoryEntity {
  Duration get cdToDuration {
    return switch (this) {
      EpisodeEntity data => Duration(microseconds: data.currentDuration),
      _ => Duration.zero,
    };
  }

  Duration get epdToDuration {
    return switch (this) {
      EpisodeEntity data => Duration(microseconds: data.episodeDuration),
      _ => Duration.zero,
    };
  }
}
