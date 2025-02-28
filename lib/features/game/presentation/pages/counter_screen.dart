import 'dart:async';
import 'package:flutter/material.dart';

class CounterScreen extends StatefulWidget {
  final int roundNumber;
  final VoidCallback onCountdownComplete;

  const CounterScreen({
    super.key,
    required this.roundNumber,
    required this.onCountdownComplete,
  });

  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 5; // Start from 5
  late Timer _countdownTimer; // Store the timer to cancel it later

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter == 1) {
        timer.cancel();
        widget.onCountdownComplete(); // Move to the next screen
      } else if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _counter--;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                'lib/assets/logo-big.png', // Game logo
                height: 100,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Round ${widget.roundNumber}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Starts in $_counter',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
