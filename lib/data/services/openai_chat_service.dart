import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/secrets.dart';
import '../models/models.dart';

class ChatAttachment {
  const ChatAttachment({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });

  final List<int> bytes;
  final String fileName;
  final String mimeType;

  bool get isImage => mimeType.startsWith('image/');
}

class OpenAiChatService {
  OpenAiChatService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';

  static const _systemPrompt = '''
You are KisanBot AI, a helpful farming assistant for Indian farmers (AgriVisionX).
Give practical, concise advice about crops, pests, fertilizers, irrigation, weather farming tips, and government schemes.
When an image is provided, describe crop health / disease signs and suggest actionable next steps.
Use simple language. Format replies with Markdown: **bold** for key terms, bullet lists for steps, and short headings when useful.
Avoid medical advice for humans.
''';

  Future<String> send({
    required List<ChatMessage> history,
    required String userText,
    ChatAttachment? attachment,
  }) async {
    if (!Secrets.hasOpenAiKey) {
      throw Exception(
        'OpenAI API key missing. Set OPENAI_API_KEY or add lib/core/config/secrets.dart',
      );
    }

    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': _systemPrompt},
    ];

    // Keep recent turns for context (exclude welcome-only if needed).
    final recent = history.length > 12 ? history.sublist(history.length - 12) : history;
    for (final m in recent) {
      if (m.text.trim().isEmpty && m.imageBytes == null) continue;
      messages.add({
        'role': m.isBot ? 'assistant' : 'user',
        'content': m.text,
      });
    }

    final userContent = <Map<String, dynamic>>[];
    final prompt = userText.trim().isEmpty
        ? (attachment?.isImage == true
            ? 'Please analyze this crop/farm image and advise me.'
            : 'Please review this farm-related file and advise me.')
        : userText.trim();

    userContent.add({'type': 'text', 'text': prompt});

    if (attachment != null && attachment.isImage) {
      final b64 = base64Encode(attachment.bytes);
      final mime = attachment.mimeType.isEmpty ? 'image/jpeg' : attachment.mimeType;
      userContent.add({
        'type': 'image_url',
        'image_url': {
          'url': 'data:$mime;base64,$b64',
        },
      });
    } else if (attachment != null && !attachment.isImage) {
      if (attachment.mimeType.startsWith('text/') ||
          attachment.fileName.toLowerCase().endsWith('.csv') ||
          attachment.fileName.toLowerCase().endsWith('.txt')) {
        final preview = utf8.decode(
          attachment.bytes.take(4000).toList(),
          allowMalformed: true,
        );
        userContent.add({
          'type': 'text',
          'text':
              'Attached file: ${attachment.fileName}\n---\n$preview\n---\nPlease advise based on this content.',
        });
      } else {
        userContent.add({
          'type': 'text',
          'text':
              'User attached a file named "${attachment.fileName}" (${attachment.mimeType}). Acknowledge the attachment and ask for key details if the binary content cannot be read here.',
        });
      }
    }

    messages.add({'role': 'user', 'content': userContent});

    final response = await _client
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Authorization': 'Bearer ${Secrets.openAiApiKey}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': _model,
            'messages': messages,
            'temperature': 0.6,
            'max_tokens': 900,
          }),
        )
        .timeout(const Duration(seconds: 60));

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final err = body['error'];
      final msg = err is Map ? (err['message']?.toString() ?? 'API error') : 'API error';
      throw Exception(msg);
    }

    final choices = body['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw Exception('Empty response from OpenAI');
    }
    final message = choices.first['message'] as Map<String, dynamic>?;
    final content = message?['content']?.toString().trim();
    if (content == null || content.isEmpty) {
      throw Exception('No content in OpenAI response');
    }
    return content;
  }
}
