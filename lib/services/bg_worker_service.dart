import 'package:workmanager/workmanager.dart';
import 'logger_service.dart';
import 'local_storage_service.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    LoggerService.logger.i('Handling a background task: $task');
    if (inputData != null && inputData.isNotEmpty) {
      LoggerService.logger.i('Task also contained data: $inputData');
      await LocalStorageService.saveMessageData(inputData);
    }
    return Future.value(true);
  });
}
