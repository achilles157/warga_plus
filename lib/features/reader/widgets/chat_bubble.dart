import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isAi;
  final String? imageUrl;
  final String? caption;
  final bool skipAnimation;

  const ChatBubble({
    super.key,
    required this.text,
    this.isAi = true,
    this.imageUrl,
    this.caption,
    this.skipAnimation = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAi) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 16, bottom: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
                image: const DecorationImage(
                  image: AssetImage('assets/mascot/bung_warga_neutral.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(width: 4),
          ],
          Flexible(
            fit: FlexFit.loose,
            child: Container(
              margin: EdgeInsets.only(
                  top: 8,
                  bottom: 8,
                  right: isAi ? 16 : 16,
                  left: isAi ? 0 : 16),
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: isAi
                    ? const Color(0xFF2A2A3C)
                    : const Color(0xFF6C63FF), // Dark surface / Accent
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isAi ? 4 : 16),
                  bottomRight: Radius.circular(isAi ? 16 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isAi && !skipAnimation)
                    Text(
                      "Bung Warga",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.6)),
                    ).animate().fade(),
                  if (isAi && !skipAnimation) const SizedBox(height: 4),
                  if (isAi)
                    Builder(builder: (context) {
                      return skipAnimation
                          ? Text(
                              text,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                color: Colors.white, // White text for dark bg
                              ),
                            )
                          : Text(
                              text,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                color: Colors.white,
                              ),
                            ).animate().custom(
                                duration: Duration(
                                    milliseconds:
                                        (text.length * 30).clamp(500, 3000)),
                                builder: (context, value, child) {
                                  final int count =
                                      (text.length * value).toInt();
                                  return Text(
                                    text.substring(0, count),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.4,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              );
                    })
                  else
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        color: Colors.white,
                      ),
                    ),
                  if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl!,
                        errorBuilder: (ctx, _, __) => const SizedBox(),
                      ),
                    ).animate().fade(duration: 500.ms).scale(),
                    if (caption != null && caption!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          caption!,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: isAi ? Colors.grey[600] : Colors.white70,
                          ),
                        ),
                      ).animate(delay: 400.ms).fade(),
                  ],
                ],
              ),
            ).animate().fade(duration: 300.ms).slideX(
                  begin: isAi ? -0.1 : 0.1,
                  end: 0,
                  curve: Curves.easeOutQuad,
                ),
          ),
        ],
      ),
    );
  }
}
