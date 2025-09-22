import 'package:equatable/equatable.dart';
import 'package:html/dom.dart';

class Genre extends Equatable {
  final String label;

  const Genre(this.label);

  factory Genre.byElement(Element element) {
    final label = element.text.trim();
    return Genre(label);
  }

  @override
  List<Object?> get props => [label];
}
