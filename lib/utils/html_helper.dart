import 'package:html/parser.dart' show parse;

class HtmlHelper {
  static String stripAndUnescape(String? html) {
    if (html == null || html.isEmpty) return '';
    final document = parse(html);
    return document.documentElement?.text ?? '';
  }
}
