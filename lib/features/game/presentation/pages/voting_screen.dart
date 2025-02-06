import 'dart:async';
import 'package:camjam/core/services/lifecycle_service.dart';
import 'package:camjam/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:camjam/features/game/data/models/game.dart';
import 'package:camjam/features/game/data/models/player.dart';
import 'package:camjam/features/game/data/repositories/game_repository.dart';
import 'package:camjam/features/game/data/repositories/photo_repository.dart';
import 'package:camjam/features/game/data/repositories/player_repository.dart';
import 'package:flutter/material.dart';

class VotingScreen extends StatefulWidget {
  final String gameCode;
  final String currentUserId;
  final bool isCreator;
  final int roundNumber;
  final VoidCallback onRoundComplete;

  VotingScreen({
    required this.gameCode,
    required this.currentUserId,
    required this.isCreator,
    required this.roundNumber,
    required this.onRoundComplete,
  });

  @override
  _VotingScreenState createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  final GameRepository _gameRepository = GameRepository();
  final PlayerRepository _playerRepository = PlayerRepository();
  final PhotoRepository _photoRepository = PhotoRepository();
  late Stream<List<Player>> playerStream;
  late Stream<Game> gameStream;
  late Stream<List<Map<String, dynamic>>>
      pictureStream; // Stream for pictures taken
  List<Player> players = [];
  int remainingTime = 30; // Timer value in seconds
  bool isGameInProgress = false;
  String? selectedPicture;
  late Timer countdownTimer;
  bool hasVoted = false;

  @override
  void initState() {
    super.initState();

    // Initialize global lifecycle service
    LifecycleService().initialize(
      userId: widget.currentUserId,
      gameCode: widget.gameCode,
    );

    gameStream = _gameRepository.listenToGame(widget.gameCode);

    gameStream.listen((game) async {
      setState(() {
        if (game.status == 'corrupted') {
          _showCreatorDisconnectedDialog();
        }
      });
    });
    // Initialize the player stream
    playerStream = _playerRepository.listenToPlayers(widget.gameCode);

    playerStream.listen((updatedPlayers) async {
      setState(() {
        players = updatedPlayers
            .where((player) => player.status == 'active')
            .toList();
      });
    });

    pictureStream = _photoRepository.listenToPictures(widget.gameCode);

    // Start a countdown timer for 30 seconds
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        countdownTimer.cancel();
        widget.onRoundComplete();
        Navigator.pop(context);
        // Stop the timer once it reaches 0
        // Submit scores or perform other game end actions here
      }
    });
  }

  @override
  void dispose() {
    countdownTimer.cancel(); // Cancel the timer when the widget is disposed
    LifecycleService().dispose();
    super.dispose();
  }

  void _selectPicture(String pictureUrl, String uploadedBy) {
    setState(() {
      selectedPicture = pictureUrl;
      if (uploadedBy != widget.currentUserId && !hasVoted) {
        _playerRepository.increasePlayerScore(widget.gameCode, uploadedBy);
        hasVoted = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Voting Screen'),
            automaticallyImplyLeading: false,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display timer
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Time Remaining: $remainingTime seconds',
                  style: const TextStyle(fontSize: 24),
                ),
              ),

              // Horizontal list of players and their scores
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          CircleAvatar(child: Text(player.name[0])),
                          Text(player.name),
                          Text('Score: ${player.score}'),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Grid view for displaying pictures
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: pictureStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final pictures = snapshot.data
                            ?.where((pictureData) =>
                                pictureData['round'] ==
                                widget.roundNumber.toString())
                            .toList() ??
                        [];
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: pictures.length,
                      itemBuilder: (context, index) {
                        final picture = pictures[index];
                        final isSelected = selectedPicture == picture['url'];

                        return GestureDetector(
                          onTap: () => _selectPicture(
                              picture['url']!, picture['uploadedBy']!),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    8), // Optional rounded corners
                                child: Image.network(
                                  picture['url']!,
                                  fit: BoxFit.cover,
                                  width:
                                      double.infinity, // Adjust size as needed
                                  height: double.infinity,
                                ),
                              ),
                              if (isSelected)
                                const Positioned(
                                  top: 5, // Adjust position inside the image
                                  right: 5,
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 24, // Adjust icon size
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  void _showCreatorDisconnectedDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Game Over"),
        content: const Text("The game creator has left."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
