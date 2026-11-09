import '../theme/stroop_colors.dart';

class TrialModel {
  final int trialNumber; // 1 to 30
  final bool isPractice; // 1-10 practice, 11-30 scored
  final StroopItem word;
  final StroopItem inkColor;
  final StroopItem? selectedColor;
  final int reactionTimeMs;
  final bool isCorrect;
  final bool isTimeout;

  TrialModel({
    required this.trialNumber,
    required this.isPractice,
    required this.word,
    required this.inkColor,
    this.selectedColor,
    required this.reactionTimeMs,
    required this.isCorrect,
    required this.isTimeout,
  });

  bool get isCongruent => word == inkColor;

  Map<String, dynamic> toJson() => {
        'trialNumber': trialNumber,
        'isPractice': isPractice,
        'word': word.name,
        'inkColor': inkColor.name,
        'selectedColor': selectedColor?.name,
        'reactionTimeMs': reactionTimeMs,
        'isCorrect': isCorrect,
        'isTimeout': isTimeout,
      };

  factory TrialModel.fromJson(Map<String, dynamic> json) => TrialModel(
        trialNumber: json['trialNumber'] as int,
        isPractice: json['isPractice'] as bool,
        word: StroopItem.values.firstWhere((e) => e.name == json['word']),
        inkColor: StroopItem.values.firstWhere((e) => e.name == json['inkColor']),
        selectedColor: json['selectedColor'] != null
            ? StroopItem.values.firstWhere((e) => e.name == json['selectedColor'])
            : null,
        reactionTimeMs: json['reactionTimeMs'] as int,
        isCorrect: json['isCorrect'] as bool,
        isTimeout: json['isTimeout'] as bool,
      );
}
