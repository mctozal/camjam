import 'package:camjam/features/join_game/presentation/pages/game_screen.dart';
import 'package:flutter/material.dart';

class JoinGameDialog extends StatefulWidget {
  @override
  _JoinGameDialogState createState() => _JoinGameDialogState();
}

class _JoinGameDialogState extends State<JoinGameDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Join a Game'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _codeController,
          decoration: InputDecoration(
            labelText: 'Enter 5-Digit Code',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          maxLength: 5,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a code';
            }
            if (value.length != 5 || int.tryParse(value) == null) {
              return 'Enter a valid 5-digit code';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _joinGame(context, _codeController.text);
            }
          },
          child: Text('Join'),
        ),
      ],
    );
  }

  void _joinGame(BuildContext context, String code) {
    // TODO: Validate the code against the backend or database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Joining game with code: $code')),
    );

    // Navigate to the game page
    Navigator.of(context).pop(); // Close the dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(gameCode: code),
      ),
    );
  }
}
