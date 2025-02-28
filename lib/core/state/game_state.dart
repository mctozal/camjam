import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camjam/features/game/data/models/game.dart';
import 'package:camjam/features/game/data/models/player.dart';
import 'package:camjam/features/game/data/repositories/game_data_repository.dart';
import 'package:camjam/features/game/data/repositories/game_repository.dart';
import 'package:camjam/features/game/data/repositories/player_repository.dart';
import 'package:camjam/features/game/data/repositories/photo_repository.dart';

class GameState extends ChangeNotifier {
  final GameRepository _gameRepository = GameRepository();
  final GameDataRepository _gameDataRepository = GameDataRepository();
  final PlayerRepository _playerRepository = PlayerRepository();

  Game? _game;
  List<Player> _players = [];
  StreamSubscription<Game>? _gameStreamSubscription;
  StreamSubscription<List<Player>>? _playerStreamSubscription;

  Game? get game => _game;
  List<Player> get players => _players;

  Stream<Game> get gameStream =>
      _gameRepository.listenToGame(_game?.gameCode ?? '');
  Stream<List<Player>> get playerStream =>
      _playerRepository.listenToPlayers(_game?.gameCode ?? '');

  Future<void> initializeGameState(
      String gameCode, String currentPlayerId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('games')
          .doc(gameCode)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _game = Game.fromFirestore(data);

        if (_game!.pov.isEmpty) {
          final defaultPov = await _gameDataRepository.getRandomPov();
          await _gameRepository.updatePov(gameCode, defaultPov);
          _game = _game!.copyWith(pov: defaultPov);
        }

        debugPrint(
            'Initial game state loaded: ${_game!.status}, phase: ${_game!.roundPhase}, pov: ${_game!.pov}');
      } else {
        debugPrint('No game document found for code: $gameCode');
      }
    } catch (e) {
      debugPrint('Error initializing game state: $e');
    }
  }

  void listenToGame(String gameCode) {
    _gameStreamSubscription?.cancel();
    _gameStreamSubscription =
        _gameRepository.listenToGame(gameCode).listen((game) {
      _game = game;
      debugPrint(
          'Game stream update: ${_game!.status}, phase: ${_game!.roundPhase}, pov: ${_game!.pov}');
      notifyListeners();
    }, onError: (error) {
      debugPrint('Game stream error: $error');
      if (_game != null) {
        _game = _game!.copyWith(status: 'error', roundPhase: 'error');
        notifyListeners();
      }
    });
  }

  void listenToPlayers(String gameCode) {
    _playerStreamSubscription?.cancel();
    _playerStreamSubscription =
        _playerRepository.listenToPlayers(gameCode).listen(
      (updatedPlayers) {
        _players = updatedPlayers;
        debugPrint('Players updated: ${_players.length} players');
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Players stream error: $error');
      },
    );
  }

  Future<void> updatePov(String gameCode) async {
    final newPov = await _gameDataRepository.getRandomPov();
    await _gameRepository.updatePov(gameCode, newPov);
    _game = _game!.copyWith(pov: newPov);
  }

  Future<void> updateRoundPhase(String phase, int duration) async {
    if (_game == null) return;
    debugPrint('Updating phase to $phase');
    await _gameRepository.updateRoundPhase(_game!.gameCode, phase, duration);
    _game = _game!.copyWith(
      roundPhase: phase,
      phaseDuration: duration,
      phaseStartTime: Timestamp.now(),
    );
    notifyListeners();
  }

  Future<void> updateCurrentRound(int round) async {
    if (_game == null) return;
    await _gameRepository.updateCurrentRound(_game!.gameCode, round);

    _game = _game!.copyWith(currentRound: round);
    notifyListeners();
    debugPrint('current round updated.');
  }

  Future<void> completeGame() async {
    if (_game == null) return;
    await _gameRepository.completeGame(_game!.gameCode);
    _game = _game!.copyWith(status: 'completed');
    notifyListeners();
  }

  @override
  void dispose() {
    _gameStreamSubscription?.cancel();
    _playerStreamSubscription?.cancel();
    super.dispose();
    debugPrint('GameState disposed');
  }
}
