import 'package:camjam/features/game/presentation/pages/voting_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'features/user/presentation/pages/user_form_screen.dart';
import 'features/dashboard/presentation/pages/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures binding is ready for Firebase
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Use platform-specific config
  );

  runApp(SelfieGameApp());
}

class SelfieGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cam Jam',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => UserFormScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}
