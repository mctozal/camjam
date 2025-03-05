import 'dart:math';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:camjam/core/services/user_service.dart';
import 'package:camjam/features/dashboard/presentation/pages/about_screen.dart';
import 'package:camjam/features/game/data/models/game.dart';
import 'package:camjam/features/game/data/models/player.dart';
import 'package:camjam/features/game/data/repositories/game_repository.dart';
import 'package:camjam/features/game/data/repositories/player_repository.dart';
import 'package:camjam/features/game/presentation/pages/waiting_room_screen.dart';
import 'package:camjam/features/user/presentation/pages/user_avatar_screen.dart';
import 'package:camjam/features/user/presentation/widgets/name_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.toUpperCase();
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GameRepository _gameRepository = GameRepository();
  final PlayerRepository _playerRepository = PlayerRepository();
  final UserService _userService = UserService();

  double _timePerRound = 10;
  double _numberOfRounds = 5;
  String? _gameCode;
  String userId = '';
  String userName = '';
  String avatar = 'avatar_0.png';

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    var user = await _userService.getCurrentUser();
    if (user != null) {
      setState(() {
        userId = user.id;
        userName = user.username;
        avatar = user.selectedImage ?? 'avatar_0.png';
      });
    }
  }

  void _generateGameCode() {
    setState(() {
      _gameCode = (Random().nextInt(90000) + 10000).toString();
    });
  }

  Future<void> _createGame() async {
    _generateGameCode();

    if (userId.isEmpty) return;

    Game game = Game(
      gameCode: _gameCode!,
      timePerRound: _timePerRound.toInt(),
      numberOfRounds: _numberOfRounds.toInt(),
      creatorId: userId,
      createdAt: Timestamp.now(),
      pov: '',
      status: 'waiting',
      currentRound: 1,
      roundPhase: 'counter',
    );

    await _gameRepository.addGame(game);
    await _playerRepository.addPlayer(
      _gameCode!,
      Player(
        id: userId,
        name: userName,
        joinedAt: Timestamp.now(),
        avatar: avatar,
        status: 'active',
      ),
    );

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnimatedSplashScreen(
            splash: Center(
              child: Lottie.asset('lib/assets/splash_animation.json'),
            ),
            nextScreen: WaitingRoomScreen(
                gameCode: _gameCode!,
                currentUserId: userId,
                isCreator: true), // Pass the nextScreen dynamically
            splashTransition: SplashTransition.scaleTransition,
            splashIconSize: 200,
            backgroundColor: Colors.black,
          ),
        ));
  }

  Future<void> _joinGame() async {
    if (_formKey.currentState!.validate()) {
      String code = _codeController.text;
      bool active = await _gameRepository.getGameStatus(code) == 'waiting';

      if (active) {
        await _playerRepository.addPlayer(
          code,
          Player(
              id: userId,
              name: userName,
              avatar: avatar,
              joinedAt: Timestamp.now(),
              status: 'active'),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('This game is no longer available or has started')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'lib/assets/logo-small.png',
                  height: 50,
                ),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutScreen(),
                        ),
                      );
                    },
                    icon:
                        ImageIcon(AssetImage('lib/assets/question_icon.png'))),
                IconButton(
                    onPressed: () {},
                    icon: ImageIcon(AssetImage('lib/assets/heart_icon.png'))),
                IconButton(
                    onPressed: () {},
                    icon:
                        ImageIcon(AssetImage('lib/assets/currency_icon.png'))),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Welcome,',
                  style: TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return NameUpdateDialog(onComplete: () {
                          _fetchUserDetails();
                        });
                      },
                    );
                  },
                  child: Text(userName,
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis)),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserAvatarScreen(
                      userName: userName,
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('lib/assets/' + avatar),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: Form(
                key: _formKey,
                child: TextFormField(
                  inputFormatters: [
                    UpperCaseTextFormatter(), // Forces uppercase input
                  ],
                  controller: _codeController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter a Lobby Code'),
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter a code';
                    if (value.length != 5 || int.tryParse(value) == null)
                      return 'Enter a valid 5-digit code';
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _joinGame,
                child: Text('JOIN A GAME'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
              ),
            ),
            SizedBox(height: 48),
            Text('OR', style: TextStyle(fontSize: 24)),
            SizedBox(height: 48),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 150,
                        child: Text('Round', // Fixed width for alignment
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                    ToggleButtons(
                      isSelected: [
                        _numberOfRounds == 3,
                        _numberOfRounds == 5,
                        _numberOfRounds == 10
                      ],
                      borderRadius: BorderRadius.circular(10),
                      onPressed: (index) {
                        setState(() {
                          _numberOfRounds = [3, 5, 10][index].toDouble();
                        });
                      },
                      constraints: BoxConstraints(minWidth: 50),
                      children: const [
                        Text(
                          '3',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('5',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            )),
                        Text('10',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 150,
                        child: Text(
                            'Time Per Round', // Fixed width for alignment
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(10),
                      constraints: BoxConstraints(minWidth: 50),
                      isSelected: [
                        _timePerRound == 10,
                        _timePerRound == 15,
                        _timePerRound == 20
                      ],
                      onPressed: (index) {
                        setState(() {
                          _timePerRound = [10, 15, 20][index].toDouble();
                        });
                      },
                      children: const [
                        Text('10',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('15',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('20',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFF4E0F97)),
                ),
                onPressed: _createGame,
                child:
                    Text('CREATE A NEW GAME', style: TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }
}
