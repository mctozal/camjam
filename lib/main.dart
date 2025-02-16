import 'package:camjam/core/services/permission_service.dart';
import 'package:camjam/features/user/presentation/pages/user_avatar_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'features/user/presentation/pages/user_form_screen.dart';
import 'features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

void main() async {
  PermissionService permissionService = PermissionService();

  permissionService.requestPermissions();

  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures binding is ready for Firebase

  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Use platform-specific config
  );

  // Check if user exists
  final prefs = await SharedPreferences.getInstance();
  final userHashId = prefs.getString('userHashId'); // Retrieve userHashId

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(SelfieGameApp(userHashId: userHashId));
  });
}

class SelfieGameApp extends StatelessWidget {
  final String? userHashId;

  const SelfieGameApp({super.key, required this.userHashId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cam Jam',
      theme: darkTheme,
      initialRoute:
          userHashId == null ? '/' : '/dashboard', // Check if userHashId exists
      routes: {
        '/': (context) => UserFormScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}
