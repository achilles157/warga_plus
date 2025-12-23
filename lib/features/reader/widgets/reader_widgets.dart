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
                color: isAi ? Colors.white : Colors.indigo,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isAi ? 4 : 16),
                  bottomRight: Radius.circular(isAi ? 16 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                          color: Colors.indigo.shade300),
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
                                color: Colors.black87,
                              ),
                            )
                          : Text(
                              text,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                color: Colors.black87,
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
                                      color: Colors.black87,
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

class SummaryCard extends StatelessWidget {
  final String title;
  final String content;

  const SummaryCard({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Light yellow/papyrus look
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.orange),
          ...lines.map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.brown)),
                    Expanded(
                      child: Text(
                        line.trim().replaceAll(RegExp(r'^[-•]\s*'), ''),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.brown.shade800,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'DISIMPAN DI MEMORI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.brown.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RedactedTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const RedactedTextWidget({
    super.key,
    required this.text,
    this.style,
  });

  @override
  State<RedactedTextWidget> createState() => _RedactedTextWidgetState();
}

class _RedactedTextWidgetState extends State<RedactedTextWidget> {
  // Map to track which indices are revealed. Key is the segment index.
  final Map<int, bool> _revealedSegments = {};

  @override
  Widget build(BuildContext context) {
    // Regex to find content inside square brackets, e.g., [SECRET]
    final RegExp regex = RegExp(r'\[(.*?)\]');
    final List<InlineSpan> spans = [];

    int currentIndex = 0;
    int segmentIndex = 0;

    for (final match in regex.allMatches(widget.text)) {
      // Add text before the match
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: widget.text.substring(currentIndex, match.start),
          style: widget.style ?? const TextStyle(color: Colors.black),
        ));
      }

      // The redacted content (without brackets)
      final content = match.group(1) ?? "";
      final thisSegmentIndex = segmentIndex++;
      final isRevealed = _revealedSegments[thisSegmentIndex] ?? false;

      // Add the redacted block
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _revealedSegments[thisSegmentIndex] = !isRevealed;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isRevealed ? Colors.transparent : Colors.black,
              border:
                  isRevealed ? Border.all(color: Colors.red, width: 2) : null,
            ),
            child: Text(
              content,
              style: (widget.style ?? const TextStyle(color: Colors.black))
                  .copyWith(
                color: isRevealed ? Colors.red : Colors.transparent,
                fontWeight: isRevealed ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'Courier', // Glitchy look
              ),
            ),
          ),
        ),
      ));

      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < widget.text.length) {
      spans.add(TextSpan(
        text: widget.text.substring(currentIndex),
        style: widget.style ?? const TextStyle(color: Colors.black),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

class BibliographyCard extends StatelessWidget {
  final String title;
  final String content;

  const BibliographyCard({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 16, color: Colors.grey),
          ...lines.map((line) {
            String cleanLine = line.trim().replaceAll(RegExp(r'^[-•]\s*'), '');
            // Optional: Basic link detection styling (not clickable yet)
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Expanded(
                    child: Text(
                      cleanLine,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
