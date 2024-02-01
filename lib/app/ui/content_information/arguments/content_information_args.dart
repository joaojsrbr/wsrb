// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:app_wsrb_jsr/app/models/content.dart';
import 'package:equatable/equatable.dart';

class ContentInformationArgs extends Equatable {
  final Content content;

  const ContentInformationArgs({required this.content});

  @override
  List<Object?> get props => [content];
}
