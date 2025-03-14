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
    super.key,
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
    _initializeCamera().then((_) => _startCountdownTimer());
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
      await _cameraController?.setFlashMode(FlashMode.off);

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Failed to initialize camera: $e');
      if (mounted) _showCameraErrorDialog();
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
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingTime > 0) {
        if (mounted) {
          setState(() {
            _remainingTime--;
          });
        }
      } else {
        timer.cancel();
        if (!_captured && !_isCapturing) {
          await _capturePhoto(); // Capture automatically if not done
        }
        if (mounted) {
          widget.onPhotoCaptured(); // Trigger callback when timer ends
        }
      }
    });
  }

  int _getInitialRemainingTime(Game game) {
    if (game.phaseStartTime == null) return 0;
    final startTime = game.phaseStartTime!.toDate();
    final now = DateTime.now();
    final elapsed = now.difference(startTime).inSeconds;
    return (game.timePerRound - elapsed).clamp(0, game.timePerRound);
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '$_remainingTime',
                    style: const TextStyle(
                      fontSize: 55,
                      overflow: TextOverflow.ellipsis,
                      color: Colors.red,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.game.currentRound.toString(),
                    style: const TextStyle(
                      fontSize: 30,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          if (_capturedPhotoPath != null)
            Transform.scale(
              scale: 1,
              alignment: Alignment.topCenter,
              child: Image.file(
                File(_capturedPhotoPath!),
                fit: BoxFit.cover,
                width: mediaSize.width,
                height: mediaSize.height,
              ),
            )
          else
            Expanded(
              child: FutureBuilder<void>(
                future: _initializeControllerFuture, // Corrected here
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      _cameraController != null &&
                      _cameraController!.value.isInitialized) {
                    return ClipRect(
                      clipper: _MediaSizeClipper(mediaSize),
                      child: Transform.scale(
                        scale: 1,
                        alignment: Alignment.topCenter,
                        child: CameraPreview(_cameraController!),
                      ),
                    );
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
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.game.pov,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 60), // Fix this typo later
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_captured)
              ElevatedButton(
                onPressed: _isCapturing ? null : _capturePhoto,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.white,
                  elevation: 10,
                ),
                child: const Icon(
                  Icons.circle,
                  size: 40,
                  color: Colors.white,
                ),
              ),
          ],
        ),
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

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
