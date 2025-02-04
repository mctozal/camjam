import 'package:camjam/core/models/user.dart';
import 'package:camjam/core/services/user_service.dart';
import 'package:camjam/features/game/data/models/player.dart';
import 'package:camjam/features/game/data/repositories/game_repository.dart';
import 'package:camjam/features/game/data/repositories/player_repository.dart';
import 'package:camjam/features/game/presentation/pages/waiting_room_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JoinGameDialog extends StatefulWidget {
  @override
  _JoinGameDialogState createState() => _JoinGameDialogState();
}

class _JoinGameDialogState extends State<JoinGameDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  UserService userService = UserService();
  final PlayerRepository _playerRepository = PlayerRepository();
  final GameRepository _gameRepository = GameRepository();

  String userId = '';
  String userName = '';

  Future<void> fetchUserCode() async {
    var user = await userService.getCurrentUser();
    if (user != null) {
      userId = user.id;
      userName = user.username;
    }
  }

  Future<bool> isAvailable(String gameCode) async {
    return await _gameRepository.getGameStatus(gameCode) == 'waiting';
  }

  Future<void> addNewPlayer(String gameCode) async {
    _playerRepository.addPlayer(
        gameCode,
        Player(
            id: userId,
            name: userName,
            joinedAt: Timestamp.now(),
            status: 'active'));
  }

  @override
  void initState() {
    super.initState();
    fetchUserCode(); // Fetch user ID when initializing
  }

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

  void _joinGame(BuildContext context, String code) async {
    // TODO: Validate the code against the backend or database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Joining game with code: $code')),
    );

    // Navigate to the game page
    Navigator.of(context).pop(); // Close the dialog

    bool active = await isAvailable(code);

    if (active) {
      addNewPlayer(code);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WaitingRoomScreen(
            currentUserId: userId,
            gameCode: code,
            isCreator: false,
          ),
        ),
      );
    } else {
      // Show a message if the game is not active
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('This game is no longer available or has started')),
      );
    }
  }
}
