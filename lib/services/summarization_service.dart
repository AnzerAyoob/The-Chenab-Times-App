import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/html_helper.dart';
import 'database_service.dart';

class SummarizationService {
  SummarizationService._internal();

  static final SummarizationService instance = SummarizationService._internal();

  static const _summaryEndpoint =
      'https://api.thechenabtimes.com/summarise.php';

  final DatabaseService _db = DatabaseService();

  Future<String> summarizeArticle(
    String text, {
    String? articleLink,
    String? excerpt,
  }) async {
    final rawText = text.trim();

    if (rawText.isEmpty &&
        (articleLink == null || articleLink.trim().isEmpty)) {
      return _finalFallback();
    }

    if (articleLink != null) {
      final cached = await _db.getCachedSummary(articleLink);

      if (cached != null &&
          cached.trim().isNotEmpty &&
          !cached.contains('Summary not available')) {
        return cached;
      }
    }

    String articleText = _prepareArticleText(rawText);

    debugPrint('Summarizer cleaned length: ${articleText.length}');

    String? summary;

    try {
      final response = await http
          .post(
            Uri.parse(_summaryEndpoint),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'article': articleText}),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('Summarizer API status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        summary = data['summary']?.toString().trim();

        if (summary != null && summary.length < 40) {
          summary = null;
        }
      }
    } catch (e) {
      debugPrint('Summarizer error: $e');
    }

    // fallback 1: WordPress excerpt
    summary ??= _excerptFallback(excerpt);

    // fallback 2: final message
    summary ??= _finalFallback();

    if (articleLink != null && summary.isNotEmpty) {
      await _db.cacheSummary(articleLink, summary);
    }

    return summary;
  }

  String _prepareArticleText(String text) {
    final cleanText = HtmlHelper.stripAndUnescape(
      text,
    ).replaceAll(RegExp(r'\\s+'), ' ').trim();

    if (cleanText.length < 1200) return cleanText;

    return cleanText.substring(0, 2500);
  }

  String? _excerptFallback(String? excerpt) {
    if (excerpt == null) return null;

    final cleanExcerpt = HtmlHelper.stripAndUnescape(
      excerpt,
    ).replaceAll(RegExp(r'\\s+'), ' ').trim();

    if (cleanExcerpt.length < 30) return null;

    return cleanExcerpt;
  }

  String _finalFallback() {
    return 'Summary not available at the moment. Please read full article.';
  }
}
