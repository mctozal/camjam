import 'dart:async';
import 'dart:io';
import 'package:camjam/core/services/lifecycle_service.dart';
import 'package:camjam/core/services/storage_service.dart';
import 'package:camjam/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:camjam/features/game/data/models/game.dart';
import 'package:camjam/features/game/data/models/player.dart';
import 'package:camjam/features/game/data/models/round.dart';
import 'package:camjam/features/game/data/repositories/game_data_repository.dart';
import 'package:camjam/features/game/data/repositories/game_repository.dart';
import 'package:camjam/features/game/data/repositories/player_repository.dart';
import 'package:camjam/features/game/data/repositories/round_repository.dart';
import 'package:camjam/features/game/presentation/pages/result_screen.dart';
import 'package:camjam/features/game/presentation/pages/voting_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;

class GameScreen extends StatefulWidget {
  final String currentPlayerId; // ID of the current player
  final String gameCode;
  final bool isCreator;

  const GameScreen(
      {super.key,
      required this.currentPlayerId,
      required this.gameCode,
      required this.isCreator});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final StorageService _storageService = StorageService();
  final GameDataRepository _gameDataRepository = GameDataRepository();
  final GameRepository _gameRepository = GameRepository();
  final PlayerRepository _playerRepository = PlayerRepository();
  final RoundRepository _roundRepository = RoundRepository();
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

    // Initialize global lifecycle service
    LifecycleService().initialize(
      userId: widget.currentPlayerId,
      gameCode: widget.gameCode,
    );

    // Initialize the player stream
    playerStream = _playerRepository.listenToPlayers(widget.gameCode);
    // Initialize the game stream
    gameStream = _gameRepository.listenToGame(widget.gameCode);

    // Listen to the player stream and update the UI
    playerStream.listen((updatedPlayers) async {
      setState(() {
        players = updatedPlayers;
      });
    });

    gameStream.listen((updatedGame) async {
      setState(() {
        game = updatedGame;

        if (game.status == 'corrupted') {
          _showCreatorDisconnectedDialog();
        }
      });
    });

    _initializeCamera();
    _startTimer();
    _fetchPov();
    _addRound();
  }

  Future<void> _fetchPov() async {
    _pov = await _gameDataRepository.getRandomPov() ?? '';
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
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _addRound() async {
    if (_roundNumber > 1) {
      String previousRoundNumber = (_roundNumber - 1).toString();
      await _roundRepository.completeRound(widget.gameCode,
          previousRoundNumber); // Ensure previous round is completed before adding a new one
    }

    final round = Round(
      roundNumber: _roundNumber,
      startTime: Timestamp.now(),
      endTime:
          Timestamp.now(), // Don't set endTime yet, as the round just started
      status: "in-progress",
    );

    await _roundRepository.addRound(
        widget.gameCode, round); // Ensure round is properly saved
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

    if (_roundNumber >= game.numberOfRounds) {
      // Navigate to Result Screen after the final round
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(players: players),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VotingScreen(
              gameCode: game.gameCode,
              currentUserId: widget.currentPlayerId,
              isCreator: widget.isCreator,
              roundNumber: _roundNumber,
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
              }),
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

      await _uploadPhoto(photo);
    } catch (e) {
      debugPrint('Error capturing photo: $e');
    }
  }

  Future<void> _savePhotoToFirestore(String photoUrl) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore
          .collection('games')
          .doc(widget.gameCode)
          .collection('photos') // Store in a subcollection
          .add({
        'url': photoUrl,
        'uploadedBy': widget.currentPlayerId,
        'timestamp': FieldValue.serverTimestamp(),
        'round': _roundNumber
      });

      debugPrint('Photo saved to Firestore');
    } catch (e) {
      debugPrint('Error saving photo to Firestore: $e');
    }
  }

  Future<void> _uploadPhoto(XFile photo) async {
    final File imageFile = File(photo.path);
    final String fileName = path.basename(photo.path); // Get file name
    final String folderPath = 'game_photos/${widget.gameCode}/$fileName';
    String url =
        await _storageService.uploadPhoto(imageFile, folderPath, fileName);
    await _savePhotoToFirestore(url);
  }

  @override
  void dispose() {
    super.dispose();
    LifecycleService().dispose();
    _timer.cancel();
    _cameraController.dispose();
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
