import 'package:camjam/core/services/firestore_service.dart';

class GameRepository {
  final FirestoreService _firestoreService;

  GameRepository(this._firestoreService);

  Future<void> createGame(String gameCode, Map<String, dynamic> gameData) {
    return _firestoreService.createGame(gameCode, gameData);
  }

  Stream<Map<String, dynamic>> listenToGame(String gameCode) {
    return _firestoreService.listenToGame(gameCode).map((snapshot) {
      return snapshot.data()!;
    });
  }

  Future<void> updateGame(String gameCode, Map<String, dynamic> updates) {
    return _firestoreService.updateGame(gameCode, updates);
  }
}
