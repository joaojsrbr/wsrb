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

  final AllDataContent allDataContent;

  final ColorScheme? contentColorScheme;

  final String title;

  const Content({
    this.contentColorScheme,
    required this.url,
    this.sinopse,
    this.allDataContent = const AllDataContent(),
    required this.title,
  });

  Content copyWith({
    String? title,
    String? sinopse,
    String? url,
    ColorScheme? contentColorScheme,
    AllDataContent? allDataContent,
  });

  Map<String, dynamic> get toMap;
}

class AllDataContent extends ListBase<DataContent> {
  const AllDataContent([this._array = const []]);

  AllDataContent.empty() : _array = List.empty();

  final List<DataContent> _array;

  @override
  DataContent operator [](int index) => _array[index];

  @override
  void operator []=(int index, DataContent value) => _array[index] = value;

  @override
  int get length => _array.length;

  @override
  set length(int newLength) => _array.length = newLength;
}
