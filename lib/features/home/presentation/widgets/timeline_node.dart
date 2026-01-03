import 'package:flutter/material.dart';
import '../../../../core/models/release_model.dart';

class TimelineNode extends StatelessWidget {
  final SubModule subModule;
  final bool isLocked;
  final bool isCompleted;
  final bool isNext;
  final VoidCallback? onTap;
  final int index;

  const TimelineNode({
    super.key,
    required this.subModule,
    this.isLocked = false,
    this.isCompleted = false,
    this.isNext = false,
    this.onTap,
    required this.index,
  });

  /// Generates a partially censored title for locked modules
  /// Shows enough chars for users to guess the topic
  String _generateCensoredTitle(String title) {
    if (title.length <= 5) return "███";

    final words = title.split(' ');
    final result = StringBuffer();

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (i == 0) {
        // First word: show first 4-5 chars then light censor
        if (word.length <= 4) {
          result.write(word);
        } else {
          result.write(word.substring(0, 4));
          result.write('█' * (word.length - 4).clamp(1, 2)); // Less blocks
        }
      } else if (i == words.length - 1) {
        // Last word: show more (first 2 + last 2)
        if (word.length <= 3) {
          result.write(word);
        } else {
          result.write(word.substring(0, 2));
          result.write('█');
          result.write(word.substring(word.length - 2));
        }
      } else {
        // Middle words: show first 2-3 chars + light censor
        if (word.length <= 3) {
          result.write(word);
        } else {
          result.write(word.substring(0, 2));
          result.write('█' * (word.length - 2).clamp(1, 2));
        }
      }
      if (i < words.length - 1) result.write(' ');
    }

    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Random rotation for organic feel (deterministic based on index)
    final double rotation = (index % 2 == 0 ? -1 : 1) * 0.05;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Transform.rotate(
        angle: rotation,
        child: SizedBox(
          width: 160,
          height: 190, // Increased slighty for scotch tape space
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // 1. Polaroid Card
              Container(
                width: 160,
                height: 172, // Keep original card height
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA), // Slightly off-white paper
                  borderRadius: BorderRadius.circular(
                      2), // Sharper corners for photo paper
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12, // Softer shadow
                      offset: const Offset(4, 6), // More depth
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Photo Area (The "Image")
                    Container(
                      height: 90,
                      margin: const EdgeInsets.fromLTRB(
                          6, 6, 6, 0), // Photo border margin
                      decoration: BoxDecoration(
                        color: isLocked
                            ? Colors.grey[300]
                            : const Color(0xFF222222), // Dark bg for photo feel
                        border:
                            Border.all(color: Colors.grey[300]!, width: 0.5),
                      ),
                      child: isLocked
                          ? Center(
                              child: Icon(
                                Icons.question_mark,
                                size: 32,
                                color: Colors.grey[600],
                              ),
                            )
                          : Stack(
                              fit: StackFit.expand,
                              children: [
                                // Placeholder for actual image if we had one, or keep icon
                                Center(
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      subModule.type == 'redacted_doc'
                                          ? Icons.description
                                          : (subModule.type == 'chat_stream'
                                              ? Icons.chat_bubble_outline
                                              : Icons.extension),
                                      size: 28,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),

                                // Checkmark overlay - ONLY show when completed
                                if (isCompleted)
                                  Container(
                                      color:
                                          Colors.black.withValues(alpha: 0.6),
                                      child: const Center(
                                          child: Icon(Icons.check_circle,
                                              color: Colors.greenAccent,
                                              size: 40))),
                              ],
                            ),
                    ),

                    // Text Area (Handwritten/Typewriter Label)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                isLocked
                                    ? _generateCensoredTitle(subModule.title)
                                    : subModule.title,
                                style: TextStyle(
                                  fontFamily: 'Courier Prime',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color:
                                      isLocked ? Colors.grey : Colors.black87,
                                  height: 1.1,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isLocked)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "EXP ${subModule.xpReward}",
                                    style: TextStyle(
                                      fontFamily: 'Courier Prime',
                                      fontSize: 9,
                                      color: Colors.red[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Scotch Tape Widget (Top Center)
              Positioned(
                top: -12, // Move up to overlap edge
                child: Transform.rotate(
                  angle: (index % 3 - 1) * 0.05, // Random-ish tilt for tape
                  child: Container(
                    width: 50,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: 0.4), // Semi-transparent
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        )
                      ],
                    ),
                    child: CustomPaint(
                      painter: TapeTexturePainter(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple texture for the tape to look fibrous
class TapeTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += 2) {
      canvas.drawLine(Offset(i, 0), Offset(i + 5, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
