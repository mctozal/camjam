import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camjam/core/state/game_state.dart';
import 'package:camjam/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:camjam/features/game/presentation/pages/counter_screen.dart';
import 'package:camjam/features/game/presentation/pages/pov_screen.dart';
import 'package:camjam/features/game/presentation/pages/photo_screen.dart';
import 'package:camjam/features/game/presentation/pages/voting_screen.dart';
import 'package:camjam/features/game/presentation/pages/result_screen.dart';

class GameScreen extends StatefulWidget {
  final String currentPlayerId;
  final String gameCode;
  final bool isCreator;

  const GameScreen({
    required this.currentPlayerId,
    required this.gameCode,
    required this.isCreator,
    super.key,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    var gameState = Provider.of<GameState>(context, listen: false);
    gameState.initializeGameState(widget.gameCode, widget.currentPlayerId);
    gameState.listenToGame(widget.gameCode);
    gameState.listenToPlayers(widget.gameCode);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Consumer<GameState>(
        builder: (context, gameState, child) {
          final game = gameState.game;
          debugPrint('GameScreen: Game=${game?.status}');

          if (game == null) {
            debugPrint('GameScreen: Game or Phase is null');
            return const Center(child: CircularProgressIndicator());
          }

          if (game.status == 'corrupted') {
            _showCreatorDisconnectedDialog(context);
            return Container();
          }

          if (game.status == 'completed') {
            debugPrint('GameScreen: Navigating to ResultScreen');

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(
                    players: gameState.players,
                    gameCode: game.gameCode,
                    numberOfRound: game.numberOfRounds,
                    timePerRound: game.timePerRound,
                  ),
                ),
              );
            });

            return Container();
          }

          switch (game.roundPhase) {
            case 'counter':
              return CounterScreen(
                roundNumber: game.currentRound,
                onCountdownComplete: () {
                  if (widget.isCreator) {
                    gameState.updateRoundPhase('pov', 5);
                  }
                },
              );
            case 'pov':
              return PoseScreen(
                pose: game.pov,
                onPoseComplete: () {
                  if (widget.isCreator) {
                    gameState.updateRoundPhase('photo', 5);
                  }
                },
              );
            case 'photo':
              return PhotoScreen(
                gameCode: widget.gameCode,
                currentPlayerId: widget.currentPlayerId,
                isCreator: widget.isCreator,
                game: game,
                onPhotoCaptured: () {
                  if (widget.isCreator) {
                    gameState.updateRoundPhase('voting', 5);
                  }
                },
              );
            case 'voting':
              return VotingScreen(
                gameCode: widget.gameCode,
                currentUserId: widget.currentPlayerId,
                isCreator: widget.isCreator,
                roundNumber: game.currentRound,
                onRoundComplete: () {
                  if (widget.isCreator &&
                      game.currentRound < game.numberOfRounds) {
                    gameState.updateCurrentRound(game.currentRound + 1);
                    gameState.updateRoundPhase('counter', 5);
                    gameState.updatePov(game.gameCode);
                  } else if (widget.isCreator) {
                    //if nor <=currentround
                    gameState.completeGame();
                  }
                },
              );
            default:
              debugPrint('GameScreen: Unknown phase: ${game.roundPhase}');
              return const Center(child: Text('Unknown game phase'));
          }
        },
      ),
    );
  }

  void _showCreatorDisconnectedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Game Over"),
        content: const Text("The game creator has left."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
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
