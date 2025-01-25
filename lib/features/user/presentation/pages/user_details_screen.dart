import 'package:flutter/material.dart';

class UserDetailsScreen extends StatelessWidget {
  final String username;
  final String gender;
  final int age;

  UserDetailsScreen({
    required this.username,
    required this.gender,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Username: $username',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Gender: $gender',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Age: $age',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
