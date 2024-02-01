// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class Genre extends Equatable {
  final String label;

  const Genre(this.label);

  @override
  List<Object?> get props => [label];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'label': label,
    };
  }

  factory Genre.fromMap(Map<dynamic, dynamic> map) {
    return Genre(
      map['label'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Genre.fromJson(String source) =>
      Genre.fromMap(json.decode(source) as Map<String, dynamic>);
}
