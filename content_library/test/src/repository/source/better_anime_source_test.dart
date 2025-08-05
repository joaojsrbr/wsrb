import 'package:content_library/content_library.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

void main() {
  test('better anime source ...', () async {
    final client = DioClient();

    final response = await client.get("https://betteranime.net");
    final Document document = parse(response.data);

    final livewireElement = document
        .querySelectorAll('script')
        .firstWhereOrNull(
          (element) => element.attributes.values.any(
            (value) => value.contains("livewire"),
          ),
        );

    final dataCsrf = livewireElement?.attributes["data-csrf"];

    customLog(dataCsrf);
  });
}
