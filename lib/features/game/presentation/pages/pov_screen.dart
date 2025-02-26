import 'dart:async';
import 'package:flutter/material.dart';

class PoseScreen extends StatefulWidget {
  final VoidCallback onPoseComplete;
  final String pose;

  const PoseScreen(
      {super.key, required this.onPoseComplete, required this.pose});

  @override
  _PoseScreenState createState() => _PoseScreenState();
}

class _PoseScreenState extends State<PoseScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  void _startProgress() {
    Timer.periodic(Duration(milliseconds: 300), (timer) {
      if (_progress >= 1.0) {
        timer.cancel();
        widget.onPoseComplete(); // Move to game screen
      } else {
        setState(() {
          _progress += 0.1;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          Expanded(
            child: Center(
              child: Text(
                widget.pose,
                style: TextStyle(
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
