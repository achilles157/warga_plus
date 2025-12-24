import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/services/auth_service.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Identitas Warga'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _profileService.getProfileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildProfileContent(
              xp: 0,
              streak: 1,
              archetype: 'The Citizen',
              desc: _profileService.getArchetypeDescription('The Citizen'),
            );
          }

          final data = snapshot.data!.data()!;
          final xp = (data['total_xp'] as int?) ?? 0;
          final streak = (data['current_streak'] as int?) ?? 0;
          final tagScores = data['tag_scores'] as Map<String, dynamic>?;

          final archetype = _profileService.calculateArchetype(tagScores);
          final desc = _profileService.getArchetypeDescription(archetype);

          return _buildProfileContent(
            xp: xp,
            streak: streak,
            archetype: archetype,
            desc: desc,
          );
        },
      ),
    );
  }

  Widget _buildProfileContent({
    required int xp,
    required int streak,
    required String archetype,
    required String desc,
  }) {
    // Level Logic: Every 1000 XP is a level
    final int level = (xp / 1000).floor() + 1;
    final int currentLevelXp = xp % 1000;
    final double progress = currentLevelXp / 1000.0;
    final int xpToNext = 1000 - currentLevelXp;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 24),
      child: Column(
        children: [
          // STREAK BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  "$streak Day Streak",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
              ],
            ),
          ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),

          const SizedBox(height: 32),

          // IDENTITY CARD (KTP GAYA BARU)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                )
              ],
            ),
            child: Stack(
              children: [
                // Background Pattern / Noise
                Positioned(
                  right: -50,
                  top: -50,
                  child: Icon(
                    Icons.fingerprint,
                    size: 300,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/badges/xp_star.png',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "REPUBLIK DATA WARGA",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "LVL $level",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Main Badge & Role
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    )
                                  ]),
                              child: Image.asset(
                                _getBadgeAsset(archetype),
                                fit: BoxFit.contain,
                              ),
                            )
                                .animate()
                                .scale(
                                    duration: 600.ms, curve: Curves.easeOutBack)
                                .shimmer(delay: 1000.ms, duration: 1500.ms),
                            const SizedBox(height: 16),
                            Text(
                              archetype.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 300.ms)
                                .slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "ID: 2024-WP-${xp.toString().padLeft(6, '0')}",
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontFamily: 'Courier', // Monospace font
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Progress Bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "PROGRESS",
                                style: TextStyle(
                                  color: Colors.blue.shade100,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "$xpToNext XP ke Level ${level + 1}",
                                style: TextStyle(
                                  color: Colors.blue.shade100,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor:
                                  Colors.black.withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFFFFD700)), // Gold
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().slideY(
              begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),

          const SizedBox(height: 32),

          // Description Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      "DESKRIPSI PERAN",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 40),

          if (context.watch<AuthService>().isAdmin)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/admin');
                },
                icon: const Icon(Icons.admin_panel_settings, color: Colors.red),
                label: const Text(
                  "Admin Portal",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getBadgeAsset(String archetype) {
    switch (archetype) {
      case 'The Timekeeper':
        return 'assets/badges/historian_badge.png';
      case 'The Citizen':
        return 'assets/badges/civilian_badge.png';
      case 'The Lawmaker':
        return 'assets/badges/lawmaker_badge.png';
      case 'Street Diplomat':
        return 'assets/badges/diplomat_badge.png';
      case 'Oligarch Hunter':
        return 'assets/badges/oligarch_hunter_badge.png';
      case 'Earth Guardian':
        return 'assets/badges/earth_guardian_badge.png';
      case 'Underground Agent':
        return 'assets/badges/underground_agent_badge.png';
      case 'The Strategist':
        return 'assets/badges/badge_politics.png';
      case 'The Scholar':
        return 'assets/badges/badge_academic.png';
      case 'The Statesman':
        return 'assets/badges/badge_statesman.png';
      default:
        return 'assets/badges/civilian_badge.png'; // Fallback to citizen instead of activist
    }
  }
}
