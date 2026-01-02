import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/release_model.dart';
import '../../profile/services/profile_service.dart';
import '../../reader/screens/chat_stream_screen.dart';
import '../../reader/screens/redacted_doc_screen.dart';
import 'widgets/timeline_node.dart';

class ReleaseTimelineScreen extends StatelessWidget {
  final Release release;

  const ReleaseTimelineScreen({super.key, required this.release});

  @override
  Widget build(BuildContext context) {
    final profileService = Provider.of<ProfileService>(context, listen: false);

    return Scaffold(
      backgroundColor:
          const Color(0xFF1E1E2C), // Dark Investigation Board Theme
      body: StreamBuilder(
        stream: profileService.getProfileStream(),
        builder: (context, snapshot) {
          final userData = snapshot.data?.data();
          final completedModules =
              List<String>.from(userData?['completed_modules'] ?? []);

          // Calculate Progress
          // Filter subModules that are actually readable/playable (if any constraint exists, otherwise all)
          final totalModules = release.subModules.length;
          final completedInRelease = release.subModules
              .where((m) => completedModules.contains(m.id))
              .length;
          final progressPercent =
              totalModules > 0 ? completedInRelease / totalModules : 0.0;
          final percentageString = (progressPercent * 100).toInt();

          return CustomScrollView(
            slivers: [
              // 1. Header with Cover
              // 1. Header with Cover
              // 1. Header with Cover
              // 1. Header with Cover
              SliverAppBar(
                expandedHeight: 220, // Compact but room for badge
                pinned: true,
                backgroundColor: const Color(0xFFF5F5F7),
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const BackButton(color: Colors.black),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(
                      left: 56, // Clear the back button when scrolled
                      bottom: 16,
                      right: 120), // Right padding avoids mascot
                  centerTitle: false,
                  expandedTitleScale: 1.5, // Bigger title when expanded
                  title: Text(
                    release.title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                      fontSize: 14, // Base size (scales to ~21 when expanded)
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2, // Allow 2 lines when expanded
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. Beautiful Gradient Background (No cover image dependency)
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFE8EAF6), // Light Indigo
                              Color(0xFFC5CAE9), // Slightly deeper
                              Color(0xFFF5F5F7), // Light grey at bottom
                            ],
                          ),
                        ),
                      ),

                      // 2. Decorative Pattern (Subtle)
                      Positioned(
                        right: -50,
                        top: -30,
                        child: Icon(
                          Icons.auto_stories,
                          size: 200,
                          color: Colors.black.withValues(alpha: 0.03),
                        ),
                      ),

                      // 3. Mascot (Bung Warga)
                      Positioned(
                        right: -10,
                        bottom: 0,
                        child: Image.asset(
                          'assets/mascot/bung_warga_thinking.png',
                          height: 130, // Smaller to fit compact header
                          fit: BoxFit.contain,
                        ).animate().slideX(
                            begin: 0.1,
                            duration: 600.ms,
                            curve: Curves.easeOutBack),
                      ),

                      // 4. Badge (Positioned above the scaling title)
                      Positioned(
                        left: 24,
                        bottom: 75, // Higher to avoid title overlap
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: const Text(
                            "RELEASE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),

                      // 5. Subtle Dark Transition at very bottom
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF1E1E2C).withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Thematic Progress Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "EVIDENCE COLLECTED",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontFamily:
                                  'Courier Prime', // Try monospace if available, else fallback
                              letterSpacing: 2,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$percentageString%",
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progressPercent,
                        backgroundColor: Colors.grey[800],
                        color: Colors.redAccent,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. The Board (Timeline)
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 60),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final subModule = release.subModules[index];
                      // Determine State
                      // Logic:
                      // - If index 0: Unlocked.
                      // - Else: Unlocked if previous is completed OR self is completed.
                      // - Locked if !Unlocked.

                      // Actually, 'completed_modules' is list of IDs.
                      // We can check if previous module ID is in completed_modules.
                      bool isUnlocked = false;
                      if (index == 0) {
                        isUnlocked = true;
                      } else {
                        final prevModule = release.subModules[index - 1];
                        if (completedModules.contains(prevModule.id)) {
                          isUnlocked = true;
                        }
                      }

                      // Also if self is completed (edge case where we allowed jump or dev testing), it's unlocked
                      if (completedModules.contains(subModule.id)) {
                        isUnlocked = true;
                      }

                      final isCompleted =
                          completedModules.contains(subModule.id);
                      final isLocked = !isUnlocked;

                      return _TimelineItem(
                        index: index,
                        totalCount: release.subModules.length,
                        child: TimelineNode(
                          subModule: subModule,
                          isLocked: isLocked,
                          isCompleted: isCompleted,
                          index: index,
                          onTap: () {
                            // Navigate
                            if (subModule.type == 'chat_stream') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatStreamScreen(
                                    subModule: subModule,
                                    releaseId: release.id,
                                  ),
                                ),
                              ).then((_) => profileService
                                  .checkIn()); // Refresh logic if needed
                            } else if (subModule.type == 'redacted_doc') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RedactedDocScreen(
                                    subModule: subModule,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                    childCount: release.subModules.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final int index;
  final int totalCount;
  final Widget child;

  const _TimelineItem({
    required this.index,
    required this.totalCount,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Layout: Zig-zag
    // Even: padding Left 32, Right Auto
    // Odd: padding Right 32, Left Auto

    final bool isEven = index % 2 == 0;
    final bool isLast = index == totalCount - 1;

    return SizedBox(
      height: 220, // Fixed height for cleaner lines
      child: Stack(
        children: [
          // The String (Paint)
          if (!isLast)
            Positioned.fill(
              child: CustomPaint(
                painter: StringPainter(
                  isStartLeft: isEven,
                ),
              ),
            ),

          // The Content
          Align(
            alignment:
                isEven ? const Alignment(-0.6, 0) : const Alignment(0.6, 0),
            child: child,
          ),
        ],
      ),
    );
  }
}

class StringPainter extends CustomPainter {
  final bool isStartLeft;

  StringPainter({required this.isStartLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE53935).withValues(alpha: 0.8) // Red String
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Coordinates
    // Anchor Point for current Item (Top Center of "Photo" roughly)
    // Item is centered vertically in the 220px slot.
    // Alignment(-0.6, 0) means horizontally at 20% (since -1 is 0, 1 is 100, range 2. -0.6 -> 0.4/2 = 0.2)
    // Wait, Alignment(x,y): x from -1 to 1. 0.0 is center.
    // -0.6 is left side. 0.6 is right side.

    final double startX = isStartLeft
        ? size.width * (0.5 + 0.5 * -0.6) // ~20% width
        : size.width * (0.5 + 0.5 * 0.6); // ~80% width

    final double startY = size.height * 0.5; // Center of current slot

    // End Point (Next Item)
    // Next item is Next Slot (which is physically below this stack, but we are painting inside THIS slot).
    // Wait, CustomPainter inside the stack only paints inside the stack's size.
    // If I want to paint to the "next" item, I have to paint DOWNWARDS out of bounds?
    // No, CustomPaint usually clips?
    // Actually, I can paint to (NextX, Size.height + NextY - offset).
    // Easier: Paint from Center of current to Center of Next.
    // Center of Next is at:
    // X: Oppposite side.
    // Y: size.height * 1.5 (since next slot is same height and below)

    final double endX = !isStartLeft
        ? size.width * (0.5 + 0.5 * -0.6)
        : size.width * (0.5 + 0.5 * 0.6);

    final double endY = size.height * 1.5;

    // We can simulate a "drooping" string or straight tight string.
    // Tight string for investigation board.

    // BUT: Painting outside bounds (Y > size.height) might be clipped by SliverList items?
    // SliverList items usually don't clip unless ClipRect is used.
    // Let's try. If it clips, I'll need a different approach (Overlay or rendering lines separately).

    // Alternative: Draw line from Top of this cell (coming from prev) to Center?
    // No, draw from Center to Bottom (towards next).
    // And Next item draws from Top (coming from prev) to Center?
    // That means two segments meeting at the boundary.
    // Boundary is size.height.
    // Midpoint between Center(i) and Center(i+1) is at Y=size.height.
    // X at boundary? Linear interpolation.
    // X_mid = (startX + endX) / 2.

    path.moveTo(startX, startY);
    path.lineTo(endX, endY);

    canvas.drawPath(path, paint);

    // Pin at start
    final pinPaint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(startX, startY - 50), 4,
        pinPaint); // Pin roughly where the photo top is
    // Hard to guess photo top from here.
    // I'll just draw the string from center to center for now.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
