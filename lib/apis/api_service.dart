import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get apiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static String get defaultModel => dotenv.env['DEFAULT_MODEL'] ?? 'nvidia/nemotron-3-nano-30b-a3b:free';
  static const String baseUrl = 'https://openrouter.ai/api/v1';
}