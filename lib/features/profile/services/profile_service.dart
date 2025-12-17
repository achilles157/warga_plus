import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/models/release_model.dart';
import 'package:flutter/foundation.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Logic from GelarKarakter.csv
  final Map<String, String> _archetypes = {
    'history': 'Sang Pengingat',
    'law_policy': 'Warga Legislatif',
    'human_rights': 'Diplomat Jalanan',
    'economy_oligarchy': 'Pemburu Oligarki',
    'environment': 'Penjaga Bumi',
    'critical_thinking': 'Agen Bawah Tanah',
  };

  final String _defaultArchetype = 'Warga Sipil';

  // --- Firestore Logic ---

  Future<void> checkIn() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDocRef = _firestore.collection('users').doc(user.uid);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      final doc = await userDocRef.get();

      if (!doc.exists) {
        // First time user, create doc
        await userDocRef.set({
          'last_login': now.toIso8601String(),
          'current_streak': 1,
          'total_xp': 0,
          'completed_modules': [],
          'tag_scores': {},
        });
        return;
      }

      final data = doc.data() as Map<String, dynamic>;
      final lastLoginStr = data['last_login'] as String?;
      int currentStreak = data['current_streak'] as int? ?? 0;

      if (lastLoginStr != null) {
        final lastLogin = DateTime.parse(lastLoginStr);
        final lastDate =
            DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
        final difference = today.difference(lastDate).inDays;

        if (difference == 1) {
          currentStreak++;
        } else if (difference > 1) {
          currentStreak = 1;
        }
        // If 0, same day, do nothing
      } else {
        currentStreak = 1;
      }

      await userDocRef.update({
        'last_login': now.toIso8601String(),
        'current_streak': currentStreak,
      });
    } catch (e) {
      debugPrint("Error checking in: $e");
    }
  }

  // Returns a stream of the user document for real-time UI
  Stream<DocumentSnapshot<Map<String, dynamic>>> getProfileStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  // Helper to calculate total XP from snapshot or fetch
  Future<int> getTotalXp() async {
    final user = _auth.currentUser;
    if (user == null) return 0;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return (doc.data()?['total_xp'] as int?) ?? 0;
  }

  // Check completion
  Future<bool> isModuleCompleted(String id) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    // NOTE: For better performance in lists, usage of Stream in parent widget is recommended.
    // This fetch is okay for sporadic checks.
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final completed = List<String>.from(doc.data()?['completed_modules'] ?? []);
    return completed.contains(id);
  }

  Future<void> completeModule(SubModule module) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDocRef = _firestore.collection('users').doc(user.uid);

    try {
      // Use transaction to ensure atomic updates (read-modify-write)
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);

        if (!snapshot.exists) {
          // If doc doesn't exist (edge case), create it
          transaction.set(userDocRef, {
            'completed_modules': [module.id],
            'total_xp': module.xpReward,
            'tag_scores': _buildTagScores({}, module.specificTags),
            // Assuming checkIn might handle streak/login_date, but let's init defaults if missing
            'current_streak': 1,
            'last_login': DateTime.now().toIso8601String(),
          });
          return;
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final completed = List<String>.from(data['completed_modules'] ?? []);

        final alreadyCompleted = completed.contains(module.id);
        final currentXp = (data['total_xp'] as int?) ?? 0;

        // Self-healing: If it matches 'already completed' but total_xp is 0, we assume it was a glitch and award XP.
        if (!alreadyCompleted ||
            (alreadyCompleted && currentXp == 0 && module.xpReward > 0)) {
          if (!alreadyCompleted) completed.add(module.id);

          final newXp = currentXp + module.xpReward;

          final currentTags =
              Map<String, dynamic>.from(data['tag_scores'] ?? {});
          final newTags = _buildTagScores(currentTags, module.specificTags);

          transaction.update(userDocRef, {
            'completed_modules': completed,
            'total_xp': newXp,
            'tag_scores': newTags,
          });
          debugPrint(
              "Module completed. Updated XP: $newXp. Tags: ${newTags.keys}");
        } else {
          debugPrint("Module already completed and XP seems valid. Skipping.");
        }
      });
    } catch (e) {
      debugPrint("Error completing module: $e");
    }
  }

  Map<String, dynamic> _buildTagScores(
      Map<String, dynamic> currentScores, List<String>? newTags) {
    if (newTags == null) return currentScores;
    for (var tag in newTags) {
      final currentObj = currentScores[tag];
      int score = 0;
      if (currentObj is int) {
        // Handle potential legacy or different types
        score = currentObj;
      }
      currentScores[tag] = score + 1;
    }
    return currentScores;
  }

  // Now synchronous helper, usually called with data from Stream
  String calculateArchetype(Map<String, dynamic>? tagScores) {
    if (tagScores == null || tagScores.isEmpty) return _defaultArchetype;

    String dominator = '';
    int maxScore = 0;

    for (var entry in tagScores.entries) {
      // Match against known archetypes to be sure
      // Or just take the highest tag if we map it later?
      // GelarKarakter.csv maps specific tags.
      if (_archetypes.containsKey(entry.key)) {
        final score = entry.value as int? ?? 0;
        if (score > maxScore) {
          maxScore = score;
          dominator = entry.key;
        }
      }
    }

    if (maxScore == 0) return _defaultArchetype;
    return _archetypes[dominator] ?? _defaultArchetype;
  }

  String getArchetypeDescription(String archetypeTitle) {
    switch (archetypeTitle) {
      case 'Sang Pengingat':
        return "Melawan lupa adalah tugasmu. Kamu hafal dosa masa lalu negara lebih baik dari buku sejarah sekolah.";
      case 'Warga Legislatif':
        return "Pasal-pasal karet gak mempan buat kamu. Kamu paham aturan main negara layaknya pengacara pro-bono.";
      case 'Diplomat Jalanan':
        return "Suara bagi yang tak bersuara. Kamu berdiri paling depan kalau ada ketidakadilan kemanusiaan.";
      case 'Pemburu Oligarki':
        return "Kamu tahu ke mana larinya uang pajak. Musuh bebuyutan para tikus berdasi dan penguasa lahan.";
      case 'Penjaga Bumi':
        return "Bukan sekadar peduli plastik. Kamu paham krisis iklim adalah krisis politik.";
      case 'Agen Bawah Tanah':
        return "Skeptis, tajam, dan berbahaya. Kamu selalu mempertanyakan 'Kebenaran' versi pemerintah.";
      case 'Warga Sipil':
        return "Warga negara yang baik. Mulai perjalananmu untuk menemukan peran aslimu di republik ini.";
      default:
        return "Warga negara yang baik.";
    }
  }
}
