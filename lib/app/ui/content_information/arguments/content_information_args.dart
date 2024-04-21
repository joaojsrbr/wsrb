// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:content_library/content_library.dart';

import 'package:equatable/equatable.dart';

class ContentInformationArgs extends Equatable {
  final Content content;

  const ContentInformationArgs({required this.content});

  @override
  List<Object?> get props => [content];
}
