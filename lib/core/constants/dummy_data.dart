import 'package:camjam/features/game/data/models/player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final dummyPlayers = [
  Player(
      id: 'player1',
      name: 'Player 1',
      score: 0,
      joinedAt: Timestamp.now(),
      status: 'active'),
  Player(
      id: 'player2',
      name: 'Player 2',
      score: 0,
      joinedAt: Timestamp.now(),
      status: 'active'),
  Player(
      id: 'player3',
      name: 'Player 3',
      score: 0,
      joinedAt: Timestamp.now(),
      status: 'active'),
];
