import 'dart:math';
import 'package:camjam/core/models/User.dart';
import 'package:camjam/core/services/user_service.dart';
import 'package:camjam/features/game/data/models/game.dart';
import 'package:camjam/features/game/data/models/player.dart';
import 'package:camjam/features/game/data/repositories/game_repository.dart';
import 'package:camjam/features/game/data/repositories/player_repository.dart';
import 'package:camjam/features/game/presentation/pages/waiting_room_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/game_option_card.dart';

class CreateGameScreen extends StatefulWidget {
  @override
  _CreateGameScreenState createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  double _timePerRound = 5; // Default value for time per round
  double _numberOfRounds = 5; // Default value for number of rounds
  late String _gameCode;
  final GameRepository _gameRepository = GameRepository();
  final PlayerRepository _playerRepository = PlayerRepository();
  final UserService _userService = UserService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _generateGameCode(); // Generate code when the screen is loaded
  }

  void _generateGameCode() {
    final random = Random();
    setState(() {
      _gameCode = (random.nextInt(90000) + 10000).toString(); // 5-digit code
    });
  }

  Future<void> createGame() async {
    User? currentUser = await _userService.getCurrentUser();

    if (currentUser == null) {
      print("Error: No current user found.");
      return;
    }

    Game game = Game(
        gameCode: _gameCode,
        timePerRound: _timePerRound.toInt(),
        numberOfRounds: _numberOfRounds.toInt(),
        creatorId: currentUser.id,
        createdAt: Timestamp.now(),
        status: 'waiting');

    await _gameRepository.addGame(game);

    Player player = Player(
        id: currentUser.id,
        name: currentUser.username,
        joinedAt: Timestamp.now(),
        status: 'active');

    await _playerRepository.addPlayer(_gameCode, player);
  }

  void _startGame() async {
    String userId = await _userService.getUserHashId();
    createGame();
    try {
      // Proceed to the Waiting Room
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WaitingRoomScreen(
              isCreator: true, gameCode: _gameCode, currentUserId: userId),
        ),
      );
    } catch (e) {
      // Handle Firestore errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create game: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Pose Party Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Pose Party! Customize your game settings below:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Time Per Round Option
            GameOptionCard(
              title: 'Time Per Round',
              description: 'Choose how long each round lasts.',
              min: 3, // Minimum time (in seconds)
              max: 10, // Maximum time (in seconds)
              initialValue: _timePerRound,
              unit: 'seconds',
              onValueChanged: (value) {
                setState(() {
                  _timePerRound = value;
                });
              },
            ),
            SizedBox(height: 16),

            // Number of Rounds Option
            GameOptionCard(
              title: 'Number of Rounds',
              description: 'Decide how many rounds the game will have.',
              min: 5, // Minimum number of rounds
              max: 10, // Maximum number of rounds
              initialValue: _numberOfRounds,
              unit: 'rounds',
              onValueChanged: (value) {
                setState(() {
                  _numberOfRounds = value;
                });
              },
            ),
            SizedBox(height: 40),

            // Start Game Button
            Center(
                child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width * 0.6,
                    50), // 60% of screen width, height: 50
                maximumSize: Size(MediaQuery.of(context).size.width * 0.8,
                    60), // 80% of screen width, height: 60
              ),
              onPressed: () {
                _startGame();
              },
              child: Text(
                'Start Game',
                style:
                    TextStyle(fontSize: 18), // Adjust font size for readability
              ),
            )),
          ],
        ),
      ),
    );
  }
}
