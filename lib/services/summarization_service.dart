import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SummarizationService {
  SummarizationService._internal();
  static final SummarizationService instance = SummarizationService._internal();

  final String? _apiKey = dotenv.env['OPENROUTER_API_KEY'];

  /// Summarize using OpenRouter
  Future<String> summarizeArticle(String text) async {
    if (text.trim().isEmpty) {
      return "No content available to summarize.";
    }

    if (_apiKey == null || _apiKey.isEmpty) {
      return "Error: OpenRouter API key is missing or invalid.";
    }

    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
          "HTTP-Referer": "https://thechenabtimes.com",
          "X-Title": "The Chenab Times",
        },
        body: jsonEncode({
          "model": "meta-llama/llama-3-8b-instruct",
          "messages": [
            {
              "role": "system",
              "content": "Summarize the following news article in exactly 150 words. The output must be clean, fully human-readable, and contain only the summary itself, without any introductory phrases like 'Here is the summary:'."
            },
            {"role": "user", "content": text}
          ],
          "max_tokens": 250,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data["choices"][0]["message"]["content"] ?? "";
      } else {
        return "Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "Summarization failed: $e";
    }
  }
}
