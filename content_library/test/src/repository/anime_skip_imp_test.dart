import 'package:content_library/content_library.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('anime skip imp ...', () async {
    await dotenv.load();
    final GraphQLApiClient graphQLApiClient = GraphQLApiClient();
    final AnimeSkipRepository animeSkipRepository = AnimeSkipRepository(graphQLApiClient);
    final result = await animeSkipRepository.getTimeStampsByName(
      search: "Attack on titan",
    );

    result
        .fold(onSuccess: (success) => success)
        ?.map((e) => e.times)
        .flattened
        .map((e) => e.at)
        .forEach(customLog);

    customLog(result);
  });
  test("timestamp", () async {
    String timestampString = "22.11087333333333";

    // Converte a string para um double
    double timestampInSeconds = double.parse(timestampString);

    // Converte o valor para uma Duration (em microseconds, para maior precisão)
    Duration duration = Duration(microseconds: (timestampInSeconds * 1000000).toInt());

    // Exibe a duração
    customLog(duration); // Exemplo de saída: 0:00:22.110873
  });
}
