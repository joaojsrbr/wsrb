import 'package:equatable/equatable.dart';

class Genre extends Equatable {
  final String label;

  const Genre(this.label);

  @override
  List<Object?> get props => [label];

  Map<String, dynamic> get toMap {
    return <String, dynamic>{
      'label': label,
    };
  }

  factory Genre.fromMap(Map<dynamic, dynamic> map) {
    return Genre(map['label'] as String);
  }
}
