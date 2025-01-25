import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Adds a user to the 'users' collection in Firestore.
  Future<void> addUser(Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').add(userData);
    } catch (e) {
      throw Exception('Error adding user to Firestore: $e');
    }
  }

  Future<void> createGame(
      String gameCode, Map<String, dynamic> gameData) async {
    await _firestore.collection('games').doc(gameCode).set(gameData);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToGame(String gameCode) {
    return _firestore.collection('games').doc(gameCode).snapshots();
  }

  Future<void> updateGame(String gameCode, Map<String, dynamic> updates) async {
    await _firestore.collection('games').doc(gameCode).update(updates);
  }
}
