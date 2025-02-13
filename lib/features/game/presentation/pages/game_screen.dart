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
import 'package:camjam/features/game/data/repositories/photo_repository.dart';
import 'package:camjam/features/game/data/repositories/player_repository.dart';
import 'package:camjam/features/game/data/repositories/round_repository.dart';
import 'package:camjam/features/game/presentation/pages/result_screen.dart';
import 'package:camjam/features/game/presentation/pages/voting_screen.dart';
import 'package:camjam/features/game/presentation/widgets/timer_widget.dart';
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
  final PhotoRepository _photoRepository = PhotoRepository();
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  String? _capturedPhotoPath;
  List<Player> players = []; // Track the list of players
  late Game game;
  late Stream<List<Player>> playerStream;
  late Stream<Game> gameStream;
  late Stream<Round> roundStream;

  int _roundNumber = 1;
  int _timerDuration = 10;
  late Timer _timer;
  String _pov = '';
  bool captured = false;

  @override
  void initState() {
    super.initState();

    // Initialize global lifecycle service
    LifecycleService().initialize(
      userId: widget.currentPlayerId,
      gameCode: widget.gameCode,
    );
    _attemptCameraInitialization();

    // Initialize the player stream
    playerStream = _playerRepository.listenToPlayers(widget.gameCode);
    // Initialize the game stream
    gameStream = _gameRepository.listenToGame(widget.gameCode);

    roundStream = _roundRepository.listenToRound(widget.gameCode, _roundNumber);

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

    roundStream.listen((updatedRound) async {
      if (updatedRound.status == 'completed') {
        _startNewRound();
      }
    });
  }

  Future<void> _fetchPov() async {
    _pov = await _gameDataRepository.getRandomPov() ?? '';
  }

  void _startNewRound() {
    setState(() {
      captured = false;
      _roundNumber++;
      _capturedPhotoPath = null;
      _timerDuration = game.timePerRound;
    });

    _timer.cancel();
    _fetchPov();
    _startTimer();
    _addRound();
  }

  Future<void> _attemptCameraInitialization({int retries = 5}) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        await _initializeCamera();

        // Camera initialized successfully, proceed with the game
        _startTimer();
        _fetchPov();
        _addRound();

        return;
      } catch (e) {
        debugPrint('Attempt $attempt: Failed to initialize camera: $e');

        if (attempt == retries) {
          _showCameraErrorDialog();
        } else {
          await Future.delayed(const Duration(seconds: 2)); // Retry delay
        }
      }
    }
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
      setState(() {});
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

  void _startTimer() async {
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

  void _endRound() async {
    if (_timer.isActive) {
      _timer.cancel(); // Stop the timer before navigation
    }

    if (!captured) await _capturePhoto();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VotingScreen(
          gameCode: game.gameCode,
          currentUserId: widget.currentPlayerId,
          isCreator: widget.isCreator,
          roundNumber: _roundNumber,
          onRoundComplete: () {
            if (_roundNumber > game.numberOfRounds) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(players: players),
                ),
              );
            }
            _startNewRound();
          },
        ),
      ),
    );
  }

  Future<void> _capturePhoto() async {
    try {
      await _initializeControllerFuture;
      final photo = await _cameraController.takePicture();
      setState(() {
        _capturedPhotoPath = photo.path;
        captured = true;
      });

      await _uploadPhoto(photo);
    } catch (e) {
      debugPrint('Error capturing photo: $e');
    }
  }

  Future<void> _savePhotoToFirestore(String photoUrl) async {
    await _photoRepository.savePhotoToFirestore(photoUrl, widget.gameCode,
        _roundNumber.toString(), widget.currentPlayerId);
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
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Game Screen - Round $_roundNumber'),
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TimerWidget(
                      roundNumber: _roundNumber,
                      timerDuration: _timerDuration,
                    )
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
                      if (snapshot.connectionState == ConnectionState.done &&
                          _cameraController.value.isInitialized) {
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
              if (!captured)
                ElevatedButton(
                  onPressed: _capturePhoto,
                  child: const Text('Capture Photo'),
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

  void _showCameraErrorDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Camera Error"),
        content: const Text(
            "Failed to initialize the camera. Please check permissions and try again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _attemptCameraInitialization(); // Retry when user presses OK
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
