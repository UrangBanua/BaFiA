import 'dart:io';

void main() {
  final directory = Directory('lib');
  final files = directory
      .listSync(recursive: true)
      .where((file) => file.path.endsWith('.dart'));

  for (var file in files) {
    final content = File(file.path).readAsStringSync();
    if (content.contains("package:get/get.dart")) {
      print('Checking file: ${file.path}');
      checkGetXUsage(content);
    }
  }
}

void checkGetXUsage(String content) {
  // Check for controller definitions
  final controllerDefinitions =
      RegExp(r'class\s+\w+Controller\s+extends\s+GetxController')
          .allMatches(content);
  if (controllerDefinitions.isEmpty) {
    print('No GetX controllers found.');
  } else {
    print('Found GetX controllers:');
    for (var match in controllerDefinitions) {
      print(content.substring(match.start, match.end));
    }
  }

  // Check for controller initializations
  final controllerInitializations = RegExp(
          r'Get\.put<\w+Controller>\(\)|Get\.lazyPut<\w+Controller>\(\)|Get\.find<\w+Controller>\(\)')
      .allMatches(content);
  if (controllerInitializations.isEmpty) {
    print('No GetX controller initializations found.');
  } else {
    print('Found GetX controller initializations:');
    for (var match in controllerInitializations) {
      print(content.substring(match.start, match.end));
    }
  }

  // Check for state observations
  final stateObservations =
      RegExp(r'Obx\(\)|GetBuilder<\w+Controller>\(\)').allMatches(content);
  if (stateObservations.isEmpty) {
    print('No GetX state observations found.');
  } else {
    print('Found GetX state observations:');
    for (var match in stateObservations) {
      print(content.substring(match.start, match.end));
    }
  }
}
