import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/game_state.dart';

class GameCubit extends Cubit<GameState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GameCubit()
      : super(GameState(
          roundNumber: 1,
          pov: 'Strike your best superhero pose!',
          photoUrls: [],
          scores: {},
        ));

  void startNewRound() async {
    final nextRound = state.roundNumber + 1;

    await _firestore.collection('rounds').doc('round_$nextRound').set({
      'roundNumber': nextRound,
      'sentence': getRandomSentence(),
      'photoUrls': [],
      'scores': {},
    });

    emit(state.copyWith(
      roundNumber: nextRound,
      pov: getRandomSentence(),
      photoUrls: [],
    ));
  }

  void addPhoto(String photoPath) async {
    final updatedPhotos = List<String>.from(state.photoUrls)..add(photoPath);

    await _firestore
        .collection('rounds')
        .doc('round_${state.roundNumber}')
        .update({
      'photoUrls': updatedPhotos,
    });

    emit(state.copyWith(photoUrls: updatedPhotos));
  }

  void addScore(String playerName) async {
    final updatedScores = Map<String, int>.from(state.scores);
    updatedScores[playerName] = (updatedScores[playerName] ?? 0) + 1;

    await _firestore
        .collection('rounds')
        .doc('round_${state.roundNumber}')
        .update({
      'scores': updatedScores,
    });

    emit(state.copyWith(scores: updatedScores));
  }

  String getRandomSentence() {
    final sentences = [
      'Make your best “I just won the lottery” face!',
      'Pretend you’re falling off a cliff!',
      'Imitate your favorite celebrity!',
    ];
    sentences.shuffle();
    return sentences.first;
  }
}
