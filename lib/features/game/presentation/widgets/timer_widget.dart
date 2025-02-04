import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int roundNumber;
  final int timerDuration;

  const TimerWidget({required this.roundNumber, required this.timerDuration});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Round: $roundNumber',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text('Time: $timerDuration s',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
      ],
    );
  }
}
