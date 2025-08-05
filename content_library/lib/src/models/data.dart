// ignore_for_file: public_member_api_docs, sort_constructors_first, constant_identifier_names
import 'dart:io';

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
  final Quality quality;
  const VideoData({
    required this.videoContent,
    this.httpHeaders,
    this.quality = Quality.NONE,
  });

  @override
  List<Object?> get props => [videoContent, quality];
}

enum Quality {
  Q480P("480p"),
  Q720P("720p"),
  Q1080P("1080p"),
  NONE("None");

  final String label;
  const Quality(this.label);
}

class FileVideoData extends Data {
  final File file;
  const FileVideoData({required this.file});

  @override
  List<Object?> get props => [file];
}

class TextData extends Data {
  final String text;

  const TextData({required this.text});

  @override
  List<Object?> get props => [text];
}
