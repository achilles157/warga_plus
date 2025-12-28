import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A wrapper that constrains the app content to a mobile-like width on large screens (Web/Desktop).
/// This ensures the mobile-first design remains aesthetic and usable on desktop.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to get actual screen width
    return LayoutBuilder(
      builder: (context, constraints) {
        // Only apply mobile-like constraints on WIDE screens (desktop/tablet)
        // This prevents the wrapper from affecting narrow screens (mobile web)
        final bool isWideScreen = constraints.maxWidth > 600;

        if (isWideScreen &&
            (kIsWeb ||
                defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.linux ||
                defaultTargetPlatform == TargetPlatform.macOS)) {
          return Container(
            color: const Color(0xFFF0F2F5),
            alignment: Alignment.center,
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                child: child,
              ),
            ),
          );
        }

        // On narrow screens (mobile web, actual mobile), just return the child
        return child;
      },
    );
  }
}
