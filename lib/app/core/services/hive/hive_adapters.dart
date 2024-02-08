part of 'hive_service.dart';

void _hiveAdapters() {
  Hive.registerAdapter(_OrderByAdapter());
  Hive.registerAdapter(_SourceAdapter());
  // Hive.registerAdapter(_BookAdapter());
  Hive.registerAdapter(_CotentAdapter());
}

class _OrderByAdapter extends TypeAdapter<OrderBy> {
  @override
  OrderBy read(BinaryReader reader) {
    final int index = reader.readInt();
    return OrderBy.values.elementAt(index);
  }

  @override
  int get typeId => 1;

  @override
  void write(BinaryWriter writer, OrderBy obj) {
    writer.writeInt(obj.index);
  }
}

class _SourceAdapter extends TypeAdapter<Source> {
  @override
  Source read(BinaryReader reader) {
    final int index = reader.readInt();
    return Source.values.elementAt(index);
  }

  @override
  int get typeId => 2;

  @override
  void write(BinaryWriter writer, Source obj) {
    writer.writeInt(obj.index);
  }
}

// class _BookAdapter extends TypeAdapter<Book> {
//   @override
//   Book read(BinaryReader reader) {
//     final Map<dynamic, dynamic> map = reader.readMap();
//     return Book.fromMap(map);
//   }

//   @override
//   int get typeId => 3;

//   @override
//   void write(BinaryWriter writer, Book obj) {
//     writer.writeMap(obj.toMap);
//   }
// }

class _CotentAdapter extends TypeAdapter<Content> {
  @override
  Content read(BinaryReader reader) {
    final Map<dynamic, dynamic> map = reader.readMap();
    try {
      return Book.fromMap(map);
    } catch (_) {
      return Anime.fromMap(map);
    }
  }

  @override
  int get typeId => 4;

  @override
  void write(BinaryWriter writer, Content obj) {
    if (obj is Anime) {
      final anime = obj;
      writer.writeMap(anime.toMap);
    } else if (obj is Book) {
      final book = obj;
      writer.writeMap(book.toMap);
    }
  }
}
