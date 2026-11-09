import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/session_model.dart';
import '../models/trial_model.dart';
import '../services/sound_haptic_service.dart';
import '../services/storage_service.dart';
import '../theme/stroop_colors.dart';

enum MatrixPhase {
  idle,
  memorize,
  recall,
  trialResult,
  finished,
}

class MatrixLevelConfig {
  final int level;
  final int gridSize; // 3 -> 3x3, 4 -> 4x4, 5 -> 5x5
  final int targetCount;
  final int memorizeMs;
  final int recallMs;

  const MatrixLevelConfig({
    required this.level,
    required this.gridSize,
    required this.targetCount,
    required this.memorizeMs,
    required this.recallMs,
  });

  int get totalTiles => gridSize * gridSize;
}

class MatrixGameProvider with ChangeNotifier {
  static const int totalTrialsCount = 10;
  static const int practiceTrialsCount = 2;
  static const int scoredTrialsCount = 8;
  static const int maxLevel = 15;

  static const Map<int, MatrixLevelConfig> levelConfigs = {
    1: MatrixLevelConfig(level: 1, gridSize: 3, targetCount: 3, memorizeMs: 2200, recallMs: 6000),
    2: MatrixLevelConfig(level: 2, gridSize: 3, targetCount: 4, memorizeMs: 2000, recallMs: 6000),
    3: MatrixLevelConfig(level: 3, gridSize: 4, targetCount: 4, memorizeMs: 1900, recallMs: 6500),
    4: MatrixLevelConfig(level: 4, gridSize: 4, targetCount: 5, memorizeMs: 1800, recallMs: 6500),
    5: MatrixLevelConfig(level: 5, gridSize: 4, targetCount: 5, memorizeMs: 1700, recallMs: 6500),
    6: MatrixLevelConfig(level: 6, gridSize: 4, targetCount: 6, memorizeMs: 1600, recallMs: 7000),
    7: MatrixLevelConfig(level: 7, gridSize: 4, targetCount: 6, memorizeMs: 1500, recallMs: 7000),
    8: MatrixLevelConfig(level: 8, gridSize: 5, targetCount: 6, memorizeMs: 1500, recallMs: 7500),
    9: MatrixLevelConfig(level: 9, gridSize: 5, targetCount: 7, memorizeMs: 1400, recallMs: 7500),
    10: MatrixLevelConfig(level: 10, gridSize: 5, targetCount: 7, memorizeMs: 1300, recallMs: 7500),
    11: MatrixLevelConfig(level: 11, gridSize: 5, targetCount: 8, memorizeMs: 1200, recallMs: 8000),
    12: MatrixLevelConfig(level: 12, gridSize: 5, targetCount: 8, memorizeMs: 1100, recallMs: 8000),
    13: MatrixLevelConfig(level: 13, gridSize: 5, targetCount: 9, memorizeMs: 1000, recallMs: 8000),
    14: MatrixLevelConfig(level: 14, gridSize: 5, targetCount: 9, memorizeMs: 950, recallMs: 8000),
    15: MatrixLevelConfig(level: 15, gridSize: 5, targetCount: 10, memorizeMs: 850, recallMs: 8000),
  };

  // State
  int _currentLevel = 1;
  int _currentTrialIndex = 0; // 0 to 9
  MatrixPhase _phase = MatrixPhase.idle;

  Set<int> _targetIndices = {};
  final Set<int> _selectedIndices = {};
  final Set<int> _wrongIndices = {};

  Timer? _phaseTimer;
  Timer? _countdownTicker;
  double _timerProgress = 1.0;
  DateTime? _recallStartTime;

  int _totalCorrectTaps = 0;
  int _totalTargetTilesAcrossBlock = 0;
  int _totalWrongTaps = 0;
  int _perfectTrials = 0;
  final List<int> _reactionTimesMs = [];
  final List<TrialModel> _recordedTrials = [];
  SessionModel? _lastCompletedSession;

  final Random _random = Random();

  // Getters
  int get currentLevel => _currentLevel;
  int get currentTrialNumber => _currentTrialIndex + 1;
  int get totalTrials => totalTrialsCount;
  bool get isPractice => _currentTrialIndex < practiceTrialsCount;
  MatrixPhase get phase => _phase;
  bool get isFinished => _phase == MatrixPhase.finished;
  double get timerProgress => _timerProgress;

  MatrixLevelConfig get currentConfig =>
      levelConfigs[_currentLevel] ?? levelConfigs[1]!;

  int get gridSize => currentConfig.gridSize;
  int get totalTiles => currentConfig.totalTiles;
  int get targetCount => currentConfig.targetCount;

  Set<int> get targetIndices => Set.unmodifiable(_targetIndices);
  Set<int> get selectedIndices => Set.unmodifiable(_selectedIndices);
  Set<int> get wrongIndices => Set.unmodifiable(_wrongIndices);
  int get remainingTargets => _targetIndices.length - _selectedIndices.length;

  SessionModel? get lastCompletedSession => _lastCompletedSession;
  List<TrialModel> get recordedTrials => List.unmodifiable(_recordedTrials);

  void startBlock(int level) {
    _currentLevel = level.clamp(1, maxLevel);
    _currentTrialIndex = 0;
    _totalCorrectTaps = 0;
    _totalTargetTilesAcrossBlock = 0;
    _totalWrongTaps = 0;
    _perfectTrials = 0;
    _reactionTimesMs.clear();
    _recordedTrials.clear();
    _lastCompletedSession = null;

    _startTrial();
  }

  void _startTrial() {
    _phaseTimer?.cancel();
    _countdownTicker?.cancel();

    _selectedIndices.clear();
    _wrongIndices.clear();

    final config = currentConfig;
    final total = config.totalTiles;
    final count = config.targetCount;

    // Pick unique target indices
    final indices = <int>{};
    while (indices.length < count) {
      indices.add(_random.nextInt(total));
    }
    _targetIndices = indices;

    if (!isPractice) {
      _totalTargetTilesAcrossBlock += count;
    }

    _phase = MatrixPhase.memorize;
    _timerProgress = 1.0;
    notifyListeners();

    // Smooth progress countdown for memorize phase
    final durationMs = config.memorizeMs;
    final startTime = DateTime.now();

    _countdownTicker = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final remaining = (durationMs - elapsed).clamp(0, durationMs);
      _timerProgress = remaining / durationMs;
      notifyListeners();

      if (remaining <= 0) {
        timer.cancel();
      }
    });

    _phaseTimer = Timer(Duration(milliseconds: durationMs), () {
      _countdownTicker?.cancel();
      _beginRecallPhase();
    });
  }

  void _beginRecallPhase() {
    _phase = MatrixPhase.recall;
    _timerProgress = 1.0;
    _recallStartTime = DateTime.now();
    notifyListeners();

    final recallMs = currentConfig.recallMs;
    final startTime = DateTime.now();

    _countdownTicker = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final remaining = (recallMs - elapsed).clamp(0, recallMs);
      _timerProgress = remaining / recallMs;
      notifyListeners();

      if (remaining <= 0) {
        timer.cancel();
      }
    });

    _phaseTimer = Timer(Duration(milliseconds: recallMs), () {
      _countdownTicker?.cancel();
      _finishCurrentTrial(timedOut: true);
    });
  }

  void handleTileTap(int index, {required bool sound, required bool haptics}) {
    if (_phase != MatrixPhase.recall) return;
    if (_selectedIndices.contains(index) || _wrongIndices.contains(index)) return;

    if (_targetIndices.contains(index)) {
      // Correct tile tap
      _selectedIndices.add(index);
      if (!isPractice) {
        _totalCorrectTaps++;
      }
      SoundHapticService.triggerCorrect(sound, haptics);
      notifyListeners();

      // Check if all targets found
      if (_selectedIndices.length == _targetIndices.length) {
        _countdownTicker?.cancel();
        _phaseTimer?.cancel();
        _finishCurrentTrial(timedOut: false);
      }
    } else {
      // Wrong tile tap
      _wrongIndices.add(index);
      if (!isPractice) {
        _totalWrongTaps++;
      }
      SoundHapticService.triggerMiss(sound, haptics);
      notifyListeners();

      // If too many mistakes (e.g. 3 wrong taps), end trial early
      if (_wrongIndices.length >= 3) {
        _countdownTicker?.cancel();
        _phaseTimer?.cancel();
        _finishCurrentTrial(timedOut: false);
      }
    }
  }

  void _finishCurrentTrial({required bool timedOut}) {
    final recallDurationMs = _recallStartTime != null
        ? DateTime.now().difference(_recallStartTime!).inMilliseconds
        : 0;

    final isCorrect = _selectedIndices.length == _targetIndices.length && _wrongIndices.isEmpty;

    if (!isPractice && isCorrect) {
      _perfectTrials++;
      _reactionTimesMs.add(recallDurationMs);
    }

    _recordedTrials.add(
      TrialModel(
        trialNumber: _currentTrialIndex + 1,
        isPractice: isPractice,
        word: StroopItem.blue,
        inkColor: StroopItem.blue,
        reactionTimeMs: recallDurationMs,
        isCorrect: isCorrect,
        isTimeout: timedOut,
      ),
    );

    _phase = MatrixPhase.trialResult;
    notifyListeners();

    // Advance to next trial after 500ms
    Timer(const Duration(milliseconds: 600), () {
      _currentTrialIndex++;
      if (_currentTrialIndex >= totalTrialsCount) {
        _finishBlock();
      } else {
        _startTrial();
      }
    });
  }

  void _finishBlock() {
    _phaseTimer?.cancel();
    _countdownTicker?.cancel();

    // Calculate accuracy percentage
    final totalTargets = _totalTargetTilesAcrossBlock > 0
        ? _totalTargetTilesAcrossBlock
        : (scoredTrialsCount * currentConfig.targetCount);

    final accuracy = ((_totalCorrectTaps / totalTargets) * 100).round().clamp(0, 100);

    // Median reaction time
    int medianRT = 0;
    if (_reactionTimesMs.isNotEmpty) {
      final sorted = List<int>.from(_reactionTimesMs)..sort();
      final mid = sorted.length ~/ 2;
      medianRT = sorted.length.isOdd ? sorted[mid] : ((sorted[mid - 1] + sorted[mid]) ~/ 2);
    } else {
      medianRT = currentConfig.recallMs;
    }

    // Speed Index: faster recall yields up to 100 points
    final avgTimePerTarget = _reactionTimesMs.isNotEmpty
        ? (_reactionTimesMs.reduce((a, b) => a + b) / _reactionTimesMs.length)
        : currentConfig.recallMs.toDouble();

    final speedFactor = ((currentConfig.recallMs - avgTimePerTarget) / currentConfig.recallMs).clamp(0.0, 1.0);
    final speed = (speedFactor * 100).round();

    // Combined Block Score out of 100
    final score = ((accuracy * 0.75) + (speed * 0.25)).round().clamp(0, 100);

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
      gameName: 'Memory Matrix',
      score: score,
      speed: speed,
      accuracy: accuracy,
      medianRT: medianRT,
      levelBefore: _currentLevel,
      levelAfter: nextLevel,
      levelChange: levelChange,
      totalTrials: totalTrialsCount,
      scoredTrials: scoredTrialsCount,
      correctTrials: _perfectTrials,
      timeouts: _recordedTrials.where((t) => t.isTimeout && !t.isPractice).length,
      createdAt: DateTime.now(),
      synced: user?.isGuest == false,
      trials: _recordedTrials,
    );

    _lastCompletedSession = session;
    StorageService.saveMatrixSession(session);

    _phase = MatrixPhase.finished;
    notifyListeners();
  }

  void quitBlock() {
    _phaseTimer?.cancel();
    _countdownTicker?.cancel();
    _phase = MatrixPhase.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _countdownTicker?.cancel();
    super.dispose();
  }
}
