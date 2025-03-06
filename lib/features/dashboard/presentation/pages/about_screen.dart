import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Positioned(
          left: 10,
          child: Image.asset(
            'lib/assets/logo-small.png', // Replace with your small logo path
            height: 50, // Adjust height as needed
          ),
        ),
        // Optional: Match your app’s theme
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20), // Space from app bar
              const Text(
                'Who we are?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30), // Space before paragraph
              Padding(
                padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                child: const Text(
                  'We are a couple. A Computer Engineer husband. UI / UX Designer wife. We just wanted to make you smile cnm. Bla bla bla.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Image.asset('lib/assets/heart_icon_purple.png'),
              const SizedBox(height: 30),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left column: Picture
                      Container(
                        width: MediaQuery.of(context).size.width *
                            0.4, // 40% of screen width
                        height: 250, // Fixed height, adjust as needed
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors
                                  .grey), // Optional: Add border for visibility
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'lib/assets/yagmur.png', // Replace with your image path
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                  child: Text('Image not found'));
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16), // Spacing between columns
                      // Right column: Text (Yağmur Tozal)
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.4, // 40% of screen width
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Yağmur Tozal',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8), // Space after name
                            Text(
                              'We are a couple. A Computer Engineer husband. UI / UX Designer wife. We just wanted to make you smile cnm. Bla bla bla.',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left column: Picture
                      Container(
                        width: MediaQuery.of(context).size.width *
                            0.4, // 40% of screen width
                        height: 250, // Fixed height, adjust as needed
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors
                                  .grey), // Optional: Add border for visibility
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'lib/assets/mucahit.png', // Replace with your image path
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                  child: Text('Image not found'));
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.4, // 40% of screen width
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Mucahit Tozal',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8), // Space after name
                            Text(
                              'We are a couple. A Computer Engineer husband. UI / UX Designer wife. We just wanted to make you smile cnm. Bla bla bla.',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
