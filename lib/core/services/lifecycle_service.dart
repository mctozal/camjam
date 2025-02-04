import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LifecycleService with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId;
  String? _gameCode;

  static final LifecycleService _instance = LifecycleService._internal();

  factory LifecycleService() {
    return _instance;
  }

  LifecycleService._internal();

  void initialize({required String userId, required String gameCode}) {
    _currentUserId = userId;
    _gameCode = gameCode;
    WidgetsBinding.instance.addObserver(this);
    _setUserActive();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _setUserInactive(); // User went to background or closed app
    } else if (state == AppLifecycleState.resumed) {
      _setUserActive(); // User reopened app
    }
  }

  Future<void> _setUserActive() async {
    if (_currentUserId != null && _gameCode != null) {
      await _firestore
          .collection('games')
          .doc(_gameCode)
          .collection('players')
          .doc(_currentUserId)
          .update({'status': 'active'});
    }
  }

  Future<void> _setUserInactive() async {
    if (_currentUserId != null && _gameCode != null) {
      await _firestore
          .collection('games')
          .doc(_gameCode)
          .collection('players')
          .doc(_currentUserId)
          .update({'status': 'inactive'});
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
