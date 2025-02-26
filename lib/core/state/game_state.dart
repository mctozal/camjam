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
  final PhotoRepository _photoRepository = PhotoRepository();
  Game? _game;
  List<Player> _players = [];
  String? _currentPhase;
  bool _isVotingActive = false;
  bool _hasNavigatedToResults = false;
  bool _isDisposed = false;
  StreamSubscription<Game>? _gameStreamSubscription;
  StreamSubscription<List<Player>>? _playerStreamSubscription;

  Game? get game => _game;
  List<Player> get players => _players;
  String? get currentPhase => _currentPhase;

  Stream<Game> get gameStream =>
      _gameRepository.listenToGame(_game?.gameCode ?? '');
  Stream<List<Player>> get playerStream =>
      _playerRepository.listenToPlayers(_game?.gameCode ?? '');

  GameState(String gameCode, String currentPlayerId) {
    if (gameCode.isNotEmpty && currentPlayerId.isNotEmpty) {
      initializeGameState(gameCode, currentPlayerId);
      listenToGame(gameCode);
      listenToPlayers(gameCode);
    }
  }

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
        if (_game!.pov == null || _game!.pov.isEmpty) {
          final defaultPov =
              await _gameDataRepository.getRandomPov() ?? 'Default Pose';
          await _gameRepository.updatePov(gameCode, defaultPov);
          _game = _game!.copyWith(pov: defaultPov);
        }
        _currentPhase = _game!.roundPhase;
        debugPrint(
            'Initial game state loaded: ${_game!.status}, phase: $_currentPhase, pov: ${_game!.pov}');
      } else {
        debugPrint('No game document found for code: $gameCode');
        _game = Game(
          gameCode: gameCode,
          creatorId: currentPlayerId,
          status: 'waiting',
          numberOfRounds: 3,
          timePerRound: 30,
          pov: await _gameDataRepository.getRandomPov() ?? 'Default Pose',
          createdAt: Timestamp.now(),
          currentRound: 1,
          roundPhase: 'counter',
          phaseStartTime: Timestamp.now(),
          phaseDuration: 10,
        );
        _currentPhase = 'counter';
      }
    } catch (e) {
      debugPrint('Error initializing game state: $e');
      _game = Game(
        gameCode: gameCode,
        creatorId: currentPlayerId,
        status: 'error',
        numberOfRounds: 3,
        timePerRound: 30,
        pov: 'Error Pose',
        createdAt: Timestamp.now(),
        currentRound: 1,
        roundPhase: 'error',
        phaseStartTime: Timestamp.now(),
        phaseDuration: 10,
      );
      _currentPhase = 'error';
    }
    if (!_isDisposed) notifyListeners();
  }

  void listenToGame(String gameCode) {
    _gameStreamSubscription?.cancel(); // Cancel any existing subscription
    _gameStreamSubscription = _gameRepository.listenToGame(gameCode).listen(
      (game) {
        _game = game;
        _currentPhase = game.roundPhase;
        debugPrint(
            'Game stream update: ${_game!.status}, phase: $_currentPhase, pov: ${_game!.pov}');
        if (!_isDisposed) notifyListeners();
      },
      onError: (error) {
        debugPrint('Game stream error: $error');
      },
    );
  }

  void listenToPlayers(String gameCode) {
    _playerStreamSubscription?.cancel(); // Cancel any existing subscription
    _playerStreamSubscription =
        _playerRepository.listenToPlayers(gameCode).listen(
      (updatedPlayers) {
        _players = updatedPlayers;
        debugPrint('Players updated: ${_players.length} players');
        if (!_isDisposed) notifyListeners();
      },
      onError: (error) {
        debugPrint('Players stream error: $error');
      },
    );
  }

  Future<void> updateRoundPhase(String phase, int duration) async {
    if (_game == null) return;
    await _gameRepository.updateRoundPhase(_game!.gameCode, phase, duration);
    _currentPhase = phase;
    if (!_isDisposed) notifyListeners();
  }

  Future<void> updateCurrentRound(int round) async {
    if (_game == null) return;
    await _gameRepository.updateCurrentRound(_game!.gameCode, round);
    if (_game != null) {
      _game = _game!.copyWith(currentRound: round);
    }
    if (!_isDisposed) notifyListeners();
  }

  Future<void> completeGame() async {
    if (_game == null) return;
    await _gameRepository.completeGame(_game!.gameCode);
    if (_game != null) {
      _game = _game!.copyWith(status: 'completed');
    }
    if (!_isDisposed) notifyListeners();
  }

  Future<void> nextPhase(Game game, bool isCreator) async {
    if (!isCreator || _game == null) return;

    String nextPhase;
    int nextDuration;
    String? nextPose;

    if (game.roundPhase == 'counter') {
      nextPhase = 'pov';
      nextDuration = 10;
      nextPose = await _gameDataRepository.getRandomPov() ?? 'Default Pose';
    } else if (game.roundPhase == 'pov') {
      nextPhase = 'photo';
      nextDuration = game.timePerRound;
    } else if (game.roundPhase == 'photo') {
      nextPhase = 'voting';
      nextDuration = 30;
    } else {
      return;
    }

    await _gameRepository.updateRoundPhase(
        game.gameCode, nextPhase, nextDuration);
    if (nextPose != null) {
      await _gameRepository.updatePov(game.gameCode, nextPose);
      _game = _game!.copyWith(pov: nextPose);
    }
    _currentPhase = nextPhase;
    if (!_isDisposed) notifyListeners();
  }

  Stream<List<Map<String, dynamic>>> photoStream(String gameCode) {
    return _photoRepository.listenToPictures(gameCode);
  }

  void setVotingActive(bool value) {
    _isVotingActive = value;
    if (!_isDisposed) notifyListeners();
  }

  bool get isVotingActive => _isVotingActive;

  void setNavigatedToResults() {
    _hasNavigatedToResults = true;
    if (!_isDisposed) notifyListeners();
  }

  bool get hasNavigatedToResults => _hasNavigatedToResults;

  @override
  void dispose() {
    _isDisposed = true;
    _gameStreamSubscription?.cancel();
    _playerStreamSubscription?.cancel();
    super.dispose();
    debugPrint('GameState disposed');
  }
}
