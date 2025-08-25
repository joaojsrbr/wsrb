class ScrapedPage {
  final Uri url;
  final String html;
  final Uri? finalUrl;

  ScrapedPage({required this.url, required this.html, this.finalUrl});

  @override
  String toString() => 'ScrapedPage(url: $url, finalUrl: $finalUrl, htmlLength: ${html.length})';
}

class ScrapedItem {
  final Map<String, dynamic> data;
  ScrapedItem(this.data);

  T? get<T>(String key) => data[key] as T?;
  @override
  String toString() => 'ScrapedItem(${data.keys.join(', ')})';
}
