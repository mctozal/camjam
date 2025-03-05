import 'package:camjam/core/services/user_service.dart';
import 'package:flutter/material.dart';

class NameUpdateDialog extends StatefulWidget {
  final VoidCallback onComplete;
  NameUpdateDialog({required this.onComplete, super.key});

  @override
  _NameUpdateDialogState createState() => _NameUpdateDialogState();
}

Future<void> _updateName(String name, VoidCallback onComplete) async {
  final UserService userService = UserService();
  await userService.updateUserField('username', name);
  onComplete();
}

class _NameUpdateDialogState extends State<NameUpdateDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Name'),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(hintText: 'Enter name'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            // Handle the name update logic here
            _updateName(_nameController.text, widget.onComplete);
            Navigator.of(context).pop();
          },
          child: Text(
            'Update',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
