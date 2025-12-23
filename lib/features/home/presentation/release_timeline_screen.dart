import 'package:cloud_firestore/cloud_firestore.dart';
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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _profileService.getProfileStream(),
        builder: (context, snapshot) {
          List<String> completedModules = [];
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data()!;
            completedModules =
                List<String>.from(data['completed_modules'] ?? []);
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 360,
                toolbarHeight: 120,
                collapsedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.zero,
                  title: LayoutBuilder(builder: (context, constraints) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          bottom: 16, left: 24, right: 24),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.5)),
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
                          ),
                          const SizedBox(width: 16),
                          Image.asset(
                            'assets/mascot/bung_warga_thinking.png',
                            height: 100,
                            fit: BoxFit.contain,
                          )
                              .animate()
                              .scale(
                                  duration: 600.ms,
                                  curve: Curves.elasticOut,
                                  delay: 300.ms)
                              .shimmer(delay: 2000.ms, duration: 1500.ms),
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
                                !widget.release.coverImage
                                    .contains('placehold.co'))
                            ? Image.network(
                                widget.release.coverImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                      ),
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

                      final isCompleted = completedModules.contains(sub.id);
                      // Determine if unlocked: first one is always unlocked,
                      // or if previous one is completed.
                      bool isUnlocked = index == 0;
                      if (index > 0) {
                        final prevId = subModules[index - 1].id;
                        isUnlocked = completedModules.contains(prevId);
                      }

                      // Optional: If you want to allow clicking any previous one even if not sequential, logic varies.
                      // But for gamified "Levels", usually sequential.
                      // For now let's stick to sequential Unlock.

                      return _TimelineNode(
                        subModule: sub,
                        isLeft: isLeft,
                        isFirst: index == 0,
                        isLast: index == subModules.length - 1,
                        isCompleted: isCompleted,
                        isUnlocked: isUnlocked,
                        onTap: () async {
                          if (!isUnlocked) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Selesaikan modul sebelumnya untuk membuka!")));
                            return;
                          }

                          if (sub.type == 'redacted_doc') {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RedactedDocScreen(subModule: sub),
                              ),
                            );
                          } else {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatStreamScreen(
                                  subModule: sub,
                                  releaseId: widget.release.id,
                                ),
                              ),
                            );
                          }
                          // No need to setState as StreamBuilder handles updates
                        },
                      ).animate().fade(duration: 500.ms).slideX(
                          begin: isLeft ? -0.1 : 0.1,
                          end: 0,
                          delay: (100 * index).ms);
                    },
                    childCount: subModules.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A237E), Color(0xFF311B92), Color(0xFF000000)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Icon(Icons.history_edu,
                size: 250, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Center(
              child: Icon(Icons.auto_stories,
                  size: 64, color: Colors.white.withValues(alpha: 0.2))),
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  final SubModule subModule;
  final bool isLeft;
  final bool isFirst;
  final bool isLast;
  final bool isCompleted;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _TimelineNode({
    required this.subModule,
    required this.isLeft,
    required this.isFirst,
    required this.isLast,
    required this.isCompleted,
    required this.isUnlocked,
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
                  color: isUnlocked
                      ? Colors.indigo.shade100
                      : Colors.grey.shade300,
                  margin: EdgeInsets.only(
                      top: isFirst ? 30 : 0, bottom: isLast ? 30 : 0),
                )
                    .animate(target: isUnlocked ? 1 : 0)
                    .tint(color: Colors.indigo.shade100),

                // Dot
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green
                          : (isUnlocked ? Colors.indigo : Colors.grey),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4)
                      ]),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 10, color: Colors.white)
                      : (isUnlocked
                          ? null
                          : const Icon(Icons.lock,
                              size: 8, color: Colors.white)),
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
          color: isUnlocked
              ? (isCompleted ? const Color(0xFFF0FDF4) : Colors.white)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: isCompleted
              ? Border.all(color: Colors.green.shade200)
              : (isUnlocked ? null : Border.all(color: Colors.grey.shade300)),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Opacity(
          opacity: isUnlocked ? 1.0 : 0.6,
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
                  color: isCompleted
                      ? Colors.green.shade800
                      : (isUnlocked ? Colors.black87 : Colors.grey.shade600),
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.green.shade200,
                ),
                textAlign: isLeft ? TextAlign.right : TextAlign.left,
              ),
              const SizedBox(height: 8),
              if (isUnlocked && !isCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/badges/xp_star.png',
                          width: 12, height: 12),
                      const SizedBox(width: 4),
                      Text(
                        "+${subModule.xpReward} XP",
                        style: TextStyle(
                            color: Colors.orange.shade900,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
