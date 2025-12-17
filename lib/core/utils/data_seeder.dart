import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DataSeeder {
  static Future<void> uploadVerticalSliceData(BuildContext context) async {
    try {
      // 1. Load JSON
      final String jsonString =
          await rootBundle.loadString('assets/data/vertical_slice_data.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      // 2. Upload to Firestore
      // Using 'modules' collection. Ensure this matches what the app expects if it reads from Firestore.
      // Currently the app reads from JSON locally, but this is for future/backend Setup.
      final String moduleId = data['module_id'];

      await FirebaseFirestore.instance
          .collection('modules')
          .doc(moduleId)
          .set(data);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Data uploaded successfully to Firestore!')),
        );
      }
    } catch (e) {
      debugPrint('Error uploading data: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
