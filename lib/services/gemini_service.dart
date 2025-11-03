import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Service for Gemini AI integration
class GeminiService {
  static const String _apiKey = 'AIzaSyDL_pHIOr57pdxw4OYuVNAjw314g6V4DEQ';
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;

  GeminiService() {
    // Model for text chat (Gemini 2.5 Flash)
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 1.0,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 300,
      ),
      systemInstruction: Content.text(
        'You are a helpful AI assistant. Keep responses brief and natural. '
        'IMPORTANT: Always respond in the EXACT same language that the user asks the question in. '
        'If the user asks in English, respond in English. '
        'If the user asks in Bengali, respond in Bengali. '
        'Never switch languages.',
      ),
    );

    // Model for image analysis (Gemini 2.5 Flash supports both text and vision)
    _visionModel = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 1.0,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 512,
      ),
    );
  }

  /// Send a text message to Gemini AI
  Future<String> sendMessage(String message) async {
    try {
      final content = [Content.text(message)];
      final response = await _model.generateContent(content);

      return response.text ?? 'Sorry, I could not generate a response.';
    } catch (e) {
      // Handle rate limit error
      if (e.toString().contains('Resource exhausted') ||
          e.toString().contains('429')) {
        return '⚠️ API Limit Reached\n\n'
            'The AI service has temporarily reached its usage limit. '
            'Please try again in a few minutes.\n\n'
            'Tips:\n'
            '• Wait 1-2 minutes before next question\n'
            '• Keep questions concise\n'
            '• Avoid sending too many messages quickly';
      }
      return 'Error: ${e.toString()}';
    }
  }

  /// Analyze an image to detect crop diseases and pests
  Future<String> analyzeImage(File imageFile, String? additionalPrompt) async {
    try {
      final imageBytes = await imageFile.readAsBytes();

      final prompt = additionalPrompt != null && additionalPrompt.isNotEmpty
          ? additionalPrompt
          : 'What is this plant?';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _visionModel.generateContent(content);

      return response.text ??
          'Sorry, I could not analyze the image. Please try again.';
    } catch (e) {
      // Handle rate limit error
      if (e.toString().contains('Resource exhausted') ||
          e.toString().contains('429')) {
        return '⚠️ API Limit Reached\n\n'
            'The AI service has temporarily reached its usage limit. '
            'Please try again in a few minutes.\n\n'
            'Tips:\n'
            '• Wait 1-2 minutes before next analysis\n'
            '• Reduce image analysis frequency';
      }
      return 'Error analyzing image: ${e.toString()}';
    }
  }

  /// Start a chat session for continuous conversation
  ChatSession startChat() {
    return _model.startChat();
  }

  /// Send message in an ongoing chat session
  Future<String> sendChatMessage(ChatSession chat, String message) async {
    try {
      // Add language instruction to each message
      final enhancedMessage =
          'Respond in the EXACT same language as this message. Do not translate. '
          'User message: $message';

      final response = await chat.sendMessage(Content.text(enhancedMessage));
      return response.text ?? 'Sorry, I could not generate a response.';
    } catch (e) {
      // Handle rate limit error
      if (e.toString().contains('Resource exhausted') ||
          e.toString().contains('429')) {
        return '⚠️ API Limit Reached\n\n'
            'The AI service has temporarily reached its usage limit. '
            'Please try again in a few minutes.\n\n'
            'Tips:\n'
            '• Wait 1-2 minutes before next question\n'
            '• Keep questions concise\n'
            '• Avoid sending too many messages quickly';
      }
      return 'Error: ${e.toString()}';
    }
  }
}
