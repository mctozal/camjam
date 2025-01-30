import 'dart:async';
import 'dart:io';
import 'package:camjam/features/game/data/models/game.dart';
import 'package:camjam/features/game/data/models/player.dart';
import 'package:camjam/features/game/data/models/round.dart';
import 'package:camjam/features/game/data/repositories/game_data_repository.dart';
import 'package:camjam/features/game/data/repositories/game_repository.dart';
import 'package:camjam/features/game/presentation/pages/result_screen.dart';
import 'package:camjam/features/game/presentation/pages/voting_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class GameScreen extends StatefulWidget {
  final String currentPlayerId; // ID of the current player
  final String gameCode;
  final bool isCreator;

  GameScreen(
      {required this.currentPlayerId,
      required this.gameCode,
      required this.isCreator});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameDataRepository _gameDataRepository = GameDataRepository();
  final GameRepository gameRepository = GameRepository();
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  String? _capturedPhotoPath;
  List<Player> players = []; // Track the list of players
  late Game game;
  late Stream<List<Player>> playerStream;
  late Stream<Game> gameStream;

  int _roundNumber = 1;
  int _timerDuration = 10;
  late Timer _timer;
  String _pov = '';

  @override
  void initState() {
    super.initState();
    // Initialize the player stream
    playerStream = gameRepository.listenToPlayers(widget.gameCode);
    // Initialize the game stream
    gameStream = gameRepository.listenToGame(widget.gameCode);

    // Listen to the player stream and update the UI
    playerStream.listen((updatedPlayers) async {
      setState(() {
        players = updatedPlayers;
      });
    });

    gameStream.listen((updatedGame) async {
      setState(() {
        game = updatedGame;
      });
    });

    _requestPermissions().then((_) => _initializeCamera());
    _startTimer();
  }

  Future<void> _fetchPov() async {
    _pov = await _gameDataRepository.getRandomPov() ?? '';
  }

  Future<void> _requestPermissions() async {
    // Check current camera permission status
    if (await Permission.camera.isDenied ||
        await Permission.camera.isRestricted) {
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus.isPermanentlyDenied) {
        openAppSettings(); // Redirect the user to settings if permission is permanently denied
        return;
      }
    }

    // Check current microphone permission status
    if (await Permission.microphone.isDenied ||
        await Permission.microphone.isRestricted) {
      final micStatus = await Permission.microphone.request();
      if (micStatus.isPermanentlyDenied) {
        openAppSettings(); // Redirect the user to settings if permission is permanently denied
        return;
      }
    }

    // Both permissions are granted or already available
    debugPrint('Camera and microphone permissions granted.');
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception("No cameras available");
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
      );

      _initializeControllerFuture = _cameraController.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerDuration > 0) {
        setState(() {
          _timerDuration--;
        });
      } else {
        _endRound();
      }
    });
  }

  void _endRound() {
    _timer.cancel();

    // Create a dummy round object
    final currentRound = Round(
      roundNumber: _roundNumber,
      startTime: Timestamp.now(),
      endTime: Timestamp.now(),
      status: "in-progress",
      scores: players.asMap().map((index, player) {
        return MapEntry(
          player.id,
          PlayerScore(
            score: 0,
            pictureUrl: player.id == widget.currentPlayerId
                ? _capturedPhotoPath ?? ''
                : '',
            timestamp: Timestamp.now(),
          ),
        );
      }),
    );

    if (_roundNumber >= game.numberOfRounds) {
      // Navigate to Result Screen after the final round
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(players: players),
        ),
      );
    } else {
      // Navigate to Voting Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VotingScreen(
            currentRound: currentRound,
            currentPlayerId: widget.currentPlayerId,
            onRoundComplete: () {
              setState(() {
                _roundNumber++;
                _fetchPov();
                if (_roundNumber > game.numberOfRounds) {
                  print('Game Over');
                } else {
                  _timerDuration = game.timePerRound;
                  _capturedPhotoPath = null;
                  _startTimer();
                }
              });
            },
          ),
        ),
      );
    }
  }

  Future<void> _capturePhoto() async {
    try {
      await _initializeControllerFuture;
      final photo = await _cameraController.takePicture();
      setState(() {
        _capturedPhotoPath = photo.path;
      });
    } catch (e) {
      debugPrint('Error capturing photo: $e');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Screen - Round $_roundNumber'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Round: $_roundNumber',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Time: $_timerDuration s',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_pov),
          ),
          if (_capturedPhotoPath != null)
            Expanded(
              child: Image.file(
                File(_capturedPhotoPath!),
                fit: BoxFit.cover,
              ),
            )
          else
            Expanded(
              child: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // Display the camera preview
                    return CameraPreview(_cameraController);
                  } else if (snapshot.hasError) {
                    // Display an error message if the camera couldn't be initialized
                    return const Center(
                      child: Text(
                        'Error initializing camera.',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    );
                  } else {
                    // Display a loading indicator while the camera initializes
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: _capturePhoto,
            child: const Text('Capture Photo'),
          ),
        ],
      ),
    );
  }
}
