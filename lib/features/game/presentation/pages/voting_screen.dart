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

  const VotingScreen({
    super.key,
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
  late Stream<List<Map<String, dynamic>>> pictureStream;
  List<Player> players = [];
  int remainingTime = 30;
  String? selectedPicture;
  late Timer countdownTimer;
  bool hasVoted = false;
  StreamSubscription<Game>? _gameStreamSubscription; // For cancellation
  StreamSubscription<List<Player>>? _playerStreamSubscription;

  @override
  void initState() {
    super.initState();

    LifecycleService().initialize(
      userId: widget.currentUserId,
      gameCode: widget.gameCode,
    );

    gameStream = _gameRepository.listenToGame(widget.gameCode);
    playerStream = _playerRepository.listenToPlayers(widget.gameCode);
    pictureStream = _photoRepository.listenToPictures(widget.gameCode);

    _gameStreamSubscription = gameStream.listen((game) {
      if (mounted) {
        setState(() {
          if (game.status == 'corrupted') {
            _showCreatorDisconnectedDialog();
          }
        });
      }
    });

    _playerStreamSubscription = playerStream.listen((updatedPlayers) {
      if (mounted) {
        setState(() {
          players = updatedPlayers
              .where((player) => player.status == 'active')
              .toList();
        });
      }
    });

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        if (mounted) {
          setState(() {
            remainingTime--;
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          widget.onRoundComplete();
        }
      }
    });
  }

  @override
  void dispose() {
    countdownTimer.cancel();
    _gameStreamSubscription?.cancel(); // Cancel stream subscription
    _playerStreamSubscription?.cancel(); // Cancel stream subscription
    LifecycleService().dispose();
    super.dispose();
  }

  void _selectPicture(String pictureUrl, String uploadedBy) {
    if (!mounted) return;
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/logo-small.png', // Replace with your small logo path
                height: 50, // Adjust height as needed
              ),
              SizedBox(width: 20),
              Text(
                widget.roundNumber.toString(),
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Column(
                children: [
                  Text(
                    'Next Round',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Starts in ',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$remainingTime',
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                        CircleAvatar(
                          backgroundImage:
                              AssetImage('lib/assets/${player.avatar}'),
                        ),
                        Text(player.name),
                        Text('Score: ${player.score}'),
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: pictureStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
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
                        onTap: () => {
                          if (!isSelected &&
                              picture['uploadedBy'] != widget.currentUserId)
                            _selectPicture(
                                picture['url']!, picture['uploadedBy']!)
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                picture['url']!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            if (isSelected)
                              const Positioned(
                                bottom: 5,
                                left: 5,
                                child: Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 40,
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
      ),
    );
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
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
