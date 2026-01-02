import 'package:flutter/material.dart';

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
