import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import 'drawer_menu.dart';

class DashboardPage extends StatelessWidget {
  final DashboardController dashboardController =
      Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      drawer: DrawerMenu(),
      body: Obx(() {
        if (dashboardController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (dashboardController.hasError.value) {
          return Center(child: Text('Failed to load data'));
        } else {
          // Display dashboard data
          return ListView.builder(
            itemCount: dashboardController.dashboardData.length,
            itemBuilder: (context, index) {
              var data = dashboardController.dashboardData[index];
              return ListTile(
                title: Text(data['nama_skpd']),
                subtitle: Text('Realisasi: ${data['realisasi_rill']}'),
              );
            },
          );
        }
      }),
    );
  }
}
