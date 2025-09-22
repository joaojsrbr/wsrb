import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// Adicionada enum para controlar o modo de exibição
enum CaptchaHandlerDisplayMode { bottomSheet, dialog }

enum CaptchaType { none, simpleImage, turnstile, hcaptcha, recaptcha, unknown }

CaptchaType detectCaptchaByHtml(String html) {
  final h = html.toLowerCase();
  if (h.contains('cf-turnstile')) return CaptchaType.turnstile;
  if (h.contains('hcaptcha')) return CaptchaType.hcaptcha;
  if (h.contains('g-recaptcha')) return CaptchaType.recaptcha;
  if (h.contains('captcha')) return CaptchaType.simpleImage;
  return CaptchaType.none;
}

abstract class CaptchaHandler {
  Future<String?> handle({
    required Uri url,
    required CaptchaType type,
    required CookieManager cookieManager,
    Map<String, String>? headers,
  });
  final BuildContext? context;
  CaptchaHandler({this.context});
}

class HumanCaptchaHandler extends CaptchaHandler {
  final String? userAgent;
  // Permite escolher o modo de exibição no construtor
  final CaptchaHandlerDisplayMode displayMode;

  HumanCaptchaHandler({
    super.context,
    this.userAgent,
    this.displayMode = CaptchaHandlerDisplayMode.bottomSheet,
  });

  @override
  Future<String?> handle({
    required Uri url,
    required CaptchaType type,
    required CookieManager cookieManager,
    Map<String, String>? headers,
  }) async {
    if (context == null) return null;
    final captchaScreen = _CaptchaScreen(
      initialUrl: url,
      cookieManager: cookieManager,
      userAgent: userAgent,
      headers: headers,
      displayMode: displayMode,
    );

    // Usa o modo de exibição escolhido
    if (displayMode == CaptchaHandlerDisplayMode.dialog) {
      return await Navigator.of(context!).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => captchaScreen,
      ));
    } else {
      return await showModalBottomSheet(
        context: context!,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => captchaScreen,
      );
    }
  }
}

class _CaptchaScreen extends StatefulWidget {
  final Uri initialUrl;
  final String? userAgent;
  final Map<String, String>? headers;
  final CaptchaHandlerDisplayMode displayMode;
  final CookieManager cookieManager;

  const _CaptchaScreen({
    required this.initialUrl,
    required this.cookieManager,
    this.userAgent,
    this.headers,
    required this.displayMode,
  });

  @override
  State<_CaptchaScreen> createState() => _CaptchaScreenState();
}

class _CaptchaScreenState extends State<_CaptchaScreen> {
  InAppWebViewController? controller;
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    // Renderiza a UI correta baseada no displayMode
    if (widget.displayMode == CaptchaHandlerDisplayMode.dialog) {
      return _BuildAsPage(this);
    }
    return _BuildAsBottomSheet(this);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void _setLoading(bool loading) {
    setState(() {
      this.loading = loading;
    });
  }
}

class _BuildAsPage extends StatelessWidget {
  final _CaptchaScreenState state;
  const _BuildAsPage(this.state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Verificação'),
        actions: [
          IconButton(
            onPressed: () async {
              final html = (await state.controller
                      ?.evaluateJavascript(source: 'document.documentElement.outerHTML'))
                  .toString();
              if (context.mounted) Navigator.of(context).pop(html);
            },
            icon: const Icon(Icons.check),
            tooltip: 'Concluído',
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.loading) const LinearProgressIndicator(),
          Expanded(child: _BuildWebView(state)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () async {
                if (await state.controller?.canGoBack() ?? false) {
                  await state.controller?.goBack();
                }
              },
              icon: const Icon(Icons.arrow_back),
            ),
            IconButton(
              onPressed: () async {
                if (await state.controller?.canGoForward() ?? false) {
                  await state.controller?.goForward();
                }
              },
              icon: const Icon(Icons.arrow_forward),
            ),
            IconButton(
              onPressed: () async {
                state._setLoading(true);

                await state.controller?.reload();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildAsBottomSheet extends StatelessWidget {
  final _CaptchaScreenState state;
  const _BuildAsBottomSheet(this.state);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            _CaptchaHeader(
              controller: state.controller,
              onReload: () => state._setLoading(true),
              onCompleted: () async {
                final html = (await state.controller?.evaluateJavascript(
                        source: 'document.documentElement.outerHTML'))
                    .toString();

                if (context.mounted) Navigator.of(context).pop(html);
              },
            ),
            if (state.loading) const LinearProgressIndicator(),
            Expanded(child: _BuildWebView(state)),
          ],
        ),
      ),
    );
  }
}

class _BuildWebView extends StatelessWidget {
  final _CaptchaScreenState state;
  const _BuildWebView(this.state);

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
          url: WebUri(state.widget.initialUrl.toString()), headers: state.widget.headers),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        useShouldOverrideUrlLoading: true,
        userAgent: state.widget.userAgent,
        applicationNameForUserAgent: 'WebViewPro',
      ),
      onWebViewCreated: (c) => state.controller = c,
      onLoadStop: (c, url) async {
        if (url == null) return;

        state._setLoading(false);
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final req = navigationAction.request.url.toString();
        if (req.contains('intent://') || req.contains('bb2r.com')) {
          return NavigationActionPolicy.CANCEL;
        }

        return NavigationActionPolicy.ALLOW;
      },
    );
  }
}

// Widget dedicado para o cabeçalho do BottomSheet, conforme solicitado.
class _CaptchaHeader extends StatelessWidget {
  final InAppWebViewController? controller;
  final VoidCallback onReload;
  final VoidCallback onCompleted;

  const _CaptchaHeader({
    required this.controller,
    required this.onReload,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        // scrollDirection: Axis.horizontal,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // IconButton(
              //   icon: const Icon(Icons.arrow_back),
              //   tooltip: 'Voltar',
              //   onPressed: () async {
              //     if (await controller?.canGoBack() ?? false) {
              //       await controller?.goBack();
              //     }
              //   },
              // ),
              // IconButton(
              //   icon: const Icon(Icons.arrow_forward),
              //   tooltip: 'Avançar',
              //   onPressed: () async {
              //     if (await controller?.canGoForward() ?? false) {
              //       await controller?.goForward();
              //     }
              //   },
              // ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Recarregar',
                onPressed: () async {
                  onReload();
                  await controller?.reload();
                },
              ),
              const Spacer(),
              const Text('Verificação Humana',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              // Padding(
              //   padding: const EdgeInsets.only(right: 8.0),
              //   child: TextButton.icon(
              //     icon: const Icon(Icons.check),
              //     label: const Text('Concluído'),
              //     onPressed: onCompleted,
              //     style: TextButton.styleFrom(
              //       foregroundColor: Theme.of(context).colorScheme.primary,
              //     ),
              //   ),
              // ),
              IconButton(
                icon: const Icon(Icons.check),
                tooltip: 'Concluído',
                onPressed: onCompleted,
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
