import 'package:camjam/features/game/presentation/pages/create_game_screen.dart';
import 'package:camjam/features/join_game/presentation/dialogs/join_game_dialog.dart';
import 'package:flutter/material.dart';
import '../widgets/game_card.dart';

class DashboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> games = [
    {'title': 'Selfie Showdown', 'icon': Icons.camera},
    {'title': 'Pose Party', 'icon': Icons.people},
    {'title': 'Photo Rush', 'icon': Icons.flash_on},
    {'title': 'Snap Scorer', 'icon': Icons.star},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Dashboard'),
      ),
      body: Column(
        children: [
          // Join Game Button
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _showJoinGameDialog(context),
              child: Text('Join a Game'),
            ),
          ),

          // Game Cards Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of cards per row
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return GameCard(
                      title: game['title'],
                      icon: game['icon'],
                      onTap: () {
                        _navigateToGame(context, game['title']);
                      });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToGame(BuildContext context, String gameTitle) {
    if (gameTitle == 'Pose Party') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateGameScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected: $gameTitle')),
      );
      // Add navigation for other games when ready
    }
  }

  void _showJoinGameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => JoinGameDialog(),
    );
  }
}
