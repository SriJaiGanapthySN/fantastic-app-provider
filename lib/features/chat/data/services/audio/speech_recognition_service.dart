import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ValueNotifier<String> recognizedText = ValueNotifier<String>('');
  final ValueNotifier<bool> isListening = ValueNotifier<bool>(false);

  Future<void> initialize() async {
    await requestPermissions();
    await _speech.initialize(
      onStatus: (status) => print("Speech status: $status"),
      onError: (error) => print("Speech error: $error"),
    );
  }

  Future<void> requestPermissions() async {
    var status = await Permission.microphone.request();
    if (status.isDenied) {
      print("Microphone permission denied");
    }
  }

  void startListening() async {
    if (!_speech.isAvailable) {
      await initialize();
    }

    if (_speech.isAvailable) {
      isListening.value = true;
      _speech.listen(
        onResult: (result) {
          recognizedText.value = result.recognizedWords;
        },
      );
    }
  }

  void stopListening() {
    isListening.value = false;
    _speech.stop();
    // Keep the recognized text for use by the caller
  }

  void clearText() {
    recognizedText.value = '';
  }

  void dispose() {
    // Clean up resources if needed
  }
}
