import 'package:fantastic_app_riverpod/features/chat/data/services/audio/speech_recognition_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpeechRecognitionNotifier
    extends StateNotifier<SpeechRecognitionService> {
  SpeechRecognitionNotifier() : super(SpeechRecognitionService()) {
    state.initialize();
  }

  void startListening() {
    state.startListening();
  }

  void stopListening() {
    state.stopListening();
  }

  void clearText() {
    state.clearText();
  }

  String get recognizedText => state.recognizedText.value;

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }
}

final speechRecognitionProvider =
    StateNotifierProvider<SpeechRecognitionNotifier, SpeechRecognitionService>(
        (ref) {
  return SpeechRecognitionNotifier();
});
