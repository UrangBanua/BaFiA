import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:baFia/controllers/item_controller.dart';

class ItemPage extends StatelessWidget {
  final ItemController itemController = Get.put(ItemController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items'),
      ),
      body: Obx(() {
        if (itemController.items.isEmpty) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: itemController.items.length,
            itemBuilder: (context, index) {
              final item = itemController.items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text(item.description),
                onTap: () {
                  // Handle item tap
                },
              );
            },
          );
        }
      }),
    );
  }
}
