import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, String>>> listenToPictures(
      String gameCode, int roundNumber) {
    return _firestore
        .collection('games') // Collection of games
        .doc(gameCode) // Specific game
        .collection('photos') // Collection of photos for this game
        .where('round',
            isEqualTo: roundNumber) // Only get photos for the current round
        .snapshots() // Listen for real-time updates
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'url': data['url'] as String, // Extract URL
                'uploadedBy':
                    data['uploadedBy'] as String, // Extract uploader ID
              };
            }).toList());
  }
}
