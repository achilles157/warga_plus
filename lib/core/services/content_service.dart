import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/release_model.dart';

class ContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _releasesCollection =>
      _firestore.collection('releases');

  /// Import a Release from JSON data.
  /// Validates the structure by trying to parse it into a Release object first,
  /// then writes it to Firestore using the release_id as the document ID.
  Future<void> importRelease(Map<String, dynamic> json) async {
    try {
      // 1. Validate by parsing
      final release = Release.fromJson(json);

      // 2. Write to Firestore
      // We use set() with SetOptions(merge: true) or just set() to overwrite/create.
      // Masterplan implies 'release_id' is the unique key.
      await _releasesCollection.doc(release.id).set(release.toJson());

      debugPrint('Successfully imported release: ${release.id}');
    } catch (e) {
      debugPrint('Error parsing or importing release: $e');
      throw Exception('Failed to import release: $e');
    }
  }

  /// Add or update Sub-Modules for an existing Release.
  /// [releaseId]: The ID of the Release document to update.
  /// [jsonPayload]: Can be a List (multiple sub-modules) or Map (single sub-module).
  Future<void> addSubModules(String releaseId, dynamic jsonPayload) async {
    try {
      List<SubModule> newSubModules = [];

      // 1. Parse payload
      if (jsonPayload is List) {
        newSubModules = jsonPayload
            .map((e) => SubModule.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (jsonPayload is Map<String, dynamic>) {
        newSubModules = [SubModule.fromJson(jsonPayload)];
      } else {
        throw const FormatException(
            'Payload must be a JSON Object (Map) or Array (List).');
      }

      final docRef = _releasesCollection.doc(releaseId);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        throw Exception(
            'Release with ID "$releaseId" not found. Import the base release first.');
      }

      // 2. Fetch existing sub-modules
      final data = docSnap.data() as Map<String, dynamic>;
      List<dynamic> existingList = data['sub_modules'] ?? [];

      // 3. Merge logic: Overwrite if ID matches, otherwise append
      for (var newMod in newSubModules) {
        int index =
            existingList.indexWhere((element) => element['id'] == newMod.id);
        if (index != -1) {
          // Update existing
          existingList[index] = newMod.toJson();
        } else {
          // Append new
          existingList.add(newMod.toJson());
        }
      }

      // 4. Update Firestore
      await docRef.update({'sub_modules': existingList});

      debugPrint(
          'Successfully added/updated ${newSubModules.length} sub-modules for release: $releaseId');
    } catch (e) {
      debugPrint('Error adding sub-modules: $e');
      throw Exception('Failed to add sub-modules: $e');
    }
  }

  /// Fetch all releases (for debugging/verification mostly)
  Future<List<Release>> getAllReleases() async {
    try {
      final snapshot = await _releasesCollection.get();
      return snapshot.docs.map((doc) {
        return Release.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching releases: $e');
      rethrow;
    }
  }

  /// Update AI Context for a specific Sub-Module (Granular RAG Update)
  /// Expects: { "release_id": "...", "sub_module_id": "...", "ai_context": "..." }
  Future<void> updateSubModuleContext(Map<String, dynamic> json) async {
    try {
      final releaseId = json['release_id'];
      final subModuleId = json['sub_module_id'];
      final aiContext = json['ai_context'];

      if (releaseId == null || subModuleId == null || aiContext == null) {
        throw const FormatException(
            'Missing release_id, sub_module_id, or ai_context');
      }

      final docRef = _releasesCollection.doc(releaseId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception('Release $releaseId not found');
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final List<dynamic> subModules = List.from(data['sub_modules'] ?? []);

        final index = subModules.indexWhere((m) => m['id'] == subModuleId);

        if (index == -1) {
          throw Exception(
              'SubModule $subModuleId not found in release $releaseId');
        }

        // Update the specific sub-module's context
        final modMap = Map<String, dynamic>.from(subModules[index] as Map);
        modMap['ai_context'] = aiContext;
        subModules[index] = modMap;

        transaction.update(docRef, {'sub_modules': subModules});
      });

      debugPrint('Successfully updated context for $subModuleId in $releaseId');
    } catch (e) {
      debugPrint('Error updating submodule context: $e');
      throw Exception('Failed to update context: $e');
    }
  }
}
