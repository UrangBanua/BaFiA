import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/local_storage_service.dart';
import '../services/logger_service.dart';

class NotificationController extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  String _selectedCategory = 'Semua';

  NotificationController() {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    _notifications = await LocalStorageService.getMessages();
    // show log data message
    LoggerService.logger.i(_notifications);
    notifyListeners();
  }

  List<Map<String, dynamic>> get notifications => _notifications;

  set notifications(List<Map<String, dynamic>> notifications) {
    _notifications = notifications;
    notifyListeners();
  }

  String get selectedCategory => _selectedCategory;

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> markAsRead(int idMessage) async {
    try {
      // log idMessage
      LoggerService.logger.i(idMessage.toString());

      // Update message isRead to local storage
      await markAsRead(idMessage);
      //notifyListeners();
    } catch (e) {
      LoggerService.logger.e('Failed to update markAsRead message: $e');
    }
  }

  List<Map<String, dynamic>> filterNotificationsByCategory(String category) {
    if (category == 'Semua') {
      return _notifications;
    }
    return _notifications
        .where((notification) => notification['category'] == category)
        .toList();
  }

  Map<String, List<Map<String, dynamic>>> groupNotificationsByDate(
      List<Map<String, dynamic>> notifications) {
    final Map<String, List<Map<String, dynamic>>> groupedNotifications = {};
    for (var notification in notifications) {
      String formattedDate =
          DateFormat('yyyy-MM-dd').format(DateTime.parse(notification['date']));
      if (groupedNotifications.containsKey(formattedDate)) {
        groupedNotifications[formattedDate]!.add(notification);
      } else {
        groupedNotifications[formattedDate] = [notification];
      }
    }
    return groupedNotifications;
  }
}
