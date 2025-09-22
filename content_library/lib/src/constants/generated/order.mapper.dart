// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../order.dart';

class OrderByMapper extends EnumMapper<OrderBy> {
  OrderByMapper._();

  static OrderByMapper? _instance;
  static OrderByMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderByMapper._());
    }
    return _instance!;
  }

  static OrderBy fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  OrderBy decode(dynamic value) {
    switch (value) {
      case 'LATEST':
        return OrderBy.LATEST;
      case 'RELEVANCE':
        return OrderBy.RELEVANCE;
      case 'ALPHABET':
        return OrderBy.ALPHABET;
      case 'RATING':
        return OrderBy.RATING;
      case 'TRENDING':
        return OrderBy.TRENDING;
      case 'MOST_READ':
        return OrderBy.MOST_READ;
      case 'NEW_MANGA':
        return OrderBy.NEW_MANGA;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(OrderBy self) {
    switch (self) {
      case OrderBy.LATEST:
        return 'LATEST';
      case OrderBy.RELEVANCE:
        return 'RELEVANCE';
      case OrderBy.ALPHABET:
        return 'ALPHABET';
      case OrderBy.RATING:
        return 'RATING';
      case OrderBy.TRENDING:
        return 'TRENDING';
      case OrderBy.MOST_READ:
        return 'MOST_READ';
      case OrderBy.NEW_MANGA:
        return 'NEW_MANGA';
    }
  }
}

extension OrderByMapperExtension on OrderBy {
  String toValue() {
    OrderByMapper.ensureInitialized();
    return MapperContainer.globals.toValue<OrderBy>(this) as String;
  }
}
