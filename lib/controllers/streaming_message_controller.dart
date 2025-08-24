import 'dart:async';

class StreamingMessageController {
  final StreamController<String> _textChunkController = StreamController<String>();
  final StreamController<bool> _completionController = StreamController<bool>();
  
  String _fullText = '';
  bool _isComplete = false;

  // Getters
  Stream<String> get textChunkStream => _textChunkController.stream;
  Stream<bool> get completionStream => _completionController.stream;
  String get fullText => _fullText;
  bool get isComplete => _isComplete;

  // Methods to control streaming
  void addChunk(String chunk) {
    if (!_textChunkController.isClosed && !_isComplete) {
      _fullText += chunk;
      _textChunkController.add(chunk);
    }
  }

  void completeStreaming() {
    if (!_completionController.isClosed && !_isComplete) {
      _isComplete = true;
      _completionController.add(true);
    }
  }

  void dispose() {
    _textChunkController.close();
    _completionController.close();
  }
}
