import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/logger_service.dart';

class ConnectivityController extends GetxController {
  final _connectionType = MConnectivityResult.none.obs;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _streamSubscription;

  final connectivityState = false.obs; // Tambahkan variabel connectivityState
  final connectivityCaption = ''.obs; // Tambahkan variabel connectivityCaption

  MConnectivityResult get connectionType => _connectionType.value;

  set connectionType(value) {
    _connectionType.value = value;
  }

  @override
  void onInit() {
    super.onInit();
    getConnectivityType();
    _streamSubscription =
        _connectivity.onConnectivityChanged.listen(_updateState);
  }

  Future<void> getConnectivityType() async {
    late List<ConnectivityResult> connectivityResult;
    try {
      connectivityResult = await (_connectivity.checkConnectivity());
    } on PlatformException catch (e) {
      LoggerService.logger.i(e);
    }
    return _updateState(connectivityResult);
  }

  _updateState(List<ConnectivityResult> results) {
    final result = results.first;
    switch (result) {
      case ConnectivityResult.wifi:
        connectionType = MConnectivityResult.wifi;
        connectivityState.value = true; // Update connectivityState
        connectivityCaption.value =
            'Internet WiFi tersedia'; // Update connectivityCaption
        break;
      case ConnectivityResult.mobile:
        connectionType = MConnectivityResult.mobile;
        connectivityState.value = true; // Update connectivityState
        connectivityCaption.value =
            'Internet 4G tersedia'; // Update connectivityCaption
        break;
      case ConnectivityResult.none:
        connectionType = MConnectivityResult.none;
        connectivityState.value = false; // Update connectivityState
        connectivityCaption.value =
            'Internet tidak tersedia'; // Update connectivityCaption
        break;
      default:
        LoggerService.logger.i('Failed to get connection type');
        break;
    }
  }

  @override
  void onClose() {
    _streamSubscription.cancel();
  }
}

enum MConnectivityResult { none, wifi, mobile }
