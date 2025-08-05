// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:content_library/content_library.dart';
import 'package:equatable/equatable.dart';

class ContentInformationArgs extends Equatable {
  final Content content;
  final bool getData;
  final bool isLibrary;
  const ContentInformationArgs({required this.content, this.getData = true, this.isLibrary = false});

  @override
  List<Object?> get props => [content, isLibrary, getData];
}
