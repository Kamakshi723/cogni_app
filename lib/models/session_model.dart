import 'trial_model.dart';

class SessionModel {
  final String id;
  final String userId;
  final String gameName;
  final int score;
  final int speed;
  final int accuracy;
  final int medianRT;
  final int levelBefore;
  final int levelAfter;
  final int levelChange; // -1: level down, 0: held, 1: level up
  final int totalTrials;
  final int scoredTrials;
  final int correctTrials;
  final int timeouts;
  final DateTime createdAt;
  final bool synced;
  final List<TrialModel> trials;

  SessionModel({
    required this.id,
    required this.userId,
    this.gameName = 'Colour Stroop',
    required this.score,
    required this.speed,
    required this.accuracy,
    required this.medianRT,
    required this.levelBefore,
    required this.levelAfter,
    required this.levelChange,
    this.totalTrials = 30,
    this.scoredTrials = 20,
    required this.correctTrials,
    required this.timeouts,
    required this.createdAt,
    this.synced = true,
    required this.trials,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'gameName': gameName,
        'score': score,
        'speed': speed,
        'accuracy': accuracy,
        'medianRT': medianRT,
        'levelBefore': levelBefore,
        'levelAfter': levelAfter,
        'levelChange': levelChange,
        'totalTrials': totalTrials,
        'scoredTrials': scoredTrials,
        'correctTrials': correctTrials,
        'timeouts': timeouts,
        'createdAt': createdAt.toIso8601String(),
        'synced': synced,
        'trials': trials.map((t) => t.toJson()).toList(),
      };

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        gameName: (json['gameName'] as String?) ?? 'Colour Stroop',
        score: json['score'] as int,
        speed: json['speed'] as int,
        accuracy: json['accuracy'] as int,
        medianRT: json['medianRT'] as int,
        levelBefore: json['levelBefore'] as int,
        levelAfter: json['levelAfter'] as int,
        levelChange: json['levelChange'] as int,
        totalTrials: (json['totalTrials'] as int?) ?? 30,
        scoredTrials: (json['scoredTrials'] as int?) ?? 20,
        correctTrials: json['correctTrials'] as int,
        timeouts: json['timeouts'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        synced: (json['synced'] as bool?) ?? true,
        trials: (json['trials'] as List<dynamic>?)
                ?.map((t) => TrialModel.fromJson(t as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
