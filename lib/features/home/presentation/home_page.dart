import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/content_service.dart';
import '../../../../core/models/release_model.dart';
import 'release_timeline_screen.dart';
import '../../../../core/services/temp_seeder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ContentService _contentService = ContentService();
  late Future<List<Release>> _releasesFuture;

  @override
  void initState() {
    super.initState();
    // Initialize immediately to prevent LateInitializationError
    // We chain the seeding process with the fetching process
    _releasesFuture = TempSeeder.seed().then((_) {
      return _contentService.getAllReleases();
    });
  }

  void _refresh() {
    setState(() {
      _releasesFuture = _contentService.getAllReleases();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text("Pustaka Rilisan"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthService>().signOut(),
          ),
        ],
      ),
      body: FutureBuilder<List<Release>>(
        future: _releasesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada rilisan."));
          }

          final releases = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Taller cards for covers
            ),
            itemCount: releases.length,
            itemBuilder: (context, index) {
              final release = releases[index];
              return _ReleaseCard(
                release: release,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReleaseTimelineScreen(release: release),
                    ),
                  );
                },
              )
                  .animate()
                  .fade(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, delay: (50 * index).ms);
            },
          );
        },
      ),
    );
  }
}

class _ReleaseCard extends StatelessWidget {
  final Release release;
  final VoidCallback onTap;

  const _ReleaseCard({required this.release, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'release_cover_${release.id}', // Hero Tag
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: (release.coverImage.isNotEmpty &&
                          release.coverImage.startsWith('http') &&
                          !release.coverImage.contains('placehold.co'))
                      ? Image.network(
                          release.coverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
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
                                  right: -20,
                                  top: -20,
                                  child: Icon(
                                    Icons.history_edu,
                                    size: 100,
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                Center(
                                  child: Icon(
                                    Icons.auto_stories,
                                    size: 32,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                                right: -20,
                                top: -20,
                                child: Icon(
                                  Icons.history_edu,
                                  size: 100,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              Center(
                                child: Icon(
                                  Icons.auto_stories,
                                  size: 32,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    release.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${release.subModules.length} Chapters",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
