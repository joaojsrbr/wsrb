import 'package:equatable/equatable.dart';

class Genre extends Equatable {
  final String label;

  const Genre(this.label);

  @override
  List<Object?> get props => [label];
}
