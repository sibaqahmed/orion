import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GeminiService({
    required String apiKey,
    this.modelName = 'gemini-flash-latest', // ✅ FIXED default
  })  : _model = GenerativeModel(
    model: modelName,
    apiKey: apiKey,
    systemInstruction: Content.text(
      'You are Orion, a helpful personal AI assistant. Be concise, clear, and friendly.',
    ),
  ),
        _chat = null;

  final String modelName;
  final GenerativeModel _model;
  ChatSession? _chat;

  void startSession() {
    _chat ??= _model.startChat();
  }

  Future<String> sendMessage(String text) async {
    startSession();

    final response = await _chat!.sendMessage(Content.text(text));
    final out = response.text;

    if (out == null || out.trim().isEmpty) {
      return "I couldn't generate a response. Try again.";
    }
    return out.trim();
  }
}
