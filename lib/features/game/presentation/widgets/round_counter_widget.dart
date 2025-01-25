import 'package:flutter/material.dart';

class RoundCounter extends StatefulWidget {
  @override
  _RoundCounterState createState() => _RoundCounterState();
}

class _RoundCounterState extends State<RoundCounter> {
  int _currentRound = 1;

  void _incrementRound() {
    setState(() {
      _currentRound++;
    });
  }

  void _decrementRound() {
    setState(() {
      if (_currentRound > 1) {
        _currentRound--;
      }
    });
  }

  void _resetRound() {
    setState(() {
      _currentRound = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Round Counter'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the current round
            Text(
              'Round $_currentRound',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _decrementRound,
                  child: const Text('-'),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _incrementRound,
                  child: const Text('+'),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Reset button
            ElevatedButton(
              onPressed: _resetRound,
              child: const Text('Reset'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RoundCounter(),
  ));
}
