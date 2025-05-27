// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'package:content_library/content_library.dart';
import 'package:isar/isar.dart';

part 'app_config_entity.g.dart';

@Collection(
  ignore: {
    'props',
    'stringify',
    'hashCode',
  },
)
class AppConfigEntity extends OtherEntity {
  @enumerated
  final OrderBy orderBy;

  final bool reverseContents;

  @enumerated
  final Source source;

  @override
  List<Object?> get props => [
        orderBy,
        reverseContents,
        source,
      ];

  AppConfigEntity({
    required this.orderBy,
    required this.reverseContents,
    required this.source,
  });

  factory AppConfigEntity.init() => AppConfigEntity(
        orderBy: OrderBy.LATEST,
        source: Source.ANROLL,
        reverseContents: true,
      );

  AppConfigEntity copyWith({
    OrderBy? orderBy,
    bool? reverseContents,
    Source? source,
    ConnectivityResult? connectivityResult,
    double? historicSavePercent,
  }) {
    final newConfig = AppConfigEntity(
      orderBy: orderBy ?? this.orderBy,
      reverseContents: reverseContents ?? this.reverseContents,
      source: source ?? this.source,
    );
    newConfig.id = id;
    return newConfig;
  }

  @override
  bool? get stringify => true;
}
