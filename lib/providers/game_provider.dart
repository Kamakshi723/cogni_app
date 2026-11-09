import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/session_model.dart';
import '../models/trial_model.dart';
import '../services/sound_haptic_service.dart';
import '../services/storage_service.dart';
import '../theme/stroop_colors.dart';

enum FlashState {
  none,
  correct,
  miss,
}

class GameProvider with ChangeNotifier {
  static const int totalTrialsCount = 30;
  static const int practiceTrialsCount = 10;
  static const int scoredTrialsCount = 20;
  static const int maxLevel = 15;

  // State
  int _currentLevel = 1;
  int _currentTrialIndex = 0; // 0 to 29
  bool _isPlaying = false;
  bool _isFinished = false;

  late StroopItem _currentWord;
  late StroopItem _currentInkColor;

  DateTime? _trialStartTime;
  Timer? _trialTimer;
  double _timerProgress = 1.0; // 1.0 down to 0.0

  FlashState _feedbackFlash = FlashState.none;
  Timer? _flashTimer;

  final List<TrialModel> _recordedTrials = [];
  SessionModel? _lastCompletedSession;

  final Random _random = Random();

  // Getters
  int get currentLevel => _currentLevel;
  int get currentTrialNumber => _currentTrialIndex + 1; // 1 to 30
  int get totalTrials => totalTrialsCount;
  bool get isPractice => _currentTrialIndex < practiceTrialsCount;
  bool get isPlaying => _isPlaying;
  bool get isFinished => _isFinished;
  StroopItem get currentWord => _currentWord;
  StroopItem get currentInkColor => _currentInkColor;
  double get timerProgress => _timerProgress;
  FlashState get feedbackFlash => _feedbackFlash;
  SessionModel? get lastCompletedSession => _lastCompletedSession;
  List<TrialModel> get recordedTrials => List.unmodifiable(_recordedTrials);

  /// Timer scales smoothly from Level 1 (2200ms) down to Level 15 (800ms)
  Duration get scoredTrialDuration {
    final ms = (2200 - ((_currentLevel - 1) * 100)).clamp(800, 2400);
    return Duration(milliseconds: ms);
  }

  void startBlock(int levelToPlay) {
    _currentLevel = levelToPlay.clamp(1, maxLevel);
    _currentTrialIndex = 0;
    _isPlaying = true;
    _isFinished = false;
    _recordedTrials.clear();
    _lastCompletedSession = null;
    _feedbackFlash = FlashState.none;

    _generateTrial();
    notifyListeners();
  }

  void _generateTrial() {
    _trialTimer?.cancel();
    _flashTimer?.cancel();
    _feedbackFlash = FlashState.none;

    // Pick ink color randomly
    final colors = StroopItem.values;
    _currentInkColor = colors[_random.nextInt(colors.length)];

    // Incongruent chance increases across 15 levels
    // Level 1: 45% incongruent (gentle start)
    // Level 15: 92% incongruent (high interference)
    final double incongruentChance = (0.45 + ((_currentLevel - 1) * 0.033)).clamp(0.4, 0.92);
    final bool makeIncongruent = _random.nextDouble() < incongruentChance;

    if (makeIncongruent) {
      final otherColors = colors.where((c) => c != _currentInkColor).toList();
      _currentWord = otherColors[_random.nextInt(otherColors.length)];
    } else {
      _currentWord = _currentInkColor;
    }

    _trialStartTime = DateTime.now();
    _timerProgress = 1.0;

    // If scored trial, start countdown timer
    if (!isPractice) {
      final totalMs = scoredTrialDuration.inMilliseconds;
      const intervalMs = 16; // ~60fps smooth linear progress
      int elapsedMs = 0;

      _trialTimer = Timer.periodic(const Duration(milliseconds: intervalMs), (timer) {
        elapsedMs += intervalMs;
        _timerProgress = (1.0 - (elapsedMs / totalMs)).clamp(0.0, 1.0);
        notifyListeners();

        if (elapsedMs >= totalMs) {
          timer.cancel();
          _handleTimeout();
        }
      });
    }
  }

  void handleColorTap(StroopItem selected, {required bool sound, required bool haptics}) {
    if (!_isPlaying || _feedbackFlash != FlashState.none) return;

    _trialTimer?.cancel();
    final rt = _trialStartTime != null
        ? DateTime.now().difference(_trialStartTime!).inMilliseconds
        : 0;

    final isCorrect = selected == _currentInkColor;

    if (isCorrect) {
      SoundHapticService.triggerCorrect(sound, haptics);
      _feedbackFlash = FlashState.correct;
    } else {
      SoundHapticService.triggerMiss(sound, haptics);
      _feedbackFlash = FlashState.miss;
    }

    _recordedTrials.add(
      TrialModel(
        trialNumber: currentTrialNumber,
        isPractice: isPractice,
        word: _currentWord,
        inkColor: _currentInkColor,
        selectedColor: selected,
        reactionTimeMs: rt,
        isCorrect: isCorrect,
        isTimeout: false,
      ),
    );

    notifyListeners();

    // 220 ms feedback flash per spec
    _flashTimer = Timer(const Duration(milliseconds: 220), () {
      _feedbackFlash = FlashState.none;
      _advanceTrial(sound: sound, haptics: haptics);
    });
  }

  void _handleTimeout() {
    if (!_isPlaying || _feedbackFlash != FlashState.none) return;

    final totalMs = scoredTrialDuration.inMilliseconds;
    _feedbackFlash = FlashState.miss;

    _recordedTrials.add(
      TrialModel(
        trialNumber: currentTrialNumber,
        isPractice: isPractice,
        word: _currentWord,
        inkColor: _currentInkColor,
        selectedColor: null,
        reactionTimeMs: totalMs,
        isCorrect: false,
        isTimeout: true,
      ),
    );

    notifyListeners();

    _flashTimer = Timer(const Duration(milliseconds: 220), () {
      _feedbackFlash = FlashState.none;
      _advanceTrial(sound: false, haptics: true);
    });
  }

  void _advanceTrial({required bool sound, required bool haptics}) {
    _currentTrialIndex++;
    if (_currentTrialIndex < totalTrialsCount) {
      _generateTrial();
      notifyListeners();
    } else {
      _finishBlock(sound: sound, haptics: haptics);
    }
  }

  Future<void> _finishBlock({required bool sound, required bool haptics}) async {
    _isPlaying = false;
    _isFinished = true;
    _trialTimer?.cancel();
    _flashTimer?.cancel();

    final scoredTrials = _recordedTrials.where((t) => !t.isPractice).toList();
    final correctScored = scoredTrials.where((t) => t.isCorrect).toList();
    final timeouts = scoredTrials.where((t) => t.isTimeout).length;

    // Accuracy (0-100)
    final accuracy = scoredTrials.isEmpty
        ? 0
        : ((correctScored.length / scoredTrials.length) * 100).round();

    // Median RT (ms) for correct scored trials
    int medianRT = 0;
    if (correctScored.isNotEmpty) {
      final rts = correctScored.map((t) => t.reactionTimeMs).toList()..sort();
      final middle = rts.length ~/ 2;
      medianRT = rts.length.isOdd ? rts[middle] : ((rts[middle - 1] + rts[middle]) ~/ 2);
    } else if (scoredTrials.isNotEmpty) {
      medianRT = scoredTrialDuration.inMilliseconds;
    }

    // Speed calculation: normalized scale from RT
    int speed = 0;
    if (medianRT > 0) {
      final rawSpeed = 100 - (((medianRT - 400) / 1400) * 80).clamp(0, 95);
      speed = rawSpeed.round().clamp(5, 100);
    }

    // Hero Score: 60% accuracy + 40% speed
    final score = ((0.6 * accuracy) + (0.4 * speed)).round().clamp(0, 100);

    // Passing requirement to unlock next level: score >= 60 and accuracy >= 70%
    final bool isPassed = score >= 60 && accuracy >= 70;

    int newLevel = _currentLevel;
    int levelChange = 0;

    if (isPassed) {
      final int currentUnlocked = StorageService.getHighestUnlockedLevel();
      final int nextLevelCandidate = min(maxLevel, _currentLevel + 1);

      if (_currentLevel >= currentUnlocked && nextLevelCandidate > currentUnlocked) {
        await StorageService.unlockLevel(nextLevelCandidate);
        newLevel = nextLevelCandidate;
        levelChange = 1;
        SoundHapticService.triggerLevelUp(sound, haptics);
      } else {
        newLevel = _currentLevel;
        levelChange = 0;
      }
    } else {
      newLevel = _currentLevel;
      levelChange = 0;
    }

    final user = StorageService.getUser();
    final userId = user?.uid ?? 'guest_user';

    final session = SessionModel(
      id: const Uuid().v4(),
      userId: userId,
      gameName: 'Colour Stroop',
      score: score,
      speed: speed,
      accuracy: accuracy,
      medianRT: medianRT,
      levelBefore: _currentLevel,
      levelAfter: newLevel,
      levelChange: levelChange,
      totalTrials: totalTrialsCount,
      scoredTrials: scoredTrialsCount,
      correctTrials: correctScored.length,
      timeouts: timeouts,
      createdAt: DateTime.now(),
      synced: !StorageService.isOfflineMode(),
      trials: List.from(_recordedTrials),
    );

    _lastCompletedSession = session;
    await StorageService.saveSession(session);

    notifyListeners();
  }

  void quitBlock() {
    _trialTimer?.cancel();
    _flashTimer?.cancel();
    _isPlaying = false;
    _isFinished = false;
    _recordedTrials.clear();
    _lastCompletedSession = null;
    _feedbackFlash = FlashState.none;
    notifyListeners();
  }

  @override
  void dispose() {
    _trialTimer?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }
}
