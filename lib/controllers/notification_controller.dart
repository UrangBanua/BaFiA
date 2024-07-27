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

  get notificationCount => _notifications.length;

  // Load notifications from local storage
  Future<void> _loadNotifications() async {
    _notifications = await LocalStorageService.getMessages();
    // show log data message
    LoggerService.logger.i(_notifications);
    notifyListeners();
  }

  // Getter and Setter
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

  // Add a new notification
  Future<void> addNotification(Map<String, dynamic> notification) async {
    try {
      await LocalStorageService.saveMessageData(notification);
      _notifications.add(notification);
      LoggerService.logger.i('Notification added: $notification');
      notifyListeners();
    } catch (e) {
      LoggerService.logger.e('Failed to add notification: $e');
    }
  }

  // Update an existing notification
  Future<void> updateNotification(
      Map<String, dynamic> updatedNotification) async {
    try {
      final index = _notifications
          .indexWhere((n) => n['id'] == updatedNotification['id']);
      if (index != -1) {
        _notifications[index] = updatedNotification;
        await LocalStorageService.saveMessageData(updatedNotification);
        LoggerService.logger.i('Notification updated: $updatedNotification');
        notifyListeners();
      }
    } catch (e) {
      LoggerService.logger.e('Failed to update notification: $e');
    }
  }

  // Mark message as read
  void markAsRead(int id) {
    final notification = _notifications.firstWhere((n) => n['id'] == id);
    //notification['isRead'] = 'true';
    updateNotification(notification);
  }

  // Filter notifications by category
  List<Map<String, dynamic>> filterNotificationsByCategory(String category) {
    if (category == 'Semua') {
      return _notifications;
    }
    return _notifications
        .where((notification) => notification['category'] == category)
        .toList();
  }

  // Group notifications by date
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

  // Delete message by id
  Future<void> deleteMessage(int idMessage) async {
    try {
      await LocalStorageService.deleteMessageData(idMessage);
      _notifications
          .removeWhere((notification) => notification['id'] == idMessage);
      LoggerService.logger.i('Message with id $idMessage deleted.');
      notifyListeners();
    } catch (e) {
      LoggerService.logger.e('Failed to delete message: $e');
    }
  }
}
