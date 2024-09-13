import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/local_storage_service.dart';
import '../services/logger_service.dart';

class NotificationController extends GetxController {
  final RxList<Map<String, dynamic>> notifications =
      <Map<String, dynamic>>[].obs;
  final Rx<String> selectedCategory = 'Semua'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
    //loadReadNotifications();
    //getUnreadNotificationCount();
    //logNotificationCount();
  }

  // Getter for unread notification count
  int get notificationCount =>
      notifications.where((n) => n['isRead'] == 'false').length;

  // Logger info notificationCount
  void logNotificationCount() {
    LoggerService.logger.i('Notification count: $notificationCount');
  }

  // Load notifications from local storage
  Future<void> _loadNotifications() async {
    var loadedNotifications = List<Map<String, dynamic>>.from(
        await LocalStorageService.getMessages());
    notifications.assignAll(loadedNotifications);
    LoggerService.logger.i(notifications);
    update();
  }

  // Set selected category
  void setSelectedCategory(String category) {
    selectedCategory.value = category;
  }

  // Get unread notification count
  int getUnreadNotificationCount() {
    return notifications.where((n) => n['isRead'] == 'false').length;
  }

  // Add a new notification
  Future<void> addNotification(Map<String, dynamic> notification) async {
    try {
      await LocalStorageService.saveMessageData(notification);
      notifications.add(notification);
      LoggerService.logger.i('Notification added: $notification');
    } catch (e) {
      LoggerService.logger.e('Failed to add notification: $e');
    }
  }

  // Update an existing notification
  Future<void> updateNotification(
      Map<String, dynamic> updatedNotification) async {
    try {
      final index =
          notifications.indexWhere((n) => n['id'] == updatedNotification['id']);
      if (index != -1) {
        final notificationCopy =
            Map<String, dynamic>.from(notifications[index]);
        notificationCopy.addAll(updatedNotification);
        notifications[index] = notificationCopy;
        await LocalStorageService.saveMessageData(notificationCopy);
        LoggerService.logger.i('Notification updated: $updatedNotification');
      }
    } catch (e) {
      LoggerService.logger.e('Failed to update notification: $e');
    }
  }

  // Mark message as read
  void markAsRead(int id) {
    final readNotification = notifications.firstWhere((n) => n['id'] == id);
    //loggeer info readNotification
    LoggerService.logger.i('Read notification: $readNotification');
    LocalStorageService.markAsRead(id);
    // Implement mark as read functionality
  }

  // Filter notifications by category
  List<Map<String, dynamic>> filterNotificationsByCategory(String category) {
    if (category == 'Semua') {
      return notifications;
    }
    return notifications
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
      notifications
          .removeWhere((notification) => notification['id'] == idMessage);
    } catch (e) {
      LoggerService.logger.e('Failed to delete message: $e');
    }
  }
}
