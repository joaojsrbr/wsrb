import 'dart:collection';

import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/string_extensions.dart';
import 'package:app_wsrb_jsr/app/models/release.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class Content extends Equatable {
  String get imageUrl;

  StringID get id => StringID.fromURL(url);

  final String url;

  final String? sinopse;

  final Releases releases;

  final ColorScheme? contentColorScheme;

  final String title;

  const Content({
    this.contentColorScheme,
    required this.url,
    this.sinopse,
    required this.releases,
    required this.title,
  });

  Content copyWith({
    String? title,
    String? sinopse,
    String? url,
    ColorScheme? contentColorScheme,
    Releases? releases,
  });

  Map<String, dynamic> get toMap;
}

class Releases extends ListBase<Release> {
  Releases();

  Releases.fromList(Iterable<Release> contents) {
    _array.addAll(contents);
  }

  final List<Release> _array = [];

  @override
  Release operator [](int index) => _array[index];

  @override
  void add(Release element) {
    return _array.add(element);
  }

  @override
  void operator []=(int index, Release value) => _array[index] = value;

  @override
  int get length => _array.length;

  @override
  set length(int newLength) => _array.length = newLength;
}
