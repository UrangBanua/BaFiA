import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import '../controllers/notification_controller.dart';

class NotificationPage extends StatelessWidget {
  final NotificationController _controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Obx(() {
              final filteredNotifications =
                  _controller.filterNotificationsByCategory(
                      _controller.selectedCategory.value);
              final groupedNotifications =
                  _controller.groupNotificationsByDate(filteredNotifications);
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
                        final notification = entry.value;
                        return Dismissible(
                          key: Key(notification['id'].toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _controller.deleteMessage(notification['id']);
                          },
                          background: Container(
                            color: Colors.blue[300],
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Card(
                            color: notification['isRead'] == 'false'
                                ? Theme.of(context).colorScheme.surface
                                : Theme.of(context).colorScheme.surface,
                            child: ListTile(
                              leading: Icon(
                                notification['isRead'] == 'false'
                                    ? Icons.mark_email_unread
                                    : Icons.mark_email_read,
                                color: notification['isRead'] == 'false'
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              title: Text(notification['title']),
                              subtitle: Text(notification['content']),
                              onTap: () {
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
                                                FlutterWebBrowser.openWebPage(
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
                                            _controller.markAsRead(notification[
                                                'id']); // Tandai pesan sebagai sudah dibaca
                                            Navigator.of(context)
                                                .pop(); // Tutup dialog
                                          },
                                          child: const Text('Close'),
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
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    return Obx(() {
      return ElevatedButton(
        onPressed: () => _controller.setSelectedCategory(category),
        child: Text(category),
        style: ElevatedButton.styleFrom(
          foregroundColor: _controller.selectedCategory.value == category
              ? Colors.white
              : Colors.black,
          backgroundColor: _controller.selectedCategory.value == category
              ? Colors.blue
              : Colors.blue,
        ),
      );
    });
  }
}
