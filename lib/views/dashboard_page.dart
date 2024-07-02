import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:baFia/controllers/dashboard_controller.dart';

class DashboardPage extends StatelessWidget {
  final DashboardController dashboardController =
      Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Obx(() {
        if (dashboardController.items.isEmpty) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: dashboardController.items.length,
            itemBuilder: (context, index) {
              final item = dashboardController.items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text(item.description),
              );
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: dashboardController.synchronize,
        child: Icon(Icons.sync),
      ),
    );
  }
}
