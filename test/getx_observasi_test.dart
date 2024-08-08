import 'dart:io';
import 'package:bafia/services/logger_service.dart';
import 'package:flutter/foundation.dart';

void main() {
  final directory = Directory('lib');
  final files = directory
      .listSync(recursive: true)
      .where((file) => file.path.endsWith('.dart'));

  for (var file in files) {
    final content = File(file.path).readAsStringSync();
    if (content.contains("package:get/get.dart")) {
      LoggerService.logger.i('Checking file: ${file.path}');
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
    LoggerService.logger.i('No GetX controllers found.');
  } else {
    LoggerService.logger.i('Found GetX controllers:');
    for (var match in controllerDefinitions) {
      LoggerService.logger.i(content.substring(match.start, match.end));
    }
  }

  // Check for controller initializations
  final controllerInitializations = RegExp(
          r'Get\.put<\w+Controller>\(\)|Get\.lazyPut<\w+Controller>\(\)|Get\.find<\w+Controller>\(\)')
      .allMatches(content);
  if (controllerInitializations.isEmpty) {
    LoggerService.logger.i('No GetX controller initializations found.');
  } else {
    LoggerService.logger.i('Found GetX controller initializations:');
    for (var match in controllerInitializations) {
      LoggerService.logger.i(content.substring(match.start, match.end));
    }
  }

  // Check for state observations
  final stateObservations =
      RegExp(r'Obx\(\)|GetBuilder<\w+Controller>\(\)').allMatches(content);
  if (stateObservations.isEmpty) {
    LoggerService.logger.i('No GetX state observations found.');
  } else {
    LoggerService.logger.i('Found GetX state observations:');
    for (var match in stateObservations) {
      LoggerService.logger.i(content.substring(match.start, match.end));
    }
  }
}
