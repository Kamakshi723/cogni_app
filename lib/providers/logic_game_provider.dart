import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/session_model.dart';
import '../models/trial_model.dart';
import '../services/sound_haptic_service.dart';
import '../services/storage_service.dart';
import '../theme/stroop_colors.dart';

enum LogicShape {
  circle,
  square,
  triangle,
  diamond,
  star,
}

enum LogicColor {
  purple,
  emerald,
  amber,
  cyan,
}

enum LogicRule {
  color,
  shape,
  count,
}

class LogicCard {
  final LogicShape shape;
  final LogicColor color;
  final int count; // 1 to 4

  const LogicCard({
    required this.shape,
    required this.color,
    required this.count,
  });

  Color get displayColor {
    switch (color) {
      case LogicColor.purple:
        return const Color(0xFF8B5CF6);
      case LogicColor.emerald:
        return const Color(0xFF10B981);
      case LogicColor.amber:
        return const Color(0xFFF59E0B);
      case LogicColor.cyan:
        return const Color(0xFF06B6D4);
    }
  }

  String get colorName {
    switch (color) {
      case LogicColor.purple:
        return 'Purple';
      case LogicColor.emerald:
        return 'Emerald';
      case LogicColor.amber:
        return 'Amber';
      case LogicColor.cyan:
        return 'Cyan';
    }
  }

  String get shapeName {
    switch (shape) {
      case LogicShape.circle:
        return 'Circle';
      case LogicShape.square:
        return 'Square';
      case LogicShape.triangle:
        return 'Triangle';
      case LogicShape.diamond:
        return 'Diamond';
      case LogicShape.star:
        return 'Star';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogicCard &&
          runtimeType == other.runtimeType &&
          shape == other.shape &&
          color == other.color &&
          count == other.count;

  @override
  int get hashCode => shape.hashCode ^ color.hashCode ^ count.hashCode;
}

class LogicLevelConfig {
  final int level;
  final int trialDurationMs;
  final int choicesCount;
  final int switchEvery; // Switch rule every N trials (or 1 for random flux)
  final bool allowCountRule;
  final double speedFactor;

  const LogicLevelConfig({
    required this.level,
    required this.trialDurationMs,
    required this.choicesCount,
    required this.switchEvery,
    required this.allowCountRule,
    required this.speedFactor,
  });
}

class LogicGameProvider with ChangeNotifier {
  static const int totalTrialsCount = 14;
  static const int practiceTrialsCount = 2;
  static const int scoredTrialsCount = 12;
  static const int maxLevel = 15;

  static const Map<int, LogicLevelConfig> levelConfigs = {
    // Stage 1: Rule Ignition (Lv 1 - 5)
    1: LogicLevelConfig(level: 1, trialDurationMs: 2500, choicesCount: 3, switchEvery: 5, allowCountRule: false, speedFactor: 1.0),
    2: LogicLevelConfig(level: 2, trialDurationMs: 2350, choicesCount: 3, switchEvery: 4, allowCountRule: false, speedFactor: 1.1),
    3: LogicLevelConfig(level: 3, trialDurationMs: 2200, choicesCount: 3, switchEvery: 4, allowCountRule: true, speedFactor: 1.2),
    4: LogicLevelConfig(level: 4, trialDurationMs: 2100, choicesCount: 3, switchEvery: 3, allowCountRule: true, speedFactor: 1.3),
    5: LogicLevelConfig(level: 5, trialDurationMs: 2000, choicesCount: 3, switchEvery: 3, allowCountRule: true, speedFactor: 1.4),

    // Stage 2: Dynamic Switching (Lv 6 - 10)
    6: LogicLevelConfig(level: 6, trialDurationMs: 1850, choicesCount: 4, switchEvery: 3, allowCountRule: true, speedFactor: 1.55),
    7: LogicLevelConfig(level: 7, trialDurationMs: 1700, choicesCount: 4, switchEvery: 2, allowCountRule: true, speedFactor: 1.7),
    8: LogicLevelConfig(level: 8, trialDurationMs: 1600, choicesCount: 4, switchEvery: 2, allowCountRule: true, speedFactor: 1.85),
    9: LogicLevelConfig(level: 9, trialDurationMs: 1500, choicesCount: 4, switchEvery: 2, allowCountRule: true, speedFactor: 2.0),
    10: LogicLevelConfig(level: 10, trialDurationMs: 1400, choicesCount: 4, switchEvery: 2, allowCountRule: true, speedFactor: 2.15),

    // Stage 3: Multidimensional Flux (Lv 11 - 15)
    11: LogicLevelConfig(level: 11, trialDurationMs: 1300, choicesCount: 4, switchEvery: 1, allowCountRule: true, speedFactor: 2.3),
    12: LogicLevelConfig(level: 12, trialDurationMs: 1200, choicesCount: 4, switchEvery: 1, allowCountRule: true, speedFactor: 2.45),
    13: LogicLevelConfig(level: 13, trialDurationMs: 1100, choicesCount: 4, switchEvery: 1, allowCountRule: true, speedFactor: 2.6),
    14: LogicLevelConfig(level: 14, trialDurationMs: 1000, choicesCount: 4, switchEvery: 1, allowCountRule: true, speedFactor: 2.75),
    15: LogicLevelConfig(level: 15, trialDurationMs: 900, choicesCount: 4, switchEvery: 1, allowCountRule: true, speedFactor: 2.9),
  };

  // State
  int _currentLevel = 1;
  int _currentTrialIndex = 0; // 0 to 13
  bool _isPlaying = false;
  bool _isFinished = false;

  LogicRule _activeRule = LogicRule.color;
  LogicRule? _previousRule;
  bool _justSwitchedRule = false;
  int _trialsInCurrentRule = 0;

  late LogicCard _targetCard;
  List<LogicCard> _candidateCards = [];

  DateTime? _trialStartTime;
  Timer? _trialTimer;
  double _timerProgress = 1.0;

  bool _flashCorrect = false;
  bool _flashWrong = false;
  Timer? _flashTimer;

  // Performance recording
  final List<TrialModel> _recordedTrials = [];
  final List<int> _reactionTimesMs = [];
  final List<int> _switchReactionTimesMs = [];
  final List<int> _repeatReactionTimesMs = [];
  int _correctCount = 0;
  int _timeoutCount = 0;
  SessionModel? _lastCompletedSession;

  final Random _random = Random();

  // Getters
  int get currentLevel => _currentLevel;
  int get currentTrialNumber => _currentTrialIndex + 1;
  int get totalTrials => totalTrialsCount;
  bool get isPractice => _currentTrialIndex < practiceTrialsCount;
  bool get isPlaying => _isPlaying;
  bool get isFinished => _isFinished;

  LogicRule get activeRule => _activeRule;
  bool get justSwitchedRule => _justSwitchedRule;
  LogicCard get targetCard => _targetCard;
  List<LogicCard> get candidateCards => List.unmodifiable(_candidateCards);
  double get timerProgress => _timerProgress;
  bool get flashCorrect => _flashCorrect;
  bool get flashWrong => _flashWrong;
  SessionModel? get lastCompletedSession => _lastCompletedSession;

  Duration get currentTrialDuration {
    final cfg = levelConfigs[_currentLevel] ?? levelConfigs[1]!;
    return Duration(milliseconds: cfg.trialDurationMs);
  }

  void startBlock(int level) {
    _currentLevel = level.clamp(1, maxLevel);
    _currentTrialIndex = 0;
    _recordedTrials.clear();
    _reactionTimesMs.clear();
    _switchReactionTimesMs.clear();
    _repeatReactionTimesMs.clear();
    _correctCount = 0;
    _timeoutCount = 0;
    _lastCompletedSession = null;
    _isFinished = false;
    _isPlaying = true;

    // Initial random rule
    _activeRule = _random.nextBool() ? LogicRule.color : LogicRule.shape;
    _previousRule = null;
    _justSwitchedRule = false;
    _trialsInCurrentRule = 0;

    _generateTrial();
  }

  void _generateTrial() {
    _flashCorrect = false;
    _flashWrong = false;
    _flashTimer?.cancel();
    _trialTimer?.cancel();

    final cfg = levelConfigs[_currentLevel] ?? levelConfigs[1]!;

    // Rule Switch Logic
    if (_currentTrialIndex > 0) {
      if (_trialsInCurrentRule >= cfg.switchEvery) {
        // Force rule switch
        final availableRules = <LogicRule>[
          LogicRule.color,
          LogicRule.shape,
          if (cfg.allowCountRule) LogicRule.count,
        ]..remove(_activeRule);

        _previousRule = _activeRule;
        _activeRule = availableRules[_random.nextInt(availableRules.length)];
        _justSwitchedRule = true;
        _trialsInCurrentRule = 0;
      } else {
        _justSwitchedRule = false;
        _trialsInCurrentRule++;
      }
    } else {
      _justSwitchedRule = false;
      _trialsInCurrentRule = 1;
    }

    // Generate Target Card
    final availableShapes = LogicShape.values;
    final availableColors = LogicColor.values;
    final availableCounts = cfg.allowCountRule ? [1, 2, 3, 4] : [1, 2, 3];

    final targetShape = availableShapes[_random.nextInt(availableShapes.length)];
    final targetColor = availableColors[_random.nextInt(availableColors.length)];
    final targetCount = availableCounts[_random.nextInt(availableCounts.length)];
    _targetCard = LogicCard(shape: targetShape, color: targetColor, count: targetCount);

    // Generate Candidate Cards
    final candidates = <LogicCard>[];

    // 1. Correct Match: Matches ONLY on activeRule dimension
    LogicShape correctShape = targetShape;
    LogicColor correctColor = targetColor;
    int correctCount = targetCount;

    if (_activeRule == LogicRule.color) {
      // Must match color, but differ in shape and count
      correctShape = _pickDifferent(availableShapes, targetShape);
      correctCount = _pickDifferent(availableCounts, targetCount);
    } else if (_activeRule == LogicRule.shape) {
      // Must match shape, but differ in color and count
      correctColor = _pickDifferent(availableColors, targetColor);
      correctCount = _pickDifferent(availableCounts, targetCount);
    } else {
      // Must match count, but differ in shape and color
      correctShape = _pickDifferent(availableShapes, targetShape);
      correctColor = _pickDifferent(availableColors, targetColor);
    }
    candidates.add(LogicCard(shape: correctShape, color: correctColor, count: correctCount));

    // 2. Distractor A (Lure on competing dimension 1)
    if (_activeRule != LogicRule.color) {
      // Matches on color (tempting mistake), but NOT on active rule
      candidates.add(LogicCard(
        shape: _pickDifferent(availableShapes, targetShape),
        color: targetColor,
        count: _pickDifferent(availableCounts, targetCount),
      ));
    } else {
      // Matches on shape (tempting mistake)
      candidates.add(LogicCard(
        shape: targetShape,
        color: _pickDifferent(availableColors, targetColor),
        count: _pickDifferent(availableCounts, targetCount),
      ));
    }

    // 3. Distractor B (Lure on competing dimension 2)
    if (_activeRule != LogicRule.shape && candidates.length < cfg.choicesCount) {
      candidates.add(LogicCard(
        shape: targetShape,
        color: _pickDifferent(availableColors, targetColor),
        count: _pickDifferent(availableCounts, targetCount),
      ));
    } else if (candidates.length < cfg.choicesCount) {
      candidates.add(LogicCard(
        shape: _pickDifferent(availableShapes, targetShape),
        color: _pickDifferent(availableColors, targetColor),
        count: targetCount,
      ));
    }

    // 4. Distractor C (if choicesCount == 4)
    while (candidates.length < cfg.choicesCount) {
      final randShape = _pickDifferent(availableShapes, targetShape);
      final randColor = _pickDifferent(availableColors, targetColor);
      final randCount = _pickDifferent(availableCounts, targetCount);
      final candidate = LogicCard(shape: randShape, color: randColor, count: randCount);
      if (!candidates.contains(candidate)) {
        candidates.add(candidate);
      }
    }

    // Shuffle choices so correct answer position is randomized
    candidates.shuffle(_random);
    _candidateCards = candidates;

    _trialStartTime = DateTime.now();
    _timerProgress = 1.0;
    notifyListeners();

    // Start timer for scored trials
    if (!isPractice) {
      _startTrialTimer(cfg.trialDurationMs);
    }
  }

  T _pickDifferent<T>(List<T> list, T exclude) {
    final filtered = list.where((x) => x != exclude).toList();
    if (filtered.isEmpty) return exclude;
    return filtered[_random.nextInt(filtered.length)];
  }

  void _startTrialTimer(int durationMs) {
    const tickIntervalMs = 25;
    final totalTicks = durationMs ~/ tickIntervalMs;
    int ticksLeft = totalTicks;

    _trialTimer = Timer.periodic(const Duration(milliseconds: tickIntervalMs), (timer) {
      ticksLeft--;
      _timerProgress = (ticksLeft / totalTicks).clamp(0.0, 1.0);
      notifyListeners();

      if (ticksLeft <= 0) {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    _timeoutCount++;
    SoundHapticService.triggerMiss(true, true);
    _flashWrong = true;
    notifyListeners();

    _recordedTrials.add(
      TrialModel(
        trialNumber: _currentTrialIndex + 1,
        isPractice: isPractice,
        word: StroopItem.blue,
        inkColor: StroopItem.blue,
        selectedColor: StroopItem.yellow,
        reactionTimeMs: currentTrialDuration.inMilliseconds,
        isCorrect: false,
        isTimeout: true,
      ),
    );

    _advanceTrial();
  }

  void handleCardTap(LogicCard chosenCard, {required bool sound, required bool haptics}) {
    if (!_isPlaying || _flashCorrect || _flashWrong) return;

    _trialTimer?.cancel();
    final rt = DateTime.now().difference(_trialStartTime ?? DateTime.now()).inMilliseconds;

    // Evaluate match along active rule
    bool isMatch = false;
    switch (_activeRule) {
      case LogicRule.color:
        isMatch = chosenCard.color == _targetCard.color;
        break;
      case LogicRule.shape:
        isMatch = chosenCard.shape == _targetCard.shape;
        break;
      case LogicRule.count:
        isMatch = chosenCard.count == _targetCard.count;
        break;
    }

    if (isMatch) {
      _correctCount++;
      _reactionTimesMs.add(rt);
      if (_justSwitchedRule) {
        _switchReactionTimesMs.add(rt);
      } else {
        _repeatReactionTimesMs.add(rt);
      }
      SoundHapticService.triggerCorrect(sound, haptics);
      _flashCorrect = true;
    } else {
      SoundHapticService.triggerMiss(sound, haptics);
      _flashWrong = true;
    }
    notifyListeners();

    _recordedTrials.add(
      TrialModel(
        trialNumber: _currentTrialIndex + 1,
        isPractice: isPractice,
        word: StroopItem.blue,
        inkColor: StroopItem.blue,
        selectedColor: isMatch ? StroopItem.blue : StroopItem.yellow,
        reactionTimeMs: rt,
        isCorrect: isMatch,
        isTimeout: false,
      ),
    );

    _advanceTrial();
  }

  void _advanceTrial() {
    _flashTimer = Timer(const Duration(milliseconds: 320), () {
      _currentTrialIndex++;
      if (_currentTrialIndex >= totalTrialsCount) {
        _finishBlock();
      } else {
        _generateTrial();
      }
    });
  }

  void _finishBlock() {
    _trialTimer?.cancel();
    _flashTimer?.cancel();

    // Accuracy %
    final accuracy = ((_correctCount / scoredTrialsCount) * 100).round().clamp(0, 100);

    // Median Reaction Time
    int medianRT = 1400;
    if (_reactionTimesMs.isNotEmpty) {
      final sorted = List<int>.from(_reactionTimesMs)..sort();
      final mid = sorted.length ~/ 2;
      medianRT = sorted.length.isOdd ? sorted[mid] : ((sorted[mid - 1] + sorted[mid]) ~/ 2);
    }

    // Speed Index (0 to 100): scale 600ms (100) to 2200ms (0)
    final speed = (100 - (((medianRT - 600) / 1600) * 100)).round().clamp(0, 100);

    // Combined Block Score (Accuracy 70% + Speed 30%)
    final score = ((accuracy * 0.70) + (speed * 0.30)).round().clamp(0, 100);

    // Level Advancement
    int levelChange = 0;
    int nextLevel = _currentLevel;
    if (score >= 60 && accuracy >= 65) {
      levelChange = 1;
      nextLevel = (_currentLevel + 1).clamp(1, maxLevel);
    } else if (score < 30 && _currentLevel > 1) {
      levelChange = -1;
      nextLevel = (_currentLevel - 1).clamp(1, maxLevel);
    }

    final user = StorageService.getUser();
    final session = SessionModel(
      id: const Uuid().v4(),
      userId: user?.uid ?? 'guest',
      gameName: 'Logic Flow',
      score: score,
      speed: speed,
      accuracy: accuracy,
      medianRT: medianRT,
      levelBefore: _currentLevel,
      levelAfter: nextLevel,
      levelChange: levelChange,
      totalTrials: totalTrialsCount,
      scoredTrials: scoredTrialsCount,
      correctTrials: _correctCount,
      timeouts: _timeoutCount,
      createdAt: DateTime.now(),
      synced: user?.isGuest == false,
      trials: _recordedTrials,
    );

    _lastCompletedSession = session;
    StorageService.saveLogicSession(session);

    _isFinished = true;
    _isPlaying = false;
    notifyListeners();
  }

  void quitBlock() {
    _trialTimer?.cancel();
    _flashTimer?.cancel();
    _isPlaying = false;
    _isFinished = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _trialTimer?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }
}
