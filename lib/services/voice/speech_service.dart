import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  void Function(String status)? _statusListener;

  Future<bool> init({
    void Function(String status)? onStatus,
    void Function(Object error)? onError,
  }) async {
    _statusListener = onStatus;

    _isInitialized = await _speech.initialize(
      onStatus: (status) => _statusListener?.call(status),
      onError: (error) => onError?.call(error),
    );

    return _isInitialized;
  }

  void startListening(Function(String text) onResult) {
    if (!_isInitialized) return;

    _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      listenMode: ListenMode.dictation,
      partialResults: true,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 2),
    );
  }

  void stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    }
  }

  void cancelListening() {
    if (_speech.isListening) {
      _speech.cancel();
    }
  }

  bool get isListening => _speech.isListening;
}
