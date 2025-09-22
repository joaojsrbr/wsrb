import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('main ...', () async {
    final uri = Uri(
      pathSegments: [RouteName.HOME.subRouter, RouteName.CONTENTINFO.subRouter],
    );
    customLog(uri.toString());
  });
}

class MockList {
  void dispose() {
    customLog("test");
  }
}
