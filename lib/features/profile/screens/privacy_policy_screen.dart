import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Kebijakan Privasi'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield,
                      size: 48,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Data Anda Aman",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Kami berkomitmen melindungi privasi Anda",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Policy Sections
            _buildPolicyCard(
              icon: Icons.lock,
              title: "Data Tidak Dijual",
              content:
                  "Kami TIDAK PERNAH menjual data pengguna kepada pihak ketiga manapun. "
                  "Data Anda adalah milik Anda sepenuhnya.",
              color: Colors.blue,
            ),

            _buildPolicyCard(
              icon: Icons.storage,
              title: "Penyimpanan Data",
              content:
                  "Data tersimpan terenkripsi di Firebase (Google Cloud) dengan standar keamanan industri. "
                  "Hanya Anda yang dapat mengakses data akun Anda.",
              color: Colors.indigo,
            ),

            _buildPolicyCard(
              icon: Icons.info_outline,
              title: "Data yang Dikumpulkan",
              content: "• Email untuk login\n"
                  "• Progress belajar (XP, modul selesai)\n"
                  "• Preferensi arketype\n\n"
                  "Kami TIDAK mengumpulkan lokasi, kontak, atau data sensitif lainnya.",
              color: Colors.orange,
            ),

            _buildPolicyCard(
              icon: Icons.delete_outline,
              title: "Hak Penghapusan",
              content:
                  "Anda dapat meminta penghapusan akun dan seluruh data kapan saja. "
                  "Hubungi tim kami melalui email dan data akan dihapus dalam 7 hari kerja.",
              color: Colors.red,
            ),

            _buildPolicyCard(
              icon: Icons.psychology,
              title: "Penggunaan AI",
              content: "Fitur Tanya Bung Warga menggunakan AI (Google Gemini). "
                  "Percakapan AI TIDAK disimpan di server kami dan tidak digunakan untuk melatih model.",
              color: Colors.purple,
            ),

            const SizedBox(height: 24),

            // Trust Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    "100% Privasi Terjamin",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Last Updated
            Center(
              child: Text(
                "Terakhir diperbarui: 3 Januari 2026",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
