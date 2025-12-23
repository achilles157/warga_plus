import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/models/release_model.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Logic from GelarKarakter.csv
  final Map<String, String> _archetypes = {
    'history': 'The Timekeeper',
    'law_policy': 'The Lawmaker',
    'human_rights': 'Street Diplomat',
    'economy_oligarchy': 'Oligarch Hunter',
    'environment': 'Earth Guardian',
    'critical_thinking': 'Underground Agent',
  };

  final String _defaultArchetype = 'The Citizen';

  // ... (Firestore Logic remains same) ...

  // Returns a stream of the user document for real-time UI
  Stream<DocumentSnapshot<Map<String, dynamic>>> getProfileStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  // Perform daily check-in logic
  Future<void> checkIn() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    final userData = await userRef.get();

    if (!userData.exists) return;

    final data = userData.data();
    final lastActive = (data?['last_active'] as Timestamp?)?.toDate();
    final now = DateTime.now();

    // Check if last active was yesterday to increment streak
    if (lastActive != null) {
      final difference = now.difference(lastActive).inDays;
      if (difference == 1) {
        // Increment streak
        await userRef.update({
          'streak': FieldValue.increment(1),
          'last_active': FieldValue.serverTimestamp(),
        });
      } else if (difference > 1) {
        // Reset streak
        await userRef.update({
          'streak': 1,
          'last_active': FieldValue.serverTimestamp(),
        });
      } else {
        // Same day, just update last active
        await userRef.update({
          'last_active': FieldValue.serverTimestamp(),
        });
      }
    } else {
      // First time check-in
      await userRef.update({
        'streak': 1,
        'last_active': FieldValue.serverTimestamp(),
      });
    }
  }

  // Complete a module: Award XP once, but accumulate tags always for repeat reading
  Future<void> completeModule(SubModule subModule) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);

        if (!snapshot.exists) return; // Should not happen for active user

        final data = snapshot.data() as Map<String, dynamic>;
        final completedModules =
            List<String>.from(data['completed_modules'] ?? []);
        final currentTags = Map<String, dynamic>.from(data['tag_scores'] ?? {});

        final bool isFirstTime = !completedModules.contains(subModule.id);

        // 1. Calculate XP (Only if first time)
        int xpIncrement = 0;
        if (isFirstTime) {
          xpIncrement = subModule.xpReward;
          completedModules.add(subModule.id);
        }

        // 2. Calculate Tags (Always accumulate)
        if (subModule.specificTags != null) {
          for (var tag in subModule.specificTags!) {
            final currentScore = (currentTags[tag] as int?) ?? 0;
            currentTags[tag] = currentScore + 1;
          }
        }

        // 3. Update User Doc
        final updates = <String, dynamic>{
          'tag_scores': currentTags,
          if (isFirstTime) 'completed_modules': completedModules,
          if (xpIncrement > 0) 'total_xp': FieldValue.increment(xpIncrement),
        };

        transaction.update(userRef, updates);

        debugPrint(
            "Module ${subModule.id} completed. XP Awarded: $xpIncrement. Tags Updated.");
      });
    } catch (e) {
      debugPrint("Error completing module: $e");
    }
  }

  String calculateArchetype(Map<String, dynamic>? tagScores) {
    if (tagScores == null || tagScores.isEmpty) return _defaultArchetype;

    String dominator = '';
    int maxScore = 0;

    for (var entry in tagScores.entries) {
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
      case 'The Timekeeper':
        return "Melawan lupa adalah tugasmu. Kamu hafal dosa masa lalu negara lebih baik dari buku sejarah sekolah.";
      case 'The Lawmaker':
        return "Pasal-pasal karet gak mempan buat kamu. Kamu paham aturan main negara layaknya pengacara pro-bono.";
      case 'Street Diplomat':
        return "Suara bagi yang tak bersuara. Kamu berdiri paling depan kalau ada ketidakadilan kemanusiaan.";
      case 'Oligarch Hunter':
        return "Kamu tahu ke mana larinya uang pajak. Musuh bebuyutan para tikus berdasi dan penguasa lahan.";
      case 'Earth Guardian':
        return "Bukan sekadar peduli plastik. Kamu paham krisis iklim adalah krisis politik.";
      case 'Underground Agent':
        return "Skeptis, tajam, dan berbahaya. Kamu selalu mempertanyakan 'Kebenaran' versi pemerintah.";
      case 'The Citizen':
        return "Warga negara yang baik. Mulai perjalananmu untuk menemukan peran aslimu di republik ini.";
      default:
        return "Warga negara yang baik.";
    }
  }
}
