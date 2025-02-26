import 'dart:async';
import 'package:flutter/material.dart';

class PoseScreen extends StatefulWidget {
  final String pose;
  final VoidCallback onPoseComplete;

  const PoseScreen({
    required this.pose,
    required this.onPoseComplete,
    super.key,
  });

  @override
  _PoseScreenState createState() => _PoseScreenState();
}

class _PoseScreenState extends State<PoseScreen> {
  int _progress = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  void _startProgress() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_progress > 0) {
        if (mounted) {
          setState(() {
            _progress--;
          });
        }
      } else {
        timer.cancel();
        widget.onPoseComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.pose, style: const TextStyle(fontSize: 24)),
            Text('Time left: $_progress s'),
          ],
        ),
      ),
    );
  }
}
