import 'package:camjam/core/models/User.dart';
import 'package:camjam/core/utils/hash_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getUserHashId() async {
    final String hashId = await HashService.getOrCreateUserHash();
    return hashId;
  }

  Future<User?> getCurrentUser() async {
    try {
      // Get the user document from Firestore by their hashId
      String? currentUserId = await getUserHashId();

      final docSnapshot =
          await _firestore.collection('users').doc(currentUserId).get();

      // Check if the document exists
      if (docSnapshot.exists) {
        // If the user is found, convert the document data into a User object
        return User.fromMap(docSnapshot.data()!);
      } else {
        // Return null if the user is not found
        return null;
      }
    } catch (e) {
      throw Exception('Error finding user: $e');
    }
  }

  Future<void> addUser(User user) async {
    try {
      // Get or create the unique user hash
      final String hashId = await HashService.getOrCreateUserHash();

      user.id = hashId;
      // Add user data to Firestore with the hash ID
      await _firestore.collection('users').doc(hashId).set(user.toMap());
    } catch (e) {
      throw Exception('Error adding user to Firestore: $e');
    }
  }

  Future<void> updateUserField(String field, dynamic value) async {
    try {
      // Get the current user's hash ID
      final String currentUserId = await getUserHashId();

      // Update only the specified field
      await _firestore.collection('users').doc(currentUserId).update({
        field: value,
      });
    } catch (e) {
      throw Exception('Error updating user field in Firestore: $e');
    }
  }
}
