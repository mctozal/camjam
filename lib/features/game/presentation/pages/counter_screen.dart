import 'dart:async';
import 'package:flutter/material.dart';

class CounterScreen extends StatefulWidget {
  final int roundNumber;
  final VoidCallback onCountdownComplete;

  const CounterScreen({
    required this.roundNumber,
    required this.onCountdownComplete,
    super.key,
  });

  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        if (mounted) {
          setState(() {
            _countdown--;
          });
        }
      } else {
        timer.cancel();
        widget.onCountdownComplete();
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
        child: Text('Round ${widget.roundNumber}: $_countdown'),
      ),
    );
  }
}
