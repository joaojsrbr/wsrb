import 'package:better_scraper/better_scraper.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CookieUtil.deleteAllCookies();

  runApp(MaterialApp(home: Scaffold(body: const DemoApp())));
}

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});
  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  final session = ScrapingSession(
      userAgent:
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
      debugLogging: false);
  String? title;
  String urlInput = 'https://betteranime.net';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    () async {
      await session.init();
      await _scrape();
    }();
  }

  Future<void> _scrape() async {
    setState(() => loading = true);
    final parser = await session.fetchDocument(
      Uri.parse(urlInput),
      captchaHandler: HumanCaptchaHandler(context: context),
    );
    setState(() {
      title = parser.queryText('title');
      loading = false;
    });
  }

  @override
  void dispose() {
    session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('better_scraper demo')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'URL'),
                controller: TextEditingController(text: urlInput),
                onChanged: (v) => urlInput = v,
                onSubmitted: (_) => _scrape(),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: loading ? null : _scrape,
                child: Text(loading ? 'Carregando...' : 'Scrape'),
              ),
              const SizedBox(height: 24),
              Text('Título da página: ${title ?? '(vazio)'}'),
              const SizedBox(height: 12),
              const Text(
                  'Se houver desafio/captcha, uma tela será aberta para você concluir manualmente.'),
            ],
          ),
        ),
      ),
    );
  }
}
