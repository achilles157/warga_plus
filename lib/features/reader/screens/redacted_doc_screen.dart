import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/models/release_model.dart';
import '../widgets/reader_widgets.dart';
import '../widgets/live_chat_sheet.dart';
import '../../profile/services/profile_service.dart';

class RedactedDocScreen extends StatefulWidget {
  final SubModule subModule;

  const RedactedDocScreen({super.key, required this.subModule});

  @override
  State<RedactedDocScreen> createState() => _RedactedDocScreenState();
}

class _RedactedDocScreenState extends State<RedactedDocScreen>
    with SingleTickerProviderStateMixin {
  bool _envelopeOpened = false;
  late AnimationController _envelopeController;

  @override
  void initState() {
    super.initState();
    _envelopeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    // Auto-open envelope after brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _envelopeController.forward();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _envelopeOpened = true);
        });
      }
    });
  }

  @override
  void dispose() {
    _envelopeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: _envelopeOpened
          ? AppBar(
              title: Row(
                children: [
                  const Icon(Icons.description,
                      size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(widget.subModule.title,
                        style: const TextStyle(
                            fontFamily: 'Courier', fontSize: 16),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF2A2A3C),
              foregroundColor: Colors.white,
              elevation: 0,
            )
          : null,
      body: _envelopeOpened ? _buildDocument() : _buildEnvelopeAnimation(),
      bottomNavigationBar: _envelopeOpened ? _buildBottomBar() : null,
      floatingActionButton: _envelopeOpened
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => LiveChatSheet(
                    aiContext: widget.subModule.aiContext ?? '',
                    releaseTitle: widget.subModule.title,
                    moduleType: widget.subModule.type,
                  ),
                );
              },
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.psychology, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEnvelopeAnimation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Envelope Container
          AnimatedBuilder(
            animation: _envelopeController,
            builder: (context, child) {
              final scale = 1.0 - (_envelopeController.value * 0.3);
              final rotation = _envelopeController.value * 0.1;
              return Transform.scale(
                scale: scale,
                child: Transform.rotate(
                  angle: rotation,
                  child: Container(
                    width: 280,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D3D4D),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[700]!, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Envelope flap
                        Positioned(
                          top: 0,
                          child: CustomPaint(
                            size: const Size(280, 80),
                            painter: EnvelopeFlapPainter(
                              progress: _envelopeController.value,
                            ),
                          ),
                        ),
                        // TOP SECRET Seal
                        Positioned(
                          top: 60,
                          child: Opacity(
                            opacity: 1 - _envelopeController.value,
                            child: Transform.scale(
                              scale: 1 + (_envelopeController.value * 0.5),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red[900],
                                  borderRadius: BorderRadius.circular(4),
                                  border:
                                      Border.all(color: Colors.red, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  "TOP SECRET",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Courier',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            "Opening classified document...",
            style: TextStyle(
              color: Colors.grey[500],
              fontFamily: 'Courier',
              fontSize: 14,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .fade(begin: 0.3, end: 1, duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildDocument() {
    return Stack(
      children: [
        // Paper Texture Background
        Positioned.fill(
          child: CustomPaint(
            painter: PaperTexturePainter(),
          ),
        ),
        // Document Content
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              // Aged paper color
              color: const Color(0xFFF5F0E6),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFD4C4A8), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(4, 8),
                ),
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
                  text: widget.subModule.content ?? "No content provided.",
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 16,
                    height: 1.8,
                    color: Color(0xFF2C2C2C), // Dark text for paper bg
                  ),
                ).animate().fade(duration: 800.ms, delay: 200.ms),

                const SizedBox(height: 48),
                Divider(color: Colors.brown.withValues(alpha: 0.3)),
                const Text(
                  "Tap black blocks to reveal content.",
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 12,
                    color: Color(0xFF8B7355),
                    fontStyle: FontStyle.italic,
                  ),
                ).animate().fade(delay: 1000.ms),
              ],
            ),
          ).animate().slideY(begin: 0.2, end: 0, duration: 600.ms).fade(),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: const Color(0xFF2A2A3C),
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () async {
          await ProfileService().completeModule(widget.subModule);
          if (mounted) {
            _showCompletionDialog(context);
          }
        },
        icon: const Icon(Icons.check_circle_outline),
        label: const Text("SELESAI DIBACA"),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ).animate().scale(delay: 800.ms, curve: Curves.elasticOut),
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/badges/xp_star.png', width: 100, height: 100)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      duration: 1000.ms)
                  .then()
                  .shimmer(duration: 1200.ms),
              const SizedBox(height: 16),
              const Text("MODULE COMPLETED!",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              const SizedBox(height: 8),
              Text("+${widget.subModule.xpReward} XP",
                  style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("LANJUTKAN"),
                ),
              )
            ],
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}

// Custom painter for paper texture background
class PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF8F4ED);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Subtle grain texture
    final grainPaint = Paint()
      ..color = const Color(0xFFE8DFD0)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (double y = 0; y < size.height; y += 3) {
      for (double x = 0; x < size.width; x += 4) {
        if ((x.toInt() + y.toInt()) % 7 == 0) {
          canvas.drawCircle(Offset(x, y), 0.5, grainPaint);
        }
      }
    }

    // Fold line simulation
    final foldPaint = Paint()
      ..color = const Color(0xFFD4C8B8).withValues(alpha: 0.3)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      foldPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for envelope flap
class EnvelopeFlapPainter extends CustomPainter {
  final double progress;

  EnvelopeFlapPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.lerp(
        const Color(0xFF4D4D5D),
        const Color(0xFF3D3D4D),
        progress,
      )!
      ..style = PaintingStyle.fill;

    final path = Path();
    final flapHeight = 80 * (1 - progress);
    path.moveTo(0, flapHeight);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, flapHeight);
    path.close();

    canvas.drawPath(path, paint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant EnvelopeFlapPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
