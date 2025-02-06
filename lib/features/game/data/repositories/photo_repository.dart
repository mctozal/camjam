import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> listenToPictures(String gameCode) {
    return _firestore
        .collection('games')
        .doc(gameCode)
        .collection('photos')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'url': data['url'] ?? '',
          'uploadedBy': data['uploadedBy'] ?? '',
        };
      }).toList();
    });
  }

  Future<void> savePhotoToFirestore(String photoUrl, String gameCode,
      String roundNumber, String playerId) async {
    try {
      await _firestore
          .collection('games')
          .doc(gameCode)
          .collection('photos') // Store in a subcollection
          .add({
        'url': photoUrl,
        'uploadedBy': playerId,
        'timestamp': FieldValue.serverTimestamp(),
        'round': roundNumber
      });

      print('Photo successfully added.');
    } catch (e) {}
  }
}
