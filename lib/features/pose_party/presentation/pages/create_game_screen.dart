import 'dart:math';
import 'package:camjam/core/services/firestore_service.dart';
import 'package:camjam/features/pose_party/data/repositories/game_repository.dart';
import 'package:camjam/features/pose_party/presentation/pages/waiting_room_screen.dart';
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
  final GameRepository _gameRepository = GameRepository(FirestoreService());

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

  void _startGame() async {
    // Create the game in Firestore
    try {
      await _gameRepository.createGame(_gameCode, {
        'gameCode': _gameCode,
        'timePerRound': _timePerRound.toInt(),
        'numberOfRounds': _numberOfRounds.toInt(),
        'players': [], // Initial empty player list
        'status': 'waiting', // Status can be 'waiting' or 'started'
      });

      // Proceed to the Waiting Room
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WaitingRoomScreen(
            timePerRound: _timePerRound.toInt(),
            numberOfRounds: _numberOfRounds.toInt(),
            gameCode: _gameCode,
          ),
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
