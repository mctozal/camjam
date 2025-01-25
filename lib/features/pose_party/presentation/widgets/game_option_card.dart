import 'package:flutter/material.dart';

class GameOptionCard extends StatefulWidget {
  final String title;
  final String description;
  final double min;
  final double max;
  final double initialValue;
  final String unit; // Unit to display (e.g., "seconds", "rounds")
  final Function(double) onValueChanged;

  GameOptionCard({
    required this.title,
    required this.description,
    required this.min,
    required this.max,
    required this.initialValue,
    required this.unit,
    required this.onValueChanged,
  });

  @override
  _GameOptionCardState createState() => _GameOptionCardState();
}

class _GameOptionCardState extends State<GameOptionCard> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              widget.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            // Slider Widget
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_currentValue.toInt()} ${widget.unit}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: _currentValue,
                  min: widget.min,
                  max: widget.max,
                  divisions: (widget.max - widget.min).toInt(),
                  label: _currentValue.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _currentValue = value;
                    });
                    widget.onValueChanged(value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
