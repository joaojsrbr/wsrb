import 'dart:async';
import 'dart:developer' as dev;

import 'package:better_scraper/src/dom_actions.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'captcha.dart';
import 'html_parser.dart';
import 'models.dart';

void _defaulLog(String logMessage) {
  dev.log(
    logMessage.toString(),
    time: DateTime.now(),
    name: 'better_scraper',
  );
}

// Definimos um tipo para a nossa função de log para deixar o código mais claro.
typedef LogCallback = void Function(String logMessage);

typedef ShouldOverrideUrlLoading = Future<NavigationActionPolicy?> Function(
    InAppWebViewController controller, NavigationAction navigationAction);

class ScrapingSession {
  final CookieManager _cookies = CookieManager.instance();
  late final HeadlessInAppWebView _headless;
  final Completer<InAppWebViewController> _controller = Completer();
  final String? userAgent;
  final bool debugLogging;

  // Variáveis para controlar o log
  final LogCallback? onLog;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  // Timer? _timer2;
  int? _httpStatusCode;
  ShouldOverrideUrlLoading? shouldOverrideUrlLoading;
  late InAppWebViewSettings _initialSettings;

  ScrapingSession({this.userAgent, this.debugLogging = true, this.onLog = _defaulLog}) {
    PlatformInAppWebViewController.debugLoggingSettings.enabled = debugLogging;
  }

  void setHandle({ShouldOverrideUrlLoading? shouldOverrideUrlLoading}) {
    this.shouldOverrideUrlLoading = shouldOverrideUrlLoading;
  }

  /// Método privado para formatar a duração no formato MM:SS
  String _formatDuration(Duration d) {
    return d.toString().substring(2, 7); // Pega apenas MM:SS.mmm e trunca
  }

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _initialSettings = InAppWebViewSettings(
      // javaScriptCanOpenWindowsAutomatically: true,
      javaScriptEnabled: true,
      useShouldOverrideUrlLoading: true,
      transparentBackground: true,
      userAgent: userAgent,
    );
    _headless = HeadlessInAppWebView(
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        return await shouldOverrideUrlLoading?.call(controller, navigationAction) ??
            NavigationActionPolicy.ALLOW;
      },
      initialSettings: _initialSettings,
      onWebViewCreated: (controller) async {
        _controller.complete(controller);
      },
      // Chamado quando uma página começa a carregar.
      onLoadStart: (controller, url) {
        if (url.toString() == "about:blank") return;

        _stopwatch.reset();
        _stopwatch.start();
        _httpStatusCode = null; // Limpa o status anterior
        // Dispara o log de REQUEST
        onLog?.call('[WSRB_JSR] REQUEST[GET] => PATH: $url');
      },

      // onReceivedHttpStatus: (controller, url, statusCode) {
      //   _httpStatusCode = statusCode;
      // },
      onLoadStop: (controller, url) {
        if (url.toString() == "about:blank") return;
        _stopwatch.stop();
        _timer?.cancel();
        _timer = Timer(const Duration(seconds: 1), () {
          final duration = _formatDuration(_stopwatch.elapsed);
          // Usa o status code capturado ou assume 200 (sucesso)
          final status = _httpStatusCode ?? 200;
          // Dispara o log de RESPONSE
          onLog?.call('[WSRB_JSR] RESPONSE[$status][$duration] => PATH: $url');
        });
      },

      // Chamado se ocorrer um erro ao carregar a página.
      onReceivedError: (controller, url, code) {
        _stopwatch.stop();
        final duration = _formatDuration(_stopwatch.elapsed);
        // Dispara um log de RESPONSE de erro
        onLog?.call('[WSRB_JSR] RESPONSE[ERR $code][$duration] => PATH: $url');
      },
    );
    await _headless.run();
  }

  Future<void> dispose() async {
    await _headless.dispose();
  }

  Future<void> closePage([String? url]) async {
    final controller = await _controller.future;

    await controller.loadUrl(urlRequest: URLRequest(url: WebUri(url ?? 'google.com')));
    // await _waitDomReady();
  }

  Future<void> _waitDomReady({Duration timeout = const Duration(seconds: 30)}) async {
    final controller = await _controller.future;

    await Future.delayed(const Duration(seconds: 2));

    final sw = Stopwatch()..start();
    while (sw.elapsed < timeout) {
      final rs = await controller.evaluateJavascript(source: 'document.readyState');
      final html = await controller.getHtml();

      if (html == "<html><head></head><body></body></html>") {
        continue;
      }

      if (rs == 'complete' || rs == 'interactive') return;

      await Future.delayed(const Duration(milliseconds: 120));
    }
    throw TimeoutException('DOM not ready after ${timeout.inSeconds}s');
  }

  /// Executa uma sequência de ações na página web e coleta dados durante o processo.
  ///
  /// Carrega a [url] inicial e então processa a lista de [actions].
  /// Retorna um mapa contendo todos os dados coletados pelas ações [ScrapeDataAction]
  /// e [ScrapeFinalHtmlAction].
  Future<Map<String, dynamic>> executeActionsAndScrape({
    required Uri url,
    required List<DomAction> actions,
    Map<String, String>? headers,
    CaptchaHandler? captchaHandler,
  }) async {
    final controller = await _controller.future;
    final settings = _initialSettings.copy();
    settings.userAgent = userAgent;
    await controller.setSettings(settings: settings);
    await controller.loadUrl(
        urlRequest: URLRequest(url: WebUri(url.toString()), headers: headers));
    await _waitDomReady();
    final String html = (await controller.evaluateJavascript(
                source: 'document.documentElement.outerHTML'))
            ?.toString() ??
        '';
    final type = detectCaptchaByHtml(html);

    final Map<String, dynamic> results = {};

    if (type != CaptchaType.none) {
      if (captchaHandler == null || captchaHandler.context?.mounted == false) {
        // No handler: return the page as-is so the app can decide.
        return results;
      }

      // Legit human flow: open visible WebView until user finishes.

      await captchaHandler.handle(
        url: url,
        type: type,
        cookieManager: _cookies,
        headers: headers,
      );

      // After user completes, re-load headless with same URL (cookies are shared).
      await controller.loadUrl(
          urlRequest: URLRequest(url: WebUri(url.toString()), headers: headers));

      await _waitDomReady();
    }

    // A cadeia de "if/else if" foi substituída por um "switch" mais seguro e legível.
    for (final action in actions) {
      switch (action) {
        // Usamos pattern matching para verificar o tipo e extrair as propriedades.
        case ExecuteScriptAction(script: final script, resultKey: final key):
          final result = await controller.evaluateJavascript(source: script);
          if (key != null) results[key] = result;

          break;

        case WaitAction(duration: final duration):
          await Future.delayed(duration);
          break;

        case ScrapeDataAction dataAction:
          String script;
          switch (dataAction.type) {
            case ScrapingType.text:
              script = "document.querySelector('${action.selector}')?.innerText";
              break;
            case ScrapingType.html:
              script = "document.querySelector('${action.selector}')?.innerHTML";
              break;
            case ScrapingType.attribute:
              script =
                  "document.querySelector('${action.selector}')?.getAttribute('${action.attributeName}')";
              break;
          }
          final result = await controller.evaluateJavascript(source: script);
          results[action.resultKey] = result;
          break;

        case ScrapeFinalHtmlAction(resultKey: final key):
          final html = await controller.evaluateJavascript(
              source: 'document.documentElement.outerHTML');
          results[key] = html?.toString() ?? '';
          break;
      }
    }

    return results;
  }

  Future<ScrapedPage> fetchHtml(
    Uri url, {
    Map<String, String>? headers,
    CaptchaHandler? captchaHandler,
  }) async {
    final controller = await _controller.future;
    final settings = _initialSettings.copy();
    settings.userAgent = userAgent;
    await controller.setSettings(settings: settings);

    await controller.loadUrl(
        urlRequest: URLRequest(url: WebUri(url.toString()), headers: headers));
    await _waitDomReady();

    String html = (await controller.evaluateJavascript(
                source: 'document.documentElement.outerHTML'))
            ?.toString() ??
        '';
    final type = detectCaptchaByHtml(html);

    if (type != CaptchaType.none) {
      if (captchaHandler == null || captchaHandler.context?.mounted == false) {
        // No handler: return the page as-is so the app can decide.
        return ScrapedPage(url: url, html: html, finalUrl: url);
      }

      // Legit human flow: open visible WebView until user finishes.

      await captchaHandler.handle(
        url: url,
        type: type,
        cookieManager: _cookies,
        headers: headers,
      );

      // After user completes, re-load headless with same URL (cookies are shared).
      await controller.loadUrl(
          urlRequest: URLRequest(url: WebUri(url.toString()), headers: headers));

      await _waitDomReady();
      html = (await controller.evaluateJavascript(
                  source: 'document.documentElement.outerHTML'))
              ?.toString() ??
          '';
    }

    final currentUrl = await controller.getUrl();
    // _timer2?.cancel();
    // _timer2 = Timer(const Duration(seconds: 30), closePage);
    return ScrapedPage(url: url, html: html, finalUrl: currentUrl?.uriValue);
  }

  Future<HtmlParser> fetchDocument(
    Uri url, {
    Map<String, String>? headers,
    CaptchaHandler? captchaHandler,
  }) async {
    final page = await fetchHtml(
      url,
      headers: headers,
      captchaHandler: captchaHandler,
    );
    return HtmlParser.fromString(page.html);
  }

  Future<void> setCookie({
    required Uri url,
    required String name,
    required String value,
    String path = '/',
    String? domain,
  }) async {
    await _cookies.setCookie(
      url: WebUri(url.toString()),
      name: name,
      value: value,
      path: path,
      domain: domain,
      isHttpOnly: false,
      isSecure: false,
    );
  }

  Future<List<Cookie>> getCookies(Uri url) async {
    return await _cookies.getCookies(url: WebUri(url.toString()));
  }
}
