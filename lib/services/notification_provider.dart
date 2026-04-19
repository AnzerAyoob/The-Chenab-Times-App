import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_chenab_times/models/article_model.dart';
import 'package:the_chenab_times/models/notification_model.dart';
import 'package:the_chenab_times/services/database_service.dart';
import 'package:the_chenab_times/services/rss_service.dart';
import 'package:the_chenab_times/utils/html_helper.dart';

class NotificationProvider extends ChangeNotifier {
  static final NotificationProvider _instance =
      NotificationProvider._internal();
  factory NotificationProvider() => _instance;
  NotificationProvider._internal();

  static const _knownPostIdsKey = 'notification_known_post_ids';
  static const _deletedNotificationsKey = 'deleted_notifications';

  final DatabaseService _dbService = DatabaseService();
  final RssService _rssService = RssService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final loaded = await _dbService.getNotifications();
      final deletedSignatures = await _deletedNotificationSignatures();
      final filtered = loaded.where((item) {
        return !deletedSignatures.contains(_notificationSignature(item));
      }).toList();

      for (final item in loaded) {
        if (item.id != null &&
            deletedSignatures.contains(_notificationSignature(item))) {
          await _dbService.deleteNotification(item.id!);
        }
      }

      _notifications = await _dedupeNotifications(filtered);
    } catch (e) {
      debugPrint("Failed to load notifications: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNotification(NotificationModel notification) async {
    try {
      final deletedSignatures = await _deletedNotificationSignatures();
      if (deletedSignatures.contains(_notificationSignature(notification))) {
        return;
      }

      final duplicate = _notifications.any(
        (item) =>
            _notificationSignature(item) ==
            _notificationSignature(notification),
      );
      if (duplicate) {
        return;
      }

      await _dbService.saveNotification(notification);
      _notifications.insert(0, notification);
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving notification: $e");
    }
  }

  Future<int> syncLatestPosts({
    String? languageCode,
    bool seedIfEmpty = true,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final knownIds =
          prefs.getStringList(_knownPostIdsKey)?.toSet() ?? <String>{};
      final deletedSignatures = await _deletedNotificationSignatures();
      final latestPosts = await _rssService.fetchPostsPage(
        perPage: 20,
        languageCode: languageCode,
      );

      final validPosts = latestPosts.where((post) => post.id != null).toList();
      if (validPosts.isEmpty) return 0;

      if (knownIds.isEmpty && _notifications.isEmpty && seedIfEmpty) {
        await prefs.setStringList(
          _knownPostIdsKey,
          validPosts.map((post) => '${post.id}').toList(),
        );
        return 0;
      }

      final unseenPosts = validPosts
          .where((post) {
            final postId = '${post.id}';
            return !knownIds.contains(postId) &&
                !deletedSignatures.contains('post:$postId');
          })
          .toList()
          .reversed
          .toList();

      for (final post in unseenPosts) {
        await addNotification(_notificationFromArticle(post));
      }

      final mergedIds = <String>{
        ...validPosts.map((post) => '${post.id}'),
        ...knownIds,
      }.toList();
      await prefs.setStringList(_knownPostIdsKey, mergedIds.take(100).toList());

      return unseenPosts.length;
    } catch (e) {
      debugPrint('Failed to sync latest posts: $e');
      return 0;
    }
  }

  Future<void> clearAllNotifications() async {
    final deletedSignatures = await _deletedNotificationSignatures();
    deletedSignatures.addAll(_notifications.map(_notificationSignature));
    await _saveDeletedNotificationSignatures(deletedSignatures);
    await _dbService.deleteAllNotifications();
    _notifications.clear();
    notifyListeners();
  }

  Future<void> deleteNotification(NotificationModel notification) async {
    final deletedSignatures = await _deletedNotificationSignatures();
    deletedSignatures.add(_notificationSignature(notification));
    await _saveDeletedNotificationSignatures(deletedSignatures);

    if (notification.id != null) {
      await _dbService.deleteNotification(notification.id!);
    }

    _notifications.removeWhere(
      (item) =>
          _notificationSignature(item) == _notificationSignature(notification),
    );
    notifyListeners();
  }

  NotificationModel _notificationFromArticle(Article article) {
    return NotificationModel(
      notificationId: 'post-${article.id}',
      title: HtmlHelper.stripAndUnescape(article.title).trim().isEmpty
          ? 'The Chenab Times'
          : HtmlHelper.stripAndUnescape(article.title),
      body: _notificationBody(article),
      imageUrl: article.thumbnailUrl ?? article.imageUrl,
      receivedAt: article.date ?? DateTime.now(),
      article: article,
      postId: article.id,
    );
  }

  String _notificationBody(Article article) {
    final cleanExcerpt = HtmlHelper.stripAndUnescape(
      article.excerpt,
    ).replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleanExcerpt.isNotEmpty) {
      return cleanExcerpt;
    }
    final cleanContent = HtmlHelper.stripAndUnescape(
      article.content,
    ).replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleanContent.isEmpty) {
      return 'Tap to read the latest update.';
    }
    if (cleanContent.length <= 140) {
      return cleanContent;
    }
    return '${cleanContent.substring(0, 137)}...';
  }

  Future<List<NotificationModel>> _dedupeNotifications(
    List<NotificationModel> items,
  ) async {
    final seen = <String>{};
    final unique = <NotificationModel>[];

    for (final item in items) {
      final signature = _notificationSignature(item);
      if (seen.add(signature)) {
        unique.add(item);
      } else if (item.id != null) {
        await _dbService.deleteNotification(item.id!);
      }
    }

    return unique;
  }

  String _notificationSignature(NotificationModel item) {
    final postId = item.postId;
    if (postId != null) {
      return 'post:$postId';
    }

    final title = item.title.trim().toLowerCase();
    final body = item.body.trim().toLowerCase();
    return 'text:$title|$body';
  }

  Future<Set<String>> _deletedNotificationSignatures() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_deletedNotificationsKey)?.toSet() ?? <String>{};
  }

  Future<void> _saveDeletedNotificationSignatures(
    Set<String> signatures,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _deletedNotificationsKey,
      signatures.take(200).toList(),
    );
  }
}
