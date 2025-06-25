import 'package:content_library/content_library.dart';

extension EntityExtensions on HistoryEntity {
  Duration get cdToDuration {
    return switch (this) {
      EpisodeEntity data => Duration(
          microseconds: data.getLastCurrentPosition()?.currentDuration ?? 0),
      _ => Duration.zero,
    };
  }

  Duration get epdToDuration {
    return switch (this) {
      EpisodeEntity data => Duration(
          microseconds: data.getLastCurrentPosition()?.episodeDuration ?? 0),
      _ => Duration.zero,
    };
  }
}
