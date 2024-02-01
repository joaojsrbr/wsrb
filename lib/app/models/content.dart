import 'package:equatable/equatable.dart';

sealed class ChapterContent extends Equatable {
  const ChapterContent();

  const factory ChapterContent.text({required String text}) =
      TextChapterContent;

  const factory ChapterContent.image({required String imageURL}) =
      ImageChapterContent;
}

class ImageChapterContent extends ChapterContent {
  final String imageURL;
  const ImageChapterContent({required this.imageURL});

  @override
  List<Object?> get props => [imageURL];
}

class TextChapterContent extends ChapterContent {
  final String text;

  const TextChapterContent({required this.text});

  @override
  List<Object?> get props => [text];
}
