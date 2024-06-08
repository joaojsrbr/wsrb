// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

enum OrderBy {
  LATEST('latest', 'Mais recentes'),
  RELEVANCE('', 'Relevância'),
  ALPHABET('alphabet', 'A-Z'),
  RATING('rating', 'Avaliação'),
  TRENDING('trending', 'Em alta'),
  MOST_READ('views', 'Mais lidos'),
  NEW_MANGA('new-manga', 'Novo');

  final String label;
  final String name;

  const OrderBy(this.label, this.name);

  @override
  String toString() => name;

  static List<OrderBy> get list =>
      OrderBy.values.where((element) => element != OrderBy.RELEVANCE).toList();
}

extension OrderByExtension on OrderBy {
  IconData get iconData {
    final map = {
      MdiIcons.history,
      MdiIcons.alertCircleOutline,
      MdiIcons.alphabetical,
      MdiIcons.star,
      MdiIcons.trendingUp,
      MdiIcons.magnifyPlusOutline,
      MdiIcons.newBox,
    };
    return map.elementAt(index);
  }
}
