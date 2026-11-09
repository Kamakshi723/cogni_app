import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/session_model.dart';
import '../models/trial_model.dart';
import '../services/sound_haptic_service.dart';
import '../services/storage_service.dart';
import '../theme/stroop_colors.dart';

enum SpeedStimulusType {
  go,       // Tap fast!
  noGo,     // Do NOT tap!
  distractor, // Caution! Same color or shape but different rule
}

enum SpeedTapPhase {
  idle,
  waiting,        // Jitter delay before stimulus appears
  stimulusActive, // Stimulus on screen, countdown running
  feedback,       // Brief flash feedback
  finished,       // Block done
}

enum TapOutcome {
  hit,             // Tapped Go on time
  falseAlarm,      // Tapped No-Go (impulse error)
  miss,            // Didn't tap Go in time
  correctInhibit,  // Successfully didn't tap No-Go
  falseStart,      // Tapped before stimulus appeared
}

class SpeedTapConfig {
  final int level;
  final int goWindowMs;
  final double noGoRatio; // 0.15 to 0.30
  final int minInterTrialMs;
  final int maxInterTrialMs;
  final bool hasDistractors;

  const SpeedTapConfig({
    required this.level,
    required this.goWindowMs,
    required this.noGoRatio,
    required this.minInterTrialMs,
    required this.maxInterTrialMs,
    this.hasDistractors = false,
  });
}

class SpeedTapProvider with ChangeNotifier {
  static const int totalTrialsCount = 16;
  static const int practiceTrialsCount = 4;
  static const int scoredTrialsCount = 12;
  static const int maxLevel = 15;

  static const Map<int, SpeedTapConfig> levelConfigs = {
    // Stage 1: Reflex Ignition (Lv 1 - 5)
    1: SpeedTapConfig(level: 1, goWindowMs: 900, noGoRatio: 0.15, minInterTrialMs: 900, maxInterTrialMs: 1400),
    2: SpeedTapConfig(level: 2, goWindowMs: 820, noGoRatio: 0.20, minInterTrialMs: 850, maxInterTrialMs: 1300),
    3: SpeedTapConfig(level: 3, goWindowMs: 750, noGoRatio: 0.20, minInterTrialMs: 800, maxInterTrialMs: 1200),
    4: SpeedTapConfig(level: 4, goWindowMs: 680, noGoRatio: 0.20, minInterTrialMs: 750, maxInterTrialMs: 1150),
    5: SpeedTapConfig(level: 5, goWindowMs: 620, noGoRatio: 0.25, minInterTrialMs: 700, maxInterTrialMs: 1100),

    // Stage 2: Impulsive Brake (Lv 6 - 10)
    6: SpeedTapConfig(level: 6, goWindowMs: 560, noGoRatio: 0.25, minInterTrialMs: 650, maxInterTrialMs: 1000),
    7: SpeedTapConfig(level: 7, goWindowMs: 510, noGoRatio: 0.25, minInterTrialMs: 600, maxInterTrialMs: 950),
    8: SpeedTapConfig(level: 8, goWindowMs: 460, noGoRatio: 0.25, minInterTrialMs: 550, maxInterTrialMs: 900),
    9: SpeedTapConfig(level: 9, goWindowMs: 420, noGoRatio: 0.30, minInterTrialMs: 500, maxInterTrialMs: 850),
    10: SpeedTapConfig(level: 10, goWindowMs: 380, noGoRatio: 0.30, minInterTrialMs: 450, maxInterTrialMs: 800),

    // Stage 3: Sub-Second Reflex Mastery (Lv 11 - 15)
    11: SpeedTapConfig(level: 11, goWindowMs: 350, noGoRatio: 0.30, minInterTrialMs: 420, maxInterTrialMs: 750, hasDistractors: true),
    12: SpeedTapConfig(level: 12, goWindowMs: 320, noGoRatio: 0.30, minInterTrialMs: 400, maxInterTrialMs: 700, hasDistractors: true),
    13: SpeedTapConfig(level: 13, goWindowMs: 295, noGoRatio: 0.30, minInterTrialMs: 380, maxInterTrialMs: 680, hasDistractors: true),
    14: SpeedTapConfig(level: 14, goWindowMs: 275, noGoRatio: 0.30, minInterTrialMs: 360, maxInterTrialMs: 650, hasDistractors: true),
    15: SpeedTapConfig(level: 15, goWindowMs: 255, noGoRatio: 0.32, minInterTrialMs: 340, maxInterTrialMs: 620, hasDistractors: true),
  };

  // State
  int _currentLevel = 1;
  int _currentTrialIndex = 0;
  SpeedTapPhase _phase = SpeedTapPhase.idle;

  SpeedStimulusType _currentStimulus = SpeedStimulusType.go;
  DateTime? _stimulusStartTime;
  TapOutcome? _lastOutcome;
  int? _lastReactionTimeMs;

  Timer? _stateTimer;
  Timer? _countdownTicker;
  double _timerProgress = 1.0;

  // Block Aggregate Metrics
  int _totalGoHits = 0;
  int _totalGoMisses = 0;
  int _totalCorrectInhibitions = 0;
  int _totalFalseAlarms = 0;
  int _totalFalseStarts = 0;
  final List<int> _goReactionTimes = [];
  final List<TrialModel> _recordedTrials = [];
  SessionModel? _lastCompletedSession;

  final Random _random = Random();

  // Getters
  int get currentLevel => _currentLevel;
  int get currentTrialNumber => _currentTrialIndex + 1;
  int get totalTrials => totalTrialsCount;
  bool get isPractice => _currentTrialIndex < practiceTrialsCount;
  SpeedTapPhase get phase => _phase;
  bool get isFinished => _phase == SpeedTapPhase.finished;
  SpeedStimulusType get currentStimulus => _currentStimulus;
  TapOutcome? get lastOutcome => _lastOutcome;
  int? get lastReactionTimeMs => _lastReactionTimeMs;
  double get timerProgress => _timerProgress;
  SessionModel? get lastCompletedSession => _lastCompletedSession;
  List<TrialModel> get recordedTrials => List.unmodifiable(_recordedTrials);

  SpeedTapConfig get currentConfig =>
      levelConfigs[_currentLevel] ?? levelConfigs[1]!;

  void startBlock(int level) {
    _currentLevel = level.clamp(1, maxLevel);
    _currentTrialIndex = 0;
    _totalGoHits = 0;
    _totalGoMisses = 0;
    _totalCorrectInhibitions = 0;
    _totalFalseAlarms = 0;
    _totalFalseStarts = 0;
    _goReactionTimes.clear();
    _recordedTrials.clear();
    _lastCompletedSession = null;
    _lastOutcome = null;
    _lastReactionTimeMs = null;

    _scheduleNextTrial();
  }

  void _scheduleNextTrial() {
    _stateTimer?.cancel();
    _countdownTicker?.cancel();

    _phase = SpeedTapPhase.waiting;
    _timerProgress = 1.0;
    notifyListeners();

    // Random jitter interval before stimulus appears
    final minMs = currentConfig.minInterTrialMs;
    final maxMs = currentConfig.maxInterTrialMs;
    final waitMs = minMs + _random.nextInt(max(1, maxMs - minMs));

    _stateTimer = Timer(Duration(milliseconds: waitMs), () {
      _showStimulus();
    });
  }

  void _showStimulus() {
    // Determine stimulus type based on ratio
    final roll = _random.nextDouble();
    if (roll < currentConfig.noGoRatio) {
      _currentStimulus = SpeedStimulusType.noGo;
    } else if (currentConfig.hasDistractors && roll < (currentConfig.noGoRatio + 0.15)) {
      _currentStimulus = SpeedStimulusType.distractor;
    } else {
      _currentStimulus = SpeedStimulusType.go;
    }

    _phase = SpeedTapPhase.stimulusActive;
    _stimulusStartTime = DateTime.now();
    _timerProgress = 1.0;
    notifyListeners();

    // High resolution countdown ticker
    final totalMs = currentConfig.goWindowMs;
    const intervalMs = 20;
    int elapsed = 0;

    _countdownTicker = Timer.periodic(const Duration(milliseconds: intervalMs), (ticker) {
      elapsed += intervalMs;
      _timerProgress = (1.0 - (elapsed / totalMs)).clamp(0.0, 1.0);
      notifyListeners();

      if (elapsed >= totalMs) {
        ticker.cancel();
        _handleWindowExpired();
      }
    });
  }

  /// Called when user taps the trigger pad / screen
  void handleTap({required bool sound, required bool haptics}) {
    if (_phase == SpeedTapPhase.waiting) {
      // FALSE START: Tapped before stimulus appeared!
      _stateTimer?.cancel();
      _totalFalseStarts++;
      _lastOutcome = TapOutcome.falseStart;
      _lastReactionTimeMs = null;
      SoundHapticService.triggerMiss(sound, haptics);
      _recordTrial(isCorrect: false, rt: 0, timedOut: false);
      _showFeedbackAndAdvance();
      return;
    }

    if (_phase != SpeedTapPhase.stimulusActive) return;

    _countdownTicker?.cancel();
    _stateTimer?.cancel();

    final rt = _stimulusStartTime != null
        ? DateTime.now().difference(_stimulusStartTime!).inMilliseconds
        : 0;

    if (_currentStimulus == SpeedStimulusType.go) {
      // HIT: Tapped Go on time!
      if (!isPractice) {
        _totalGoHits++;
        _goReactionTimes.add(rt);
      }
      _lastOutcome = TapOutcome.hit;
      _lastReactionTimeMs = rt;
      SoundHapticService.triggerCorrect(sound, haptics);
      _recordTrial(isCorrect: true, rt: rt, timedOut: false);
    } else {
      // FALSE ALARM: Tapped on No-Go or Distractor!
      if (!isPractice) {
        _totalFalseAlarms++;
      }
      _lastOutcome = TapOutcome.falseAlarm;
      _lastReactionTimeMs = rt;
      SoundHapticService.triggerMiss(sound, haptics);
      _recordTrial(isCorrect: false, rt: rt, timedOut: false);
    }

    _showFeedbackAndAdvance();
  }

  /// Window expired without a tap
  void _handleWindowExpired() {
    _countdownTicker?.cancel();
    _stateTimer?.cancel();

    if (_currentStimulus == SpeedStimulusType.go) {
      // MISS: Failed to tap Go before time ran out!
      if (!isPractice) {
        _totalGoMisses++;
      }
      _lastOutcome = TapOutcome.miss;
      _lastReactionTimeMs = null;
      _recordTrial(isCorrect: false, rt: currentConfig.goWindowMs, timedOut: true);
    } else {
      // CORRECT INHIBITION: Patiently withheld on No-Go / Distractor!
      if (!isPractice) {
        _totalCorrectInhibitions++;
      }
      _lastOutcome = TapOutcome.correctInhibit;
      _lastReactionTimeMs = null;
      _recordTrial(isCorrect: true, rt: 0, timedOut: false);
    }

    _showFeedbackAndAdvance();
  }

  void _recordTrial({required bool isCorrect, required int rt, required bool timedOut}) {
    _recordedTrials.add(
      TrialModel(
        trialNumber: _currentTrialIndex + 1,
        isPractice: isPractice,
        word: _currentStimulus == SpeedStimulusType.go ? StroopItem.green : StroopItem.red,
        inkColor: _currentStimulus == SpeedStimulusType.go ? StroopItem.green : StroopItem.red,
        reactionTimeMs: rt,
        isCorrect: isCorrect,
        isTimeout: timedOut,
      ),
    );
  }

  void _showFeedbackAndAdvance() {
    _phase = SpeedTapPhase.feedback;
    notifyListeners();

    _stateTimer = Timer(const Duration(milliseconds: 400), () {
      _currentTrialIndex++;
      if (_currentTrialIndex >= totalTrialsCount) {
        _finishBlock();
      } else {
        _scheduleNextTrial();
      }
    });
  }

  void _finishBlock() {
    _stateTimer?.cancel();
    _countdownTicker?.cancel();

    final scoredTrialsTotal = scoredTrialsCount;
    final totalHandledCorrectly = _totalGoHits + _totalCorrectInhibitions;

    // Accuracy %: Ratio of correct decisions
    final accuracy = scoredTrialsTotal > 0
        ? ((totalHandledCorrectly / scoredTrialsTotal) * 100).round().clamp(0, 100)
        : 0;

    // Median Reaction Time on Go trials
    int medianRT = currentConfig.goWindowMs;
    if (_goReactionTimes.isNotEmpty) {
      final sorted = List<int>.from(_goReactionTimes)..sort();
      final mid = sorted.length ~/ 2;
      medianRT = sorted.length.isOdd ? sorted[mid] : ((sorted[mid - 1] + sorted[mid]) ~/ 2);
    }

    // Speed Score Index: based on RT vs current level threshold
    final benchmark = currentConfig.goWindowMs;
    final speed = (100 - (((medianRT - 180) / (benchmark - 180)) * 100)).round().clamp(0, 100);

    // Motor Inhibition Penalty: False alarms on No-Go heavily penalize
    final score = ((accuracy * 0.6) + (speed * 0.4)).round().clamp(0, 100);

    // Level advancement
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
      gameName: 'Speed Tap',
      score: score,
      speed: speed,
      accuracy: accuracy,
      medianRT: medianRT,
      levelBefore: _currentLevel,
      levelAfter: nextLevel,
      levelChange: levelChange,
      totalTrials: totalTrialsCount,
      scoredTrials: scoredTrialsCount,
      correctTrials: totalHandledCorrectly,
      timeouts: _totalGoMisses,
      createdAt: DateTime.now(),
      synced: user?.isGuest == false,
      trials: _recordedTrials,
    );

    _lastCompletedSession = session;
    StorageService.saveSpeedTapSession(session);

    _phase = SpeedTapPhase.finished;
    notifyListeners();
  }

  void quitBlock() {
    _stateTimer?.cancel();
    _countdownTicker?.cancel();
    _phase = SpeedTapPhase.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _stateTimer?.cancel();
    _countdownTicker?.cancel();
    super.dispose();
  }
}
