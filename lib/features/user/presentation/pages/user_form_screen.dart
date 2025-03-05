import 'package:camjam/core/models/User.dart';
import 'package:camjam/core/services/user_service.dart';
import 'package:camjam/features/user/presentation/pages/user_avatar_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/user_input_form.dart';

class UserFormScreen extends StatefulWidget {
  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final UserService _userService = UserService();
  String _gender = 'Male'; // Default value
  int? _age;

  void _onGenderChanged(String gender) {
    setState(() {
      _gender = gender;
    });
  }

  void _onAgeSaved(int age) {
    _age = age;
  }

  Future<void> _saveUserToFirestore() async {
    User userData = User(
        username: _usernameController.text,
        gender: _gender,
        age: _age,
        selectedImage: null,
        createdAt: Timestamp.now(), // Add timestamp
        id: '');

    try {
      await _userService.addUser(userData);
      print('User added to Firestore: $userData');
    } catch (e) {
      print('Error saving user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save user data.')),
      );
    }
  }

  void _navigateToAvatarSelection(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _saveUserToFirestore(); // Save user to Firestore
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return UserAvatarScreen(
          userName: _usernameController.text,
        );
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(80, 100, 80, 100),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: Image.asset(
                  'lib/assets/logo-big.png', // Eğer PNG kullanıyorsan: Image.asset('assets/images/logo.png')
                  height: 300,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: UserInputForm(
                formKey: _formKey,
                usernameController: _usernameController,
                onGenderChanged: _onGenderChanged,
                onAgeSaved: _onAgeSaved,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width * 0.6,
                    50), // 60% of screen width, height: 50
                maximumSize: Size(MediaQuery.of(context).size.width * 1.2,
                    60), // 80% of screen width, height: 60
                backgroundColor: Colors.green,
              ),
              onPressed: () => _navigateToAvatarSelection(context),
              child: Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
