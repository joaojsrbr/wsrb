import 'package:app_wsrb_jsr/app/utils/quicksort.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('quicksort ...', () async {
    final QuickSort<int> quickSort = QuickSort.from([1, 10, 9, 20, 2]);
    customLog(quickSort);
  });
}
