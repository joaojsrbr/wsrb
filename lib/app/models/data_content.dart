import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

abstract class DataContent extends Equatable {
  const DataContent({
    required this.url,
    required this.title,
  });

  final String url;

  final String title;

  String get id => const Uuid().v5(Uuid.NAMESPACE_URL, url);

  Map<String, dynamic> get toMap;

  String get number;
}
