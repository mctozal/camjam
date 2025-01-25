import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  final String gameCode;

  GameScreen({required this.gameCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Room'),
      ),
      body: Center(
        child: Text(
          'Welcome to the game! Code: $gameCode',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
