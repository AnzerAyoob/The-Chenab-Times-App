import 'package:the_chenab_times/models/notification_model.dart';
import 'package:the_chenab_times/services/database_service.dart';

class NotificationService {
  final DatabaseService _dbService = DatabaseService();

  Future<List<NotificationModel>> getNotifications() async {
    return await _dbService.getNotifications();
  }

  Future<void> clearAllNotifications() async {
    await _dbService.deleteAllNotifications();
  }

  Future<void> deleteNotification(int id) async {
    await _dbService.deleteNotification(id);
  }
}
