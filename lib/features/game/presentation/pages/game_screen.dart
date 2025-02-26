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
  late GameState _gameState;

  @override
  void initState() {
    super.initState();
    _gameState = Provider.of<GameState>(context, listen: false);
    _gameState.initializeGameState(widget.gameCode, widget.currentPlayerId);
    _gameState.listenToGame(widget.gameCode);
    _gameState.listenToPlayers(widget.gameCode);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Consumer<GameState>(
        builder: (context, gameState, child) {
          final game = gameState.game;
          debugPrint(
              'GameScreen: Game=${game?.status}, Phase=${gameState.currentPhase}');

          if (game == null || gameState.currentPhase == null) {
            debugPrint('GameScreen: Game or Phase is null');
            return const Center(child: CircularProgressIndicator());
          }

          if (game.status == 'corrupted') {
            _showCreatorDisconnectedDialog(context);
            return Container();
          }

          if (game.status == 'completed' && !gameState.hasNavigatedToResults) {
            gameState.setNavigatedToResults();
            debugPrint('GameScreen: Navigating to ResultScreen');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResultScreen(players: gameState.players),
              ),
            );
            return Container();
          }

          if (game.roundPhase == 'voting' && !gameState.isVotingActive) {
            gameState.setVotingActive(true);
            debugPrint('GameScreen: Navigating to VotingScreen');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VotingScreen(
                  gameCode: widget.gameCode,
                  currentUserId: widget.currentPlayerId,
                  isCreator: widget.isCreator,
                  roundNumber: game.currentRound,
                  onRoundComplete: () {
                    gameState.setVotingActive(false);
                    if (widget.isCreator &&
                        game.currentRound < game.numberOfRounds) {
                      gameState.updateRoundPhase('counter', 5);
                      gameState.updateCurrentRound(game.currentRound + 1);
                    } else if (widget.isCreator) {
                      gameState.completeGame();
                    }
                  },
                ),
              ),
            );
            return Container();
          }

          switch (game.roundPhase) {
            case 'counter':
              return CounterScreen(
                roundNumber: game.currentRound,
                onCountdownComplete: () {
                  if (widget.isCreator) {
                    gameState.nextPhase(game, widget.isCreator);
                  }
                },
              );
            case 'pov':
              return PoseScreen(
                pose: game.pov,
                onPoseComplete: () {
                  if (widget.isCreator) {
                    gameState.nextPhase(game, widget.isCreator);
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
                    gameState.nextPhase(game, widget.isCreator);
                  }
                },
              );
            case 'voting':
              return Container();
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
