import 'package:camjam/core/services/user_service.dart';
import 'package:camjam/features/user/presentation/widgets/image_carousel.dart';
import 'package:flutter/material.dart';

class UserAvatarScreen extends StatefulWidget {
  final String userName;

  const UserAvatarScreen({super.key, required this.userName});

  @override
  _UserAvatarScreenState createState() => _UserAvatarScreenState();
}

class _UserAvatarScreenState extends State<UserAvatarScreen> {
  String? selectedImageIndex; // Store the selected image index
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'lib/assets/logo-small.png',
              height: 50,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome,',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  widget.userName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Choose your avatar',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20), // Adds spacing
            SizedBox(
              height: 300,
              width: 600,
              child: ImageCarousel(
                onImageSelected: (index) {
                  setState(() {
                    selectedImageIndex =
                        index; // Store the selected image index
                  });
                },
              ),
            ),
            SizedBox(height: 30), // Adds spacing
            ElevatedButton(
              onPressed: () {
                if (selectedImageIndex != null) {
                  // Proceed with the selected image
                  _userService.updateUserField(
                      'selectedImage', selectedImageIndex);
                  Navigator.pushReplacementNamed(context,
                      '/dashboard'); // Navigate to the dashboard screen
                } else {
                  // Show a message to select an image
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.green),
              ),
              child: Text("That's it"),
            ),
          ],
        ),
      ),
    );
  }
}
