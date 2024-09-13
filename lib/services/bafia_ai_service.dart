import 'package:google_generative_ai/google_generative_ai.dart';
import 'logger_service.dart';

class BafiaAiService {
  final GenerativeModel _model;

  BafiaAiService(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            stopSequences: ["red"],
            maxOutputTokens: 500,
            temperature: 0.7, // Sesuaikan temperature sesuai kebutuhan
            topP: 0.1,
            topK: 16,
            responseMimeType: 'text/plain',
          ),
        ) {
    try {
      // Log success message
      LoggerService.logger.i('Model AI initialized successfully');
    } catch (e) {
      // Log error message
      LoggerService.logger.e('Error initializing model AI: $e');
    }
  }

  Future<String> getAiResponse(String message) async {
    try {
      // Set safety settings
      final safetySettings = [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high)
      ];

      // Use streaming for faster interaction
      final responseStream = _model.generateContentStream(
        [Content.text(message)],
        safetySettings: safetySettings,
      );

      // Collect the response from the stream
      StringBuffer responseBuffer = StringBuffer();
      await for (var response in responseStream) {
        try {
          if (response.candidates.isNotEmpty) {
            responseBuffer.write(response.candidates.first.text);
            LoggerService.logger.i(
                'Received part of response: ${response.candidates.first.text}');
          }
        } catch (streamError) {
          LoggerService.logger
              .e('Error processing stream response: $streamError');
          return 'Error processing stream response, periksa koneksi internet anda!';
        }
      }

      if (responseBuffer.isNotEmpty) {
        LoggerService.logger.i('Full response: ${responseBuffer.toString()}');
        return responseBuffer.toString();
      } else {
        throw Exception('Failed to get AI response');
      }
    } catch (e) {
      LoggerService.logger.e('Error getting AI response: $e');
      return 'Error getting AI response, periksa koneksi internet anda!';
    }
  }
}
