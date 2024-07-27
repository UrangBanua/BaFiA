// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/notification_controller.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

// notification page state
class _NotificationPageState extends State<NotificationPage> {
  late NotificationController _controller;

  @override
  void initState() {
    super.initState();
    // initialize notification controller
    _controller = NotificationController();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryButton('Semua'),
                    _buildCategoryButton('Penatausahaan'),
                    _buildCategoryButton('Akuntansi'),
                    _buildCategoryButton('Anggaran'),
                    _buildCategoryButton('Aset'),
                    _buildCategoryButton('Lainnya'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Consumer<NotificationController>(
                builder: (context, controller, child) {
                  final filteredNotifications =
                      controller.filterNotificationsByCategory(
                          controller.selectedCategory);
                  final groupedNotifications = controller
                      .groupNotificationsByDate(filteredNotifications);
                  final sortedDates = groupedNotifications.keys.toList()
                    ..sort((a, b) => b.compareTo(a));
                  return ListView.builder(
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final date = sortedDates[index];
                      final notificationsForDate = groupedNotifications[date]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              DateFormat('  dd MMMM yyyy')
                                  .format(DateTime.parse(date)),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          ...notificationsForDate.asMap().entries.map((entry) {
                            final notificationIndex = entry.key;
                            final notification = entry.value;
                            final isRead = notification['isRead'] as String;
                            return Card(
                              color: isRead == 'false'
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(context).colorScheme.background,
                              child: ListTile(
                                title: Text(
                                    '${notificationIndex + 1}. ${notification['title']}'),
                                subtitle: Text(notification['content']),
                                trailing: Icon(
                                  isRead == 'false'
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
                                  color: isRead == 'false'
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                onTap: () {
                                  if (notificationIndex != -1) {
                                    controller.markAsRead(notification['id']);
                                  } else {
                                    // Handle the error case if needed
                                    print(
                                        'Invalid notification index: $notificationIndex');
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    return Consumer<NotificationController>(
      builder: (context, controller, child) {
        final isSelected = controller.selectedCategory == category;
        final theme = Theme.of(context);
        final textColor = isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: textColor,
              backgroundColor: Colors.blue,
            ),
            onPressed: () {
              controller.setSelectedCategory(category);
            },
            child: Text(category),
          ),
        );
      },
    );
  }
}
