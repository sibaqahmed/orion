import 'package:flutter/foundation.dart';
import 'package:orion/services/tts/tts_service.dart';
import 'package:orion/services/voice/speech_service.dart';

enum AssistantState {
  idle,
  listening,
  thinking,
  speaking,
}

class AssistantController extends ChangeNotifier {
  final SpeechService _speechService = SpeechService();

  AssistantState _state = AssistantState.idle;
  AssistantState get state => _state;

  String _lastText = '';
  String get lastText => _lastText;

  bool _speechReady = false;

  // ✅ NEW: AssistantScreen sets this to auto-send to Gemini
  void Function(String finalText)? onFinalText;

  Future<void> initSpeech() async {
    _speechReady = await _speechService.init(
      onStatus: handleSpeechStatus,
      onError: (_) => _setState(AssistantState.idle),
    );
  }

  void handleSpeechStatus(String status) {
    // Typical: "listening", "notListening", "done"
    if ((status == "done" || status == "notListening") &&
        _state == AssistantState.listening) {
      stopListening(); // will trigger onFinalText if needed
    }
  }

  void attachTts(TtsService tts) {
    tts.onStart = () => _setState(AssistantState.speaking);
    tts.onComplete = () => _setState(AssistantState.idle);
    tts.onCancel = () => _setState(AssistantState.idle);
  }

  void _setState(AssistantState newState) {
    _state = newState;
    notifyListeners();
  }

  void startListening() {
    if (!_speechReady) return;

    _lastText = '';
    _setState(AssistantState.listening);

    _speechService.startListening((text) {
      if (text.isEmpty) return;
      _lastText = text;
      notifyListeners();
    });
  }

  void stopListening() {
    _speechService.stopListening();

    final trimmed = _lastText.trim();

    if (trimmed.isNotEmpty) {
      _setState(AssistantState.thinking);

      // ✅ THIS is the missing link in your app
      // When speech ends automatically, we still send to Orion.
      onFinalText?.call(trimmed);
    } else {
      _setState(AssistantState.idle);
    }
  }

  void setThinking() => _setState(AssistantState.thinking);
  void setIdle() => _setState(AssistantState.idle);

  void reset() {
    _lastText = '';
    _setState(AssistantState.idle);
  }
}
