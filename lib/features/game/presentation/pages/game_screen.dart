import 'dart:async';
import 'dart:io';
import 'package:camjam/features/game/data/models/player.dart';
import 'package:camjam/features/game/presentation/pages/voting_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class GameScreen extends StatefulWidget {
  final List<Player> players; // List of players with their scores
  final String currentPlayerId; // ID of the current player
  final int numberOfRounds;
  final int timePerRound;

  GameScreen(
      {required this.players,
      required this.currentPlayerId,
      required this.numberOfRounds,
      required this.timePerRound});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  String? _capturedPhotoPath;

  int _roundNumber = 1;
  int _timerDuration = 10;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _requestPermissions().then((_) => _initializeCamera());
    _startTimer();
  }

  Future<void> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception("No cameras available");
      }

      final frontCamera = cameras[1];
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

    // Navigate to Voting Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VotingScreen(
          players: widget.players,
          currentPlayerId: widget.currentPlayerId,
          capturedPhotoPath: _capturedPhotoPath,
          onRoundComplete: () {
            // Prepare for the next round
            setState(() {
              _roundNumber++;
              if (_roundNumber > widget.numberOfRounds) print('game is over');
              _timerDuration = widget.timePerRound;
            });
            _startTimer();
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
      });
    } catch (e) {
      print('Error capturing photo: $e');
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
          if (_cameraController.value.isInitialized)
            AspectRatio(
              aspectRatio: _cameraController.value.aspectRatio,
              child: CameraPreview(_cameraController),
            )
          else
            const Center(child: CircularProgressIndicator()),
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
