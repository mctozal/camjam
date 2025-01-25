import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadService {
  // Future<void> uploadPhoto(File photo, String playerId) async {
  //   final storageRef =
  //       FirebaseStorage.instance.ref().child('photos/$playerId.jpg');
  //   await storageRef.putFile(photo);

  //   final downloadUrl = await storageRef.getDownloadURL();
  //   // Update Firestore with the photo URL
  //   FirebaseFirestore.instance.collection('players').doc(playerId).update({
  //     'photoPath': downloadUrl,
  //   });
  // }
}
