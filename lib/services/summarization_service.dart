import 'dart:convert';
import 'package:http/http.dart' as http;

class SummarizationService {
  SummarizationService._internal();
  static final SummarizationService instance = SummarizationService._internal();

  Future<String> summarizeArticle(String text) async {
    if (text.trim().isEmpty) {
      return "No content available to summarize.";
    }
    try {
      final response = await http.post(
        Uri.parse('https://api.thechenabtimes.com/summarise.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"article": text}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data["summary"] ?? "";
      } else {
        return "Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "Summarization failed: $e";
    }
  }
}
