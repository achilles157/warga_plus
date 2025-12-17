import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/models/release_model.dart';
import '../../profile/services/profile_service.dart';
import '../../reader/screens/chat_stream_screen.dart';
import '../../reader/screens/redacted_doc_screen.dart';

class ReleaseTimelineScreen extends StatefulWidget {
  final Release release;

  const ReleaseTimelineScreen({super.key, required this.release});

  @override
  State<ReleaseTimelineScreen> createState() => _ReleaseTimelineScreenState();
}

class _ReleaseTimelineScreenState extends State<ReleaseTimelineScreen> {
  final ProfileService _profileService = ProfileService();

  @override
  Widget build(BuildContext context) {
    final subModules = widget.release.subModules;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360, // Increased further for layout breathing room
            toolbarHeight: 120, // Make the pinned header significantly larger
            collapsedHeight: 120, // Ensure it stays this size when collapsed
            floating: false,
            pinned: true,
            backgroundColor: const Color(
                0xFF1A237E), // Deep Indigo for contrast when collapsed
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              // Move title content logic slightly to ensure it doesn't conflict with system elements or overflow
              title: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.only(bottom: 16, left: 24, right: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.9),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Subtitle/Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5)),
                        ),
                        child: const Text(
                          "SEJARAH KRITIS",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.release.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ).animate().fade().slideY(begin: 0.2, end: 0),
                    ],
                  ),
                );
              }),
              centerTitle: false,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'release_cover_${widget.release.id}',
                    child: (widget.release.coverImage.isNotEmpty &&
                            widget.release.coverImage.startsWith('http') &&
                            !widget.release.coverImage.contains('placehold.co'))
                        ? Image.network(
                            widget.release.coverImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF1A237E),
                                        Color(0xFF311B92),
                                        Color(0xFF000000)
                                      ]),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      right: -50,
                                      top: -50,
                                      child: Icon(Icons.history_edu,
                                          size: 250,
                                          color: Colors.white
                                              .withValues(alpha: 0.05)),
                                    ),
                                    Center(
                                        child: Icon(Icons.auto_stories,
                                            size: 64,
                                            color: Colors.white
                                                .withValues(alpha: 0.2))),
                                  ],
                                ),
                              );
                            },
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF1A237E), // Deep Indigo
                                  Color(0xFF311B92), // Deep Purple
                                  Color(0xFF000000), // Black
                                ],
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -50,
                                  top: -50,
                                  child: Icon(
                                    Icons.history_edu,
                                    size: 250,
                                    color: Colors.white.withValues(alpha: 0.05),
                                  ),
                                ),
                                Center(
                                  child: Icon(
                                    Icons.auto_stories,
                                    size: 64,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  // Additional gradient for readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final sub = subModules[index];
                  final isLeft = index.isEven;

                  return FutureBuilder<bool>(
                    future: _profileService.isModuleCompleted(sub.id),
                    builder: (context, completionSnap) {
                      final isCompleted = completionSnap.data ?? false;

                      return _TimelineNode(
                        subModule: sub,
                        isLeft: isLeft,
                        isFirst: index == 0,
                        isLast: index == subModules.length - 1,
                        isCompleted: isCompleted,
                        onTap: () async {
                          if (sub.type == 'redacted_doc') {
                            await Navigator.push(
                              context,
                              materialPageRoute(
                                builder: (_) =>
                                    RedactedDocScreen(subModule: sub),
                              ),
                            );
                          } else {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ChatStreamScreen(subModule: sub),
                              ),
                            );
                          }
                          setState(() {});
                        },
                      ).animate().fade(duration: 500.ms).slideX(
                          begin: isLeft ? -0.1 : 0.1,
                          end: 0,
                          delay: (100 * index).ms);
                    },
                  );
                },
                childCount: subModules.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  MaterialPageRoute materialPageRoute(
      {required Widget Function(BuildContext) builder}) {
    return MaterialPageRoute(builder: builder);
  }
}

class _TimelineNode extends StatelessWidget {
  final SubModule subModule;
  final bool isLeft;
  final bool isFirst;
  final bool isLast;
  final bool isCompleted;
  final VoidCallback onTap;

  const _TimelineNode({
    required this.subModule,
    required this.isLeft,
    required this.isFirst,
    required this.isLast,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Left Side
          Expanded(
            child: isLeft ? _buildCard(context) : const SizedBox(),
          ),
          // Center Line
          SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Line
                Container(
                  width: 4,
                  color: Colors.grey.shade300,
                  margin: EdgeInsets.only(
                      top: isFirst ? 30 : 0, bottom: isLast ? 30 : 0),
                ).animate().scaleY(
                    begin: 0,
                    end: 1,
                    duration: 600.ms,
                    curve: Curves.easeInOut),
                // Dot
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : Colors.indigo,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4)
                      ]),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 10, color: Colors.white)
                      : null,
                )
                    .animate(delay: 300.ms)
                    .scale(duration: 300.ms, curve: Curves.elasticOut),
              ],
            ),
          ),
          // Right Side
          Expanded(
            child: !isLeft ? _buildCard(context) : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isCompleted ? Border.all(color: Colors.green.shade200) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  isLeft ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text("CHAPTER",
                    style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
                if (subModule.type == 'redacted_doc')
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(Icons.visibility_off,
                        size: 12, color: Colors.grey[400]),
                  )
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subModule.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isCompleted ? Colors.green.shade800 : Colors.black87,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                decorationColor: Colors.green.shade200,
              ),
              textAlign: isLeft ? TextAlign.right : TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
