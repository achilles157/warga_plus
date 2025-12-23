import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  // Model Llama 3 8B (Ringan, Cepat, Gratis di Groq)
  static const String _model = 'llama-3.1-8b-instant';

  Future<String> chatWithContext(
      String question, String contextText, String moduleType) async {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    if (apiKey == null) {
      return "Error: API Key Groq belum diset.";
    }

    // 1. Validate Context
    if (contextText.isEmpty) {
      return "Maaf, saya tidak memiliki konteks informasi untuk modul ini.";
    }

    // 2. Persona Selection
    String personaInstruction = "";
    if (moduleType == 'redacted_doc') {
      personaInstruction = '''
      GAYA BICARA:
      - Kamu adalah seorang "Whistleblower" atau penguak fakta rahasia.
      - Gunakan nada yang agak sarkastik, misterius, dan kritis tajam.
      - Seolah-olah kamu sedang membocorkan rahasia negara kepada teman dekat secara diam-diam.
      - Gunakan istilah seperti "katanya sih", "fakta yang disembunyikan", atau "konspirasi".
      ''';
    } else {
      // Default: chat_stream / Gen Z
      personaInstruction = '''
      GAYA BICARA:
      - Kamu adalah temen ngobrol "Anak Jakarta Selatan" (Gen Z).
      - Gunakan bahasa gaul tapi sopan (aku-kamu / lo-gue boleh asal sopan).
      - Santai, asik, dan ekspresif (boleh pakai emoji).
      - Jangan kaku kaya robot atau dosen.
      ''';
    }

    // 3. Smart Truncation
    String safeContext = contextText;
    const int maxChars = 15000;
    if (safeContext.length > maxChars) {
      // Find the last period before maxChars to cut cleanly
      int cutIndex = safeContext.lastIndexOf('.', maxChars);
      if (cutIndex == -1) cutIndex = maxChars; // Fallback if no period found
      safeContext =
          "${safeContext.substring(0, cutIndex)} [DATA DIPOTONG UNTUK EFISIENSI]...";
    }

    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final systemPrompt = '''
    Kamu adalah "Bung Warga", asisten AI RAG.
    
    $personaInstruction

    PERATURAN UTAMA:
    1. Jawab pertanyaan pengguna HANYA dengan informasi yang ada di DATA KONTEKS berikut.
    2. JAWABAN WAJIB SANGAT RINGKAS: Maksimal 2-3 kalimat saja.
    3. Jika pertanyaan TIDAK ADA jawabannya di dalam konteks, kamu HARUS menolak.
       Katakan (sesuai gaya bicara): "Wah sorry, data itu gak ada di dokumen ini." atau sejenisnya.
    4. DILARANG HALUSINASI (ngarang bebas).
    
    DATA KONTEKS:
    """
    $safeContext
    """
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
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': question},
          ],
          'temperature': 0.6, // Slightly higher for more creative persona
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        final errorData = jsonDecode(response.body);
        return "Groq Error: ${errorData['error']['message']}";
      }
    } catch (e) {
      return "Gagal menghubungi Groq: $e";
    }
  }
}
