import 'package:content_library/content_library.dart';

class HistoryService {
  final HistoricController _historicController;

  HistoryService(this._historicController);

  UnmodifiableListView<HistoryEntity> get sortedByCreatedAt =>
      UnmodifiableListView(
        _historicController.entities.sorted(
          (historic1, historic2) => historic2.compareTo(historic1),
        ),
      );

  UnmodifiableListView<HistoryEntity> get entities =>
      _historicController.entities;
}
