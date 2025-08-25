import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Um utilitário para persistir cookies entre as sessões do aplicativo.
class CookieUtil {
  static Future<List<Cookie>> getCookies(WebUri url) async {
    return await CookieManager.instance().getCookies(url: url);
  }

  static Future<void> deleteAllCookies() async {
    await CookieManager.instance().deleteAllCookies();
  }

  static String stringifyCookies(List<Cookie> cookies) {
    return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }
}
