# better_scraper (genérico)

Framework genérico para scraping com WebView headless no Flutter, com parsing HTML e fluxo **humano** para desafios (captcha/turnstile/hcaptcha/recaptcha).

> ⚠️ Este pacote **não automatiza** nem instrui a burlar captchas. Ele apenas fornece um ponto de extensão **legítimo** (Human-in-the-loop) para que o usuário finalize a etapa manualmente quando necessário.

## Features
- Headless WebView (flutter_inappwebview).
- `fetchHtml` e `fetchDocument` (retorna `HtmlParser`).
- `HumanCaptchaHandler` que abre uma tela com WebView visível quando houver desafio.
- Utilitários de parsing (`HtmlParser`).

## Uso básico

```dart
final session = ScrapingSession(userAgent: '...');
await session.init();

final parser = await session.fetchDocument(
  Uri.parse('https://example.org'),
  captchaUiContext: context,
  captchaHandler: HumanCaptchaHandler(),
);

print(parser.text('title'));
```


## Script
```
  final session = ScrapingSession();
  await session.init();

  // 1. Defina a "receita" de ações
  final acoes = <DomAction>[
    // Clica no botão para carregar mais conteúdo
    ExecuteScriptAction("document.querySelector('#load-more-btn').click();"),
    
    // Espera 2 segundos para a animação e a chamada de rede terminarem
    WaitAction(const Duration(seconds: 2)),
    
    // Extrai o texto do novo título que apareceu na tela
    ScrapeDataAction(
      resultKey: 'titulo_novo_conteudo',
      selector: '.novo-item h2',
      type: ScrapingType.text,
    ),

    // Extrai o atributo 'src' da nova imagem
    ScrapeDataAction(
      resultKey: 'url_imagem',
      selector: '.novo-item img',
      type: ScrapingType.attribute,
      attributeName: 'src',
    ),

    // No final de tudo, pega o HTML completo da página
    ScrapeFinalHtmlAction('html_final'),
  ];

  // 2. Execute a sessão com as ações
  final resultados = await session.executeActionsAndScrape(
    url: Uri.parse('https://site-com-conteudo-dinamico.com'),
    actions: acoes,
  );

  // 3. Use os resultados
  print('Título extraído: ${resultados['titulo_novo_conteudo']}');
  print('URL da Imagem: ${resultados['url_imagem']}');
  print('Tamanho do HTML final: ${resultados['html_final']?.length ?? 0} caracteres');

  await session.dispose();
```

## Ética e termos
Respeite sempre os termos de uso do site e a legislação local.
