import 'dart:async';
import 'dart:io';
import 'package:camjam/core/services/lifecycle_service.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:camjam/core/services/storage_service.dart';
import 'package:camjam/features/game/data/models/game.dart';
import 'package:camjam/features/game/data/repositories/photo_repository.dart';
import 'package:path/path.dart' as path;

class PhotoScreen extends StatefulWidget {
  final String gameCode;
  final String currentPlayerId;
  final bool isCreator;
  final Game game;
  final VoidCallback onPhotoCaptured;

  const PhotoScreen({
    required this.gameCode,
    required this.currentPlayerId,
    required this.isCreator,
    required this.game,
    required this.onPhotoCaptured,
  });

  @override
  PhotoScreenState createState() => PhotoScreenState();
}

class PhotoScreenState extends State<PhotoScreen> {
  final StorageService _storageService = StorageService();
  final PhotoRepository _photoRepository = PhotoRepository();
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  String? _capturedPhotoPath;
  bool _captured = false;
  bool _isCapturing = false;
  late int _remainingTime;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    LifecycleService().initialize(
      userId: widget.currentPlayerId,
      gameCode: widget.gameCode,
    );
    _remainingTime = _getInitialRemainingTime(widget.game);
    _initializeCamera().then((s) => _startCountdownTimer());
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception("No cameras available");

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      _cameraController =
          CameraController(frontCamera, ResolutionPreset.medium);
      _initializeControllerFuture = _cameraController!.initialize();
      await _initializeControllerFuture;

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Failed to initialize camera: $e');

      if (mounted) {
        _showCameraErrorDialog();
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      _isCapturing = true;
      final photo = await _cameraController!.takePicture();
      if (mounted) {
        setState(() {
          _capturedPhotoPath = photo.path;
          _captured = true;
        });
      }
      await _uploadPhoto(photo);
      widget.onPhotoCaptured();
    } catch (e) {
      debugPrint('Error capturing photo: $e');
    } finally {
      _isCapturing = false;
    }
  }

  Future<void> _uploadPhoto(XFile photo) async {
    final File imageFile = File(photo.path);
    final String fileName = path.basename(photo.path);
    final String folderPath = 'game_photos/${widget.gameCode}/$fileName';
    String url =
        await _storageService.uploadPhoto(imageFile, folderPath, fileName);
    await _photoRepository.savePhotoToFirestore(
      url,
      widget.gameCode,
      widget.game.currentRound.toString(),
      widget.currentPlayerId,
    );
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0 && !_captured) {
        setState(() {
          _remainingTime--;
        });
        if (_remainingTime <= 0 && !_isCapturing) {
          _capturePhoto();
        }
      } else {
        timer.cancel();
      }
    });
  }

  int _getInitialRemainingTime(Game game) {
    if (game.phaseStartTime == null || game.phaseDuration == null) return 0;
    final startTime = game.phaseStartTime!.toDate();
    final now = DateTime.now();
    final elapsed = now.difference(startTime).inSeconds;
    return (game.phaseDuration! - elapsed).clamp(0, game.phaseDuration!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Screen - Round ${widget.game.currentRound}'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Time left: $_remainingTime s'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(widget.game.pov),
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
                      _cameraController != null &&
                      _cameraController!.value.isInitialized) {
                    return CameraPreview(_cameraController!);
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Error initializing camera.',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          const Spacer(),
          if (!_captured)
            ElevatedButton(
              onPressed: _isCapturing ? null : _capturePhoto,
              child: const Text('Capture Photo'),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _cameraController?.dispose();
    LifecycleService().dispose();
    super.dispose();
  }

  void _showCameraErrorDialog() {
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
              _initializeCamera();
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
