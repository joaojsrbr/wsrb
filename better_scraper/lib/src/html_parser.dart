import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

/// Um parser de HTML flexível, que funciona sem depender da interface Queryable.
class HtmlParser {
  /// Armazena o nó base (pode ser um Document ou um Element).
  final dom.Node _node;

  /// Construtor privado.
  HtmlParser._(this._node);

  dom.Document get document => _node as dom.Document;

  /// Cria um parser a partir de uma string HTML.
  factory HtmlParser.fromString(String html) => HtmlParser._(parser.parse(html));

  /// Cria um parser a partir de um Elemento já existente.
  factory HtmlParser.fromElement(dom.Element element) => HtmlParser._(element);

  // --- MÉTODOS DE BUSCA BASE (COM A NOVA LÓGICA) ---

  /// Seleciona o primeiro elemento que corresponde ao [selector].
  dom.Element? selectOne(String selector) {
    final n = _node; // Variável local para promover o tipo
    // Verifica se o nó é um Document ou Element e chama o método apropriado.
    if (n is dom.Document) return n.querySelector(selector);
    if (n is dom.Element) return n.querySelector(selector);
    return null; // Retorna nulo se o nó não for pesquisável
  }

  /// Seleciona todos os elementos que correspondem ao [selector].
  Iterable<dom.Element> selectAll(String selector) {
    final n = _node;
    if (n is dom.Document) return n.querySelectorAll(selector);
    if (n is dom.Element) return n.querySelectorAll(selector);
    return []; // Retorna lista vazia se o nó não for pesquisável
  }

  // --- O RESTANTE DA CLASSE (NENHUMA MUDANÇA NECESSÁRIA) ---
  // Todos os métodos abaixo funcionam perfeitamente, pois dependem
  // de `selectOne` e `selectAll`, que já contêm a nova lógica.

  // --- Propriedades Diretas do Elemento Atual ---
  String? get text {
    final q = _node;
    return q is dom.Element ? q.text.trim() : null;
  }

  String? get outerHtml {
    final q = _node;
    return q is dom.Element ? q.outerHtml : null;
  }

  String? operator [](String attributeName) {
    final q = _node;
    return q is dom.Element ? q.attributes[attributeName] : null;
  }

  // --- Métodos de Sub-consulta (Query) ---
  HtmlParser? query(String selector) {
    final element = selectOne(selector);
    return element != null ? HtmlParser.fromElement(element) : null;
  }

  List<HtmlParser> queryAll(String selector) {
    return selectAll(selector).map((element) => HtmlParser.fromElement(element)).toList();
  }

  String? queryText(String selector) => query(selector)?.text;

  String? queryAttr(String selector, String attributeName) =>
      query(selector)?[attributeName];

  // --- Métodos de Extração de Listas ---
  List<String> textList(String selector) {
    return queryAll(selector).map((p) => p.text).whereType<String>().toList();
  }

  String getImage(String? selector) {
    HtmlParser? $;

    if (selector != null) $ = query(selector);
    if ($ == null || $._node is! dom.Element) return '';
    final attributes = $._node.attributes;

    // String src = attributes['data-src'] ?? attributes['src'] ?? '';

    // if (bySrcSet == true) {
    String src = attributes['src'] ??
        attributes['data-src'] ??
        attributes['data-srcset'] ??
        attributes['srcset'] ??
        '';

    //   src = _bySrcSet(src, last);
    // }

    return src.trim();
  }

  List<String> attrList(String selector, String attributeName) {
    return queryAll(selector).map((p) => p[attributeName]).whereType<String>().toList();
  }
}
