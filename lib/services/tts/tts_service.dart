import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  bool _enabled = true;
  bool get enabled => _enabled;

  bool _isReady = false;

  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  // ✅ NEW: expose current voice params (so Settings can show them)
  double _speechRate = 0.45;
  double get speechRate => _speechRate;

  double _pitch = 1.0;
  double get pitch => _pitch;

  // ✅ These let AssistantController drive orb state (“alive” glue)
  VoidCallback? onStart;
  VoidCallback? onComplete;
  VoidCallback? onCancel;
  void Function(String error)? onError;

  /// Call once (screen init / app start)
  Future<void> init() async {
    if (_isReady) return;

    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(_speechRate);
    await _tts.setPitch(_pitch);

    // Flush previous speech before new speech
    await _tts.setQueueMode(1); // FLUTTER_TTS_QUEUE_FLUSH

    _tts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
      onStart?.call();
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
      onComplete?.call();
    });

    _tts.setCancelHandler(() {
      _isSpeaking = false;
      notifyListeners();
      onCancel?.call();
    });

    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
      notifyListeners();
      onError?.call(msg);
      onCancel?.call();
    });

    _isReady = true;
  }

  /// Enable / disable voice responses
  void setEnabled(bool value) {
    _enabled = value;
    notifyListeners();

    if (!_enabled) {
      stop();
    }
  }

  void toggle() => setEnabled(!_enabled);

  // ✅ NEW: rate/pitch setters (used by Settings)
  Future<void> setSpeechRate(double value) async {
    _speechRate = value.clamp(0.1, 1.0);
    notifyListeners();
    if (_isReady) {
      await _tts.setSpeechRate(_speechRate);
    }
  }

  Future<void> setPitch(double value) async {
    _pitch = value.clamp(0.5, 2.0);
    notifyListeners();
    if (_isReady) {
      await _tts.setPitch(_pitch);
    }
  }

  /// Speak text (used by ChatController)
  Future<void> speak(String text) async {
    if (!_enabled) return;
    if (!_isReady) await init();

    final cleaned = text.trim();
    if (cleaned.isEmpty) return;

    await _tts.stop();

    _isSpeaking = true;
    notifyListeners();

    await _tts.speak(cleaned);
  }

  /// 🔥 Used for interruption (mic tap, toggle off, etc.)
  Future<void> stop() async {
    if (!_isReady) return;

    await _tts.stop();

    _isSpeaking = false;
    notifyListeners();
    onCancel?.call();
  }
}
