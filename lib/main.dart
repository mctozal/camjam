import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'features/user/presentation/pages/user_form_screen.dart';
import 'features/dashboard/presentation/pages/dashboard_screen.dart';
import 'theme.dart';
import 'package:camjam/core/state/game_state.dart';

void main() async {
  Provider.debugCheckInvalidValueType = null;

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final userHashId = prefs.getString('userHashId');

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => GameState())],
      child: SelfieGameApp(userHashId: userHashId),
    ),
  );
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
      initialRoute: userHashId == null ? '/' : '/dashboard',
      routes: {
        '/': (context) => UserFormScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}
