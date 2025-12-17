import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/models/release_model.dart';
import '../widgets/reader_widgets.dart';
import '../../profile/services/profile_service.dart';

class RedactedDocScreen extends StatelessWidget {
  final SubModule subModule;

  const RedactedDocScreen({super.key, required this.subModule});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0), // Off-white
      appBar: AppBar(
        title: Text(subModule.title,
            style: const TextStyle(fontFamily: 'Courier')),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Stamp
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Transform.rotate(
                  angle: -0.1,
                  child: const Text(
                    "CONFIDENTIAL",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      fontFamily: 'Courier',
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fade(duration: 400.ms)
                  .scale(duration: 400.ms, curve: Curves.elasticOut)
                  .shake(delay: 500.ms),
              const SizedBox(height: 32),

              // The Content
              RedactedTextWidget(
                text: subModule.content ?? "No content provided.",
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 16,
                  height: 1.8,
                  color: Colors.black87,
                ),
              ).animate().fade(duration: 800.ms, delay: 200.ms),

              const SizedBox(height: 48),
              const Divider(color: Colors.black54),
              const Text(
                "Tap black blocks to reveal content.",
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ).animate().fade(delay: 1000.ms),
            ],
          ),
        ).animate().slideY(begin: 0.1, end: 0, duration: 500.ms).fade(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () async {
            await ProfileService().completeModule(subModule);
            if (context.mounted) Navigator.pop(context);
          },
          icon: const Icon(Icons.check_circle_outline),
          label: const Text("SELESAI DIBACA"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ).animate().scale(delay: 1200.ms, curve: Curves.elasticOut),
      ),
    );
  }
}
