import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class RssService {
  final String postsBaseUrl = 'https://thechenabtimes.com/wp-json/wp/v2/posts';
  final String pagesBaseUrl = 'https://thechenabtimes.com/wp-json/wp/v2/pages';

  /// [NEW] Fetch a single article by its ID.
  /// This is used when a notification comes with a specific Post ID.
  Future<Article?> fetchArticleById(int id, {String? languageCode}) async {
    var url = '$postsBaseUrl/$id?_embed=true';
    if (languageCode != null && languageCode != 'en') {
      url += '&lang=$languageCode';
    }
    final uri = Uri.parse(url);
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(resp.body);
        return Article.fromJson(data);
      } else {
        log('Failed to fetch article $id: Status ${resp.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error fetching article by ID: $e');
      return null;
    }
  }

  /// Fetch list of posts for the home screen
  Future<List<Article>> fetchPostsPage({int page = 1, int perPage = 15, String? languageCode}) async {
    var url = '$postsBaseUrl?page=$page&per_page=$perPage&_embed=true';
    if (languageCode != null && languageCode != 'en') {
      url += '&lang=$languageCode';
    }
    final uri = Uri.parse(url);
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) {
        final List data = json.decode(resp.body);
        return data.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
      } else if (resp.statusCode == 400) {
        return [];
      } else {
        throw Exception('Failed to load posts (status ${resp.statusCode})');
      }
    } catch (e) {
      log("Error fetching posts: $e");
      return [];
    }
  }

  /// Fetch posts for a specific category
  Future<List<Article>> fetchCategoryPosts({required int categoryId, int page = 1, int perPage = 15, String? languageCode}) async {
    var url = '$postsBaseUrl?categories=$categoryId&page=$page&per_page=$perPage&_embed=true';
    if (languageCode != null && languageCode != 'en') {
      url += '&lang=$languageCode';
    }
    final uri = Uri.parse(url);
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) {
        final List data = json.decode(resp.body);
        return data.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
      } else if (resp.statusCode == 400) {
        return [];
      } else {
        throw Exception('Failed to load posts (status ${resp.statusCode})');
      }
    } catch (e) {
      log("Error fetching category posts: $e");
      return [];
    }
  }

  /// Fetch a specific page (like About Us)
  Future<Article?> fetchPage(String searchTerm) async {
    final uri = Uri.parse('$pagesBaseUrl?search=${Uri.encodeQueryComponent(searchTerm)}&_embed=true');
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) {
        final List data = json.decode(resp.body);
        if (data.isNotEmpty) {
          return Article.fromJson(data.first as Map<String, dynamic>);
        }
      }
    } catch (e) {
      log("Error fetching page: $e");
    }
    return null;
  }

  /// Search for posts
  Future<List<Article>> searchPosts(String query, {int page = 1, int perPage = 30, String? languageCode}) async {
    var url = '$postsBaseUrl?search=${Uri.encodeQueryComponent(query)}&page=$page&per_page=$perPage&_embed=true';
    if (languageCode != null && languageCode != 'en') {
      url += '&lang=$languageCode';
    }
    final uri = Uri.parse(url);
    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final List data = json.decode(resp.body);
        return data.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      log("Error searching posts: $e");
    }
    return [];
  }
}
