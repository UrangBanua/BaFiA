// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
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
          title: const Text('Kotak Pesan'),
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
                            //final notificationIndex = entry.key;
                            final notification = entry.value;
                            //final isRead = notification['isRead'] as String;
                            return Dismissible(
                              key: Key(notification['id'].toString()),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                // Panggil fungsi deleteMessage dari controller
                                controller.deleteMessage(notification['id']);
                              },
                              background: Container(
                                color: Colors.blue[300],
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              child: Card(
                                color: notification['isRead'] == 'false'
                                    ? Theme.of(context).colorScheme.surface
                                    : Theme.of(context).colorScheme.background,
                                child: ListTile(
                                  leading: Icon(
                                    notification['isRead'] == 'false'
                                        ? Icons.mark_email_unread
                                        : Icons.mark_email_read,
                                    color: notification['isRead'] == 'false'
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                  title: Text(
                                      //'${notificationIndex + 1}. ${notification['title']}'),
                                      '${notification['title']}'),
                                  subtitle: Text(notification['content']),
                                  onTap: () {
                                    // Buka Popup untuk membaca isi pesan
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        final link = notification['link'];
                                        final isImage = link.endsWith('.gif') ||
                                            link.endsWith('.jpg') ||
                                            link.endsWith('.png');
                                        return AlertDialog(
                                          title: Text(notification['title']),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(notification['content']),
                                              if (isImage) ...[
                                                const SizedBox(height: 10),
                                                Image.network(link),
                                              ] else if (link.isNotEmpty) ...[
                                                const SizedBox(height: 10),
                                                Linkify(
                                                  text: link,
                                                  options: const LinkifyOptions(
                                                      humanize: false),
                                                  onOpen: (link) async {
                                                    FlutterWebBrowser
                                                        .openWebPage(
                                                            url: link.url);
                                                  },
                                                  style: const TextStyle(
                                                      color: Colors.blue),
                                                ),
                                              ],
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                // Tandai pesan sebagai sudah dibaca
                                                controller.markAsRead(
                                                    notification['id']);
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Tutup'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
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
