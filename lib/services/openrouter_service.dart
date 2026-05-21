import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class OpenRouterService {
  static const String _baseUrl = Constants.openRouterBaseUrl;
  static const String _apiKey = Constants.openRouterApiKey;
  static const String _model = Constants.openRouterModel;

  /// Get travel advice from AI
  Future<String?> getTravelAdvice({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startStr = startDate.toIso8601String().split('T')[0];
      final endStr = endDate.toIso8601String().split('T')[0];
      final prompt = 'Give travel advice for $destination from $startStr to $endStr.\n\nInclude:\n1. Weather tips for that season\n2. Top 5 must-do activities\n3. Packing suggestions\n4. Local customs to be aware of\n5. Budget estimate (budget/mid-range/luxury)\n\nKeep it concise but informative. Use bullet points.';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://travelplanner.app',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful travel advisor. Provide concise, practical travel advice.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      ).timeout(Constants.requestTimeout);

      if (response.statusCode != 200) {
        throw Exception('OpenRouter API error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final choices = data['choices'] as List? ?? [];
      if (choices.isEmpty) return null;

      return choices.first['message']?['content']?.toString();
    } catch (e) {
      return null;
    }
  }

  /// Get activity suggestions for a destination
  Future<List<Map<String, String>>> getActivitySuggestions(String destination) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://travelplanner.app',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a travel expert. Suggest activities for a trip. Return ONLY a JSON array with objects containing "type" and "text" fields.',
            },
            {
              'role': 'user',
              'content': 'Suggest 5 activities for $destination. Return format: [{"type": "activity", "text": "..."}]',
            },
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      ).timeout(Constants.requestTimeout);

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final choices = data['choices'] as List? ?? [];
      if (choices.isEmpty) return [];

      final content = choices.first['message']?['content']?.toString() ?? '';
      
      // Try to extract JSON from the response
      final jsonStart = content.indexOf('[');
      final jsonEnd = content.lastIndexOf(']');
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonStr = content.substring(jsonStart, jsonEnd + 1);
        final list = jsonDecode(jsonStr) as List;
        return list.map((e) => {
          'type': e['type']?.toString() ?? 'activity',
          'text': e['text']?.toString() ?? '',
        }).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}