/// Classe base selada para todas as ações que podem ser executadas na página.
/// Usar "sealed" garante que o switch em suas implementações seja exaustivo.
sealed class DomAction {}

/// Ação para executar um script JavaScript arbitrário no contexto da página.
/// Útil para clicar em botões, preencher formulários, rolar a página, etc.
class ExecuteScriptAction extends DomAction {
  final String script;
  final String? resultKey;

  /// [script] é o código JavaScript a ser executado.
  /// Exemplo: "document.querySelector('#meuBotao').click();"
  ExecuteScriptAction(this.script, {this.resultKey});
}

/// Ação para pausar a execução por um período fixo.
/// Útil para aguardar animações ou carregamentos de rede após uma ação.
class WaitAction extends DomAction {
  final Duration duration;

  WaitAction(this.duration);
}

/// Define o tipo de dado a ser extraído de um elemento.
enum ScrapingType {
  /// Extrai o texto visível do elemento (innerText).
  text,

  /// Extrai o conteúdo HTML interno do elemento (innerHTML).
  html,

  /// Extrai o valor de um atributo específico.
  attribute,
}

/// Ação para extrair dados de um elemento na página e armazená-los em um mapa de resultados.
/// Esta é a ação que permite o scraping "durante" a execução dos scripts.
class ScrapeDataAction extends DomAction {
  /// A chave que será usada para armazenar o dado extraído no mapa de resultados.
  final String resultKey;

  /// O seletor CSS para encontrar o elemento na página.
  final String selector;

  /// O tipo de extração a ser realizada (texto, html ou atributo).
  final ScrapingType type;

  /// O nome do atributo a ser extraído, obrigatório se o [type] for [ScrapingType.attribute].
  final String? attributeName;

  ScrapeDataAction({
    required this.resultKey,
    required this.selector,
    this.type = ScrapingType.text,
    this.attributeName,
  }) {
    if (type == ScrapingType.attribute && attributeName == null) {
      throw ArgumentError(
          'attributeName é obrigatório quando o tipo de scraping é "attribute".');
    }
  }
}

/// Ação especial para extrair o HTML completo da página no final da execução.
class ScrapeFinalHtmlAction extends DomAction {
  /// A chave que será usada para armazenar o HTML final no mapa de resultados.
  final String resultKey;

  ScrapeFinalHtmlAction(this.resultKey);
}
