import 'package:content_library/content_library.dart';

void main() {
  // test('main ...', () async {
  //   final invocation = Invocation.genericMethod(#dispose, null, null);
  //   final obj = MockList();
  //   try {
  //     (obj as dynamic).dispose();

  //     customLog("algo");
  //   } catch (e) {
  //     customLog(e.toString());
  //   }
  // });
}

class MockList {
  void dispose() {
    customLog("test");
  }
}
