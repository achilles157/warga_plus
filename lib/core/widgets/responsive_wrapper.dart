import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A wrapper that constrains the app content to a mobile-like width on large screens (Web/Desktop).
/// This ensures the mobile-first design remains aesthetic and usable on desktop.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Only apply constraint on Web or Desktop platforms
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return Container(
        color: const Color(
            0xFFF0F2F5), // Light grey background like generic web apps
        alignment: Alignment.center,
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 480, // Max width for mobile-like experience
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
            // Optional: Add rounded corners if you want it to look like a floating phone
            // borderRadius: BorderRadius.circular(16),
            child: child,
          ),
        ),
      );
    }

    // On actual mobile devices, just return the child
    return child;
  }
}
