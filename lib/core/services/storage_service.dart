import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  /// Upload a photo to Firebase Storage and get the download URL
  Future<String> uploadPhoto(
      File file, String folderPath, String fileName) async {
    try {
      // Create a reference to the file location in Storage
      final storageRef = _firebaseStorage.ref('$folderPath/$fileName');

      // Upload the file
      await storageRef.putFile(file);

      // Get the download URL
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading photo: $e');
    }
  }

  Future<void> deletePhoto(String filePath) async {
    try {
      final storageRef = FirebaseStorage.instance.ref(filePath);
      await storageRef.delete();
      print('Photo deleted successfully.');
    } catch (e) {
      throw Exception('Error deleting photo: $e');
    }
    //usage await deletePhoto('games/$gameCode/players/$playerId/photos/profile_picture.jpg');
  }
}
