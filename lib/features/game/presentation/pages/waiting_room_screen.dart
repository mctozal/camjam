import 'dart:async'; // For Timer
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camjam/core/services/lifecycle_service.dart';
import 'package:camjam/features/game/data/models/game.dart';
import 'package:camjam/features/game/data/models/player.dart';
import 'package:camjam/features/game/data/repositories/player_repository.dart';
import 'package:camjam/features/game/presentation/pages/game_screen.dart';
import 'package:camjam/features/game/data/repositories/game_repository.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String gameCode;
  final String currentUserId;
  final bool isCreator;

  const WaitingRoomScreen({
    super.key,
    required this.gameCode,
    required this.currentUserId,
    required this.isCreator,
  });

  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final GameRepository _gameRepository = GameRepository();
  final PlayerRepository _playerRepository = PlayerRepository();

  late String creatorName = 'Creator';
  late String creatorAvatar = 'avatar_0.png';

  List<Player> players = [];

  late Game game = Game(
    gameCode: '',
    creatorId: '',
    status: '',
    numberOfRounds: 0,
    timePerRound: 0,
    pov: '',
    createdAt: Timestamp.fromDate(DateTime.now().toUtc()),
  );

  late Stream<List<Player>> playerStream;
  late Stream<Game> gameStream;

  void _fetchCreator() {
    creatorName = players.isNotEmpty
        ? players.firstWhere((player) => player.id == game.creatorId).name
        : 'Unknown';

    creatorAvatar = players.isNotEmpty
        ? players.firstWhere((player) => player.id == game.creatorId).avatar
        : 'avatar_0.png';
  }

  @override
  void initState() {
    super.initState();

    LifecycleService()
        .initialize(userId: widget.currentUserId, gameCode: widget.gameCode);

    playerStream = _playerRepository.listenToPlayers(widget.gameCode);
    gameStream = _gameRepository.listenToGame(widget.gameCode);

    playerStream.listen((updatedPlayers) {
      setState(() {
        players = updatedPlayers
            .where((player) => player.status == 'active')
            .toList();
        _fetchCreator();
      });
    });

    gameStream.listen((updatedGame) {
      setState(() {
        game = updatedGame;
        _fetchCreator();
      });

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Centered Logo
              Center(
                child: Image.asset(
                  'lib/assets/logo-small.png',
                  height: 80,
                ),
              ),
              const SizedBox(height: 16),

              // Centered Lobby No
              const Text(
                "Lobby No",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Lobby Code + Copy Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.gameCode,
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.gameCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Lobby Code Copied!"),
                          behavior: SnackBarBehavior.floating, // Floating style
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Split Section: Left (Details) | Right (Avatar)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Side: Creator Name, Role, Round, Count
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(creatorName,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('Creator',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400)),
                        SizedBox(height: 12),
                        _infoText(
                            "Round:",
                            game != null
                                ? game.numberOfRounds.toString()
                                : '0'),
                        _infoText(
                          "Timer:",
                          '${game != null ? game.timePerRound.toString() : '0'} sec',
                        ),
                      ],
                    ),

                    // Right Side: Circular User Avatar
                    CircleAvatar(
                      minRadius: 20,
                      maxRadius: 45,
                      backgroundImage: AssetImage('lib/assets/$creatorAvatar'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // User Icons Grid (3 per row)
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

                    final players = snapshot.data!
                            .where((player) => player.name != creatorName)
                            .toList() ??
                        [];

                    if (players.isEmpty) {
                      return const Center(
                        child: Text(
                          'No players have joined yet.',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 3 icons per row
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final player = players[index];

                        return Column(
                          children: [
                            CircleAvatar(
                              minRadius: 20,
                              maxRadius: 40,
                              backgroundImage:
                                  AssetImage('lib/assets/${player.avatar}'),
                            ),
                            const SizedBox(height: 4),
                            Text(player.name,
                                style: const TextStyle(fontSize: 14)),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              if (widget.isCreator)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize:
                            Size(MediaQuery.of(context).size.width * 0.6, 50),
                        backgroundColor: Color(0xFF4E0F97)),
                    onPressed: players.isNotEmpty
                        ? _startGame
                        : null, // Disable if no players
                    child: const Text(
                      'START',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                child: TextButton(
                  onPressed: () {
                    _playerRepository.removePlayerFromGame(
                        widget.gameCode, widget.currentUserId);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Leave',
                    style: TextStyle(fontSize: 18, color: Color(0xFF4E0F97)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    LifecycleService().dispose();
    super.dispose();
  }

  Widget _infoText(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green),
        ),
      ],
    );
  }

  void _startGame() {
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
  }
}
