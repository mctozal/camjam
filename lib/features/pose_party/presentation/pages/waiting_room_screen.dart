import 'dart:async'; // For Timer
import 'package:camjam/core/services/firestore_service.dart';
import 'package:camjam/features/game/data/models/player.dart';
import 'package:camjam/features/game/presentation/pages/game_screen.dart';
import 'package:camjam/features/pose_party/data/repositories/game_repository.dart';
import 'package:flutter/material.dart';

class WaitingRoomScreen extends StatefulWidget {
  final int timePerRound;
  final int numberOfRounds;
  final String gameCode;
  final GameRepository _gameRepository = GameRepository(FirestoreService());

  WaitingRoomScreen({
    required this.timePerRound,
    required this.numberOfRounds,
    required this.gameCode,
  });

  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  late StreamSubscription _playerStreamSubscription;
  bool hasPlayerJoined = false; // Tracks if another player has joined
  List<String> players = []; // List of players in the game

  @override
  void initState() {
    super.initState();
    _listenToPlayers();
  }

  @override
  void dispose() {
    _playerStreamSubscription
        .cancel(); // Cancel the subscription when screen is disposed
    super.dispose();
  }

  void _listenToPlayers() {
    // Listen to Firestore updates for the game
    _playerStreamSubscription =
        widget._gameRepository.listenToGame(widget.gameCode).listen((gameData) {
      if (gameData.containsKey('players')) {
        final updatedPlayers = List<String>.from(gameData['players']);
        setState(() {
          players = updatedPlayers;
          hasPlayerJoined = players.length > 1; // Check if more than one player
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waiting Room'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Waiting for players to join...',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Game Code: ${widget.gameCode}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),

            // Display players in the waiting room
            Text(
              'Players in the Game:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...players.map((player) => Text(player)).toList(),
            SizedBox(height: 24),

            if (!hasPlayerJoined)
              CircularProgressIndicator(), // Show spinner until a player joins
            if (hasPlayerJoined)
              Column(
                children: [
                  Text(
                    'A player has joined!',
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          Size(MediaQuery.of(context).size.width * 0.6, 50),
                    ),
                    onPressed: () {
                      _startGame();
                    },
                    child: Text(
                      'Start Game',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _startGame() {
    List<Player> players = [];
    players.add(Player(id: '1', name: 'name', photoPath: 'photoPath'));

    // Navigate to the GameScreen
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GameScreen(
              currentPlayerId: '1',
              players: players,
              numberOfRounds: widget.numberOfRounds,
              timePerRound: widget.timePerRound)),
    );
    // Navigate to the game screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Game Started!')),
    );
  }
}
