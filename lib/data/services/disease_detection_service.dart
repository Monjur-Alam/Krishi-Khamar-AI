import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/secrets.dart';
import '../../core/theme/app_colors.dart';
import '../models/models.dart';

class DiseaseDetectionService {
  DiseaseDetectionService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';

  Future<CropScan> analyzeImage(List<int> imageBytes) async {
    if (!Secrets.hasOpenAiKey) {
      throw Exception('OpenAI API key missing');
    }

    final b64 = base64Encode(imageBytes);
    final response = await _client
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Authorization': 'Bearer ${Secrets.openAiApiKey}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': _model,
            'response_format': {'type': 'json_object'},
            'temperature': 0.2,
            'max_tokens': 900,
            'messages': [
              {
                'role': 'system',
                'content':
                    '''You are an expert plant pathologist for Indian farmers.
Analyze the crop leaf/plant photo and respond ONLY with valid JSON:
{
  "crop": "Tomato",
  "emoji": "🍅",
  "diagnosis": "Early Blight" or "Healthy",
  "scientificName": "Alternaria solani" or "",
  "severity": "High" | "Medium" | "Low" | "None",
  "risk": "high" | "medium" | "healthy",
  "matchPercent": 87,
  "spread": "30% Leaves",
  "description": "2-3 sentence description",
  "treatments": [
    {"number": 1, "priority": "urgent"|"important"|"good", "description": "step"}
  ]
}
If healthy, risk must be "healthy", diagnosis "Healthy", treatments can be preventive tips.
Provide 4-5 practical treatment steps for Indian farming conditions.''',
              },
              {
                'role': 'user',
                'content': [
                  {
                    'type': 'text',
                    'text':
                        'Detect crop disease from this image and return the JSON schema.',
                  },
                  {
                    'type': 'image_url',
                    'image_url': {
                      'url': 'data:image/jpeg;base64,$b64',
                    },
                  },
                ],
              },
            ],
          }),
        )
        .timeout(const Duration(seconds: 90));

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final err = body['error'];
      final msg = err is Map ? (err['message']?.toString() ?? 'API error') : 'API error';
      throw Exception(msg);
    }

    final content =
        body['choices']?[0]?['message']?['content']?.toString() ?? '{}';
    final json = jsonDecode(content) as Map<String, dynamic>;
    return _mapScan(json);
  }

  CropScan _mapScan(Map<String, dynamic> json) {
    final riskName = (json['risk'] as String? ?? 'medium').toLowerCase();
    final risk = switch (riskName) {
      'high' => ScanRisk.high,
      'healthy' => ScanRisk.healthy,
      _ => ScanRisk.medium,
    };

    final treatmentsRaw = json['treatments'] as List<dynamic>? ?? const [];
    final treatments = <TreatmentStep>[];
    for (var i = 0; i < treatmentsRaw.length; i++) {
      final t = treatmentsRaw[i] as Map<String, dynamic>;
      final priority = (t['priority'] as String? ?? '').toLowerCase();
      final color = switch (priority) {
        'urgent' => AppColors.danger,
        'important' => AppColors.warning,
        _ => AppColors.success,
      };
      treatments.add(
        TreatmentStep(
          number: t['number'] as int? ?? (i + 1),
          description: t['description'] as String? ?? '',
          color: color,
        ),
      );
    }

    return CropScan(
      crop: json['crop'] as String? ?? 'Crop',
      diagnosis: json['diagnosis'] as String? ?? 'Unknown',
      timeAgo: 'Just now',
      risk: risk,
      emoji: json['emoji'] as String? ?? '🌿',
      scientificName: json['scientificName'] as String? ?? '',
      severity: json['severity'] as String? ?? '',
      matchPercent: (json['matchPercent'] as num?)?.round() ?? 0,
      spread: json['spread'] as String? ?? '',
      description: json['description'] as String? ?? '',
      treatments: treatments,
      createdAt: DateTime.now(),
    );
  }
}
