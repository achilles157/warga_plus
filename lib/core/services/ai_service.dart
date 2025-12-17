import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  // Model Llama 3 8B (Ringan, Cepat, Gratis di Groq)
  static const String _model = 'llama-3.1-8b-instant';

  Future<String> explainAnswer(String question, String contextInfo) async {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    if (apiKey == null) {
      return "Error: API Key Groq belum diset.";
    }

    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    final prompt = '''
    Kamu adalah "Bung Warga", asisten edukasi sejarah yang asik ala Gen Z Indonesia.
    Jelaskan jawaban dari pertanyaan ini dengan santai, singkat (max 3 kalimat), dan akurat.
    
    Pertanyaan: "$question"
    Konteks Data: "$contextInfo"
    ''';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': prompt},
          ],
          'temperature': 0.7, // Kreativitas (0.0 kaku - 1.0 liar)
          'max_tokens': 150, // Batasi panjang jawaban biar cepat
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        // Jika error, kita bisa lihat apa masalahnya
        final errorData = jsonDecode(response.body);
        return "Groq Error: ${errorData['error']['message']}";
      }
    } catch (e) {
      return "Gagal menghubungi Groq: $e";
    }
  }
}
