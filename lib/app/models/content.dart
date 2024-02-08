import 'dart:collection';

import 'package:app_wsrb_jsr/app/models/data_content.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

abstract class Content extends Equatable {
  String get imageUrl;

  String get id => const Uuid().v5(Uuid.NAMESPACE_URL, url);

  final String url;

  final String? sinopse;

  final DataContents dataContents;

  final ColorScheme? contentColorScheme;

  final String title;

  const Content({
    this.contentColorScheme,
    required this.url,
    this.sinopse,
    required this.dataContents,
    required this.title,
  });

  Content copyWith({
    String? title,
    String? sinopse,
    String? url,
    ColorScheme? contentColorScheme,
    DataContents? dataContents,
  });

  Map<String, dynamic> get toMap;
}

class DataContents extends ListBase<DataContent> {
  DataContents();

  final List<DataContent> _array = [];

  @override
  DataContent operator [](int index) => _array[index];

  @override
  void add(DataContent element) {
    _array.add(element);
  }

  @override
  void operator []=(int index, DataContent value) => _array[index] = value;

  @override
  int get length => _array.length;
  @override
  set length(int newLength) => _array.length = newLength;
}
