import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HashService {
  /// Generates a random SHA-256 hash
  static String generateRandomHash() {
    final random = Random.secure();
    final randomBytes =
        List<int>.generate(16, (_) => random.nextInt(256)); // 16 bytes
    final hash = sha256.convert(randomBytes);
    return hash.toString();
  }

  /// Stores the hash locally using SharedPreferences
  static Future<void> storeHashLocally(String hashId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userHashId', hashId);
  }

  /// Retrieves the hash from local storage
  static Future<String?> getHashFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userHashId');
  }

  /// Ensures a user hash exists (creates one if not found)
  static Future<String> getOrCreateUserHash() async {
    String? hashId = await getHashFromLocalStorage();
    if (hashId == null) {
      hashId = generateRandomHash();
      await storeHashLocally(hashId);
    }
    return hashId;
  }
}
