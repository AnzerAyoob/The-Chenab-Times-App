import 'package:flutter/material.dart';
import 'package:the_chenab_times/models/notification_model.dart';
import 'package:the_chenab_times/services/database_service.dart';

class NotificationProvider extends ChangeNotifier {
  static final NotificationProvider _instance = NotificationProvider._internal();
  factory NotificationProvider() => _instance;
  NotificationProvider._internal();

  final DatabaseService _dbService = DatabaseService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _dbService.getNotifications();
    } catch (e) {
      debugPrint("Failed to load notifications: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNotification(NotificationModel notification) async {
    try {
      await _dbService.saveNotification(notification);

      // Avoid duplicates by notification_id (OneSignal's unique id)
      final alreadyExists = _notifications.any((n) => n.notificationId == notification.notificationId);
      if (!alreadyExists) {
        _notifications.insert(0, notification);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error saving notification: $e");
    }
  }

  Future<void> clearAllNotifications() async {
    await _dbService.deleteAllNotifications();
    _notifications.clear();
    notifyListeners();
  }
}