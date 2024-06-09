import 'package:equatable/equatable.dart';

sealed class Data extends Equatable {
  const Data();

  const factory Data.textData({required String text}) = TextData;

  const factory Data.imageData({required String imageURL}) = ImageData;

  const factory Data.videoData({
    required String videoContent,
    Map<String, String>? httpHeaders,
  }) = VideoData;
}

class ImageData extends Data {
  final String imageURL;
  const ImageData({required this.imageURL});

  @override
  List<Object?> get props => [imageURL];
}

class VideoData extends Data {
  final String videoContent;
  final Map<String, String>? httpHeaders;
  const VideoData({
    required this.videoContent,
    this.httpHeaders,
  });

  @override
  List<Object?> get props => [videoContent];
}

class TextData extends Data {
  final String text;

  const TextData({required this.text});

  @override
  List<Object?> get props => [text];
}
