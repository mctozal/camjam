import 'dart:async';
import 'package:flutter/material.dart';

class PoseScreen extends StatefulWidget {
  final VoidCallback onPoseComplete;
  final String pose;

  const PoseScreen({
    super.key,
    required this.onPoseComplete,
    required this.pose,
  });

  @override
  _PoseScreenState createState() => _PoseScreenState();
}

class _PoseScreenState extends State<PoseScreen> {
  double _progress = 0.0;
  late Timer _progressTimer; // Store the timer to cancel it later

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  void _startProgress() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (_progress >= 1.0) {
        timer.cancel();
        widget.onPoseComplete(); // Move to the next screen
      } else if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _progress += 0.1;
        });
      }
    });
  }

  @override
  void dispose() {
    _progressTimer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4E0F97)),
          ),
          Expanded(
            child: Center(
              child: Text(
                widget.pose,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
