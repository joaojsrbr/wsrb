import 'package:app_wsrb_jsr/app/models/data_content.dart';

class Episode extends DataContent {
  const Episode({
    required super.url,
    required super.title,
  });

  @override
  List<Object?> get props => [id, title, url];

  @override
  Map<String, dynamic> get toMap {
    return <String, dynamic>{
      'url': url,
      'title': title,
    };
  }

  factory Episode.fromMap(Map<dynamic, dynamic> map) {
    return Episode(
      url: map['url'] as String,
      title: map['title'] as String,
    );
  }

  @override
  String get number {
    final rgx = RegExp(r'Cap.+[0-9].-');
    final rgx2 = RegExp(r'Cap.+[0-9]');

    final match = rgx.stringMatch(title) ?? rgx2.stringMatch(title) ?? '';

    return match
        .replaceAll(RegExp(r'\([0-9]\)|\(\)|\([0-9]'), '')
        .replaceFirst('-', '')
        .replaceAll(RegExp('[^0-9]'), '')
        .trim();
  }
}
