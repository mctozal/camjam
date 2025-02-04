import 'dart:async'; // For Timer
import 'package:camjam/core/services/lifecycle_service.dart';
import 'package:camjam/features/game/data/models/game.dart';
import 'package:camjam/features/game/data/models/player.dart';
import 'package:camjam/features/game/data/repositories/player_repository.dart';
import 'package:camjam/features/game/presentation/pages/game_screen.dart';
import 'package:camjam/features/game/data/repositories/game_repository.dart';
import 'package:flutter/material.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String gameCode;
  final String currentUserId;
  final bool isCreator;

  WaitingRoomScreen(
      {required this.gameCode,
      required this.currentUserId,
      required this.isCreator});

  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final GameRepository _gameRepository =
      GameRepository(); // Initialize the repository

  final PlayerRepository _playerRepository = PlayerRepository();

  List<Player> players = []; // Track the list of players
  late Game game;
  late Stream<List<Player>> playerStream;
  late Stream<Game> gameStream;

  bool isGameInProgress = false;

  @override
  void initState() {
    super.initState();

    // Initialize global lifecycle service
    LifecycleService().initialize(
      userId: widget.currentUserId,
      gameCode: widget.gameCode,
    );

    // Initialize the player stream
    playerStream = _playerRepository.listenToPlayers(widget.gameCode);
    // Initialize the game stream
    gameStream = _gameRepository.listenToGame(widget.gameCode);

    // Listen to the player stream and update the UI
    playerStream.listen((updatedPlayers) async {
      setState(() {
        players = updatedPlayers
            .where((player) => player.status == 'active')
            .toList();
      });
    });

    gameStream.listen((updatedGame) async {
      setState(() {
        game = updatedGame;
      });
      // Redirect to the GameScreen when the game status is in progress
      if (game.status == 'in-progress') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(
              gameCode: game.gameCode,
              currentPlayerId: widget.currentUserId,
              isCreator: false,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    LifecycleService().dispose();
    super.dispose();
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
            // Display the PlayersScreen within the WaitingRoomScreen
            Expanded(
              child: StreamBuilder<List<Player>>(
                stream: playerStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final players = snapshot.data ?? [];

                  if (players.isEmpty) {
                    return Center(
                      child: Text(
                        'No players have joined yet.',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                              player.name[0]), // Display first letter of name
                        ),
                        title: Text(player.name),
                        subtitle: Text('Score: ${player.score}'),
                      );
                    },
                  );
                },
              ),
            ),
            if (widget.isCreator)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize:
                      Size(MediaQuery.of(context).size.width * 0.6, 50),
                ),
                onPressed: players.isNotEmpty
                    ? () {
                        _startGame();
                      }
                    : null, // Disable button if no players have joined
                child: const Text(
                  'Start Game',
                  style: TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _startGame() {
    // Navigate to the GameScreen
    _gameRepository.startGame(widget.gameCode);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          currentPlayerId: widget.currentUserId,
          gameCode: widget.gameCode,
          isCreator: true,
        ),
      ),
    );

    // Notify the user that the game has started
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Game Started!')),
    );
  }
}
