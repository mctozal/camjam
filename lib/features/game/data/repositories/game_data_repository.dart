import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GameDataRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getRandomPov() async {
    try {
      final doc = await _firestore
          .collection('povs')
          .doc('pov') // Ensure correct document ID
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          // Access the values as a list
          final texts = List<String>.from(data.values);
          if (texts.isNotEmpty) {
            texts.shuffle();
            return texts.first; // Return a random pose
          }
        }
      }
      return 'No poses available';
    } catch (e) {
      debugPrint('Error fetching poses: $e');
      return 'Error fetching poses';
    }
  }
}
