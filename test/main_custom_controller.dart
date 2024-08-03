import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MainCustomController extends GetxController {
  var connectionStatus = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInternetConnection();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
          _updateConnectionStatus(result);
        } as void Function(List<ConnectivityResult> event)?);
  }

  void _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    _updateConnectionStatus(connectivityResult as ConnectivityResult);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      connectionStatus.value = false;
    } else {
      connectionStatus.value = true;
    }
  }
}

class ConnectionStatusText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainCustomController>();
    return Obx(() {
      return AnimatedSwitcher(
        duration: const Duration(seconds: 3),
        child: controller.connectionStatus.value
            ? const Text(
                'Saat ini Anda terhubung ke internet',
                key: ValueKey('connected'),
              )
            : const Text(
                'Periksa koneksi anda, kemungkinan pengambilan data serapan akan gagal dan hanya mengambil nilai serapan terakhir',
                key: ValueKey('disconnected'),
              ),
      );
    });
  }
}
