import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/session_model.dart';
import '../models/trial_model.dart';
import '../services/sound_haptic_service.dart';
import '../services/storage_service.dart';
import '../theme/stroop_colors.dart';

enum RadarPhase {
  idle,
  cue,          // Targets highlighted
  tracking,     // Targets blend in, all orbs move
  recall,       // Orbs freeze, player selects targets
  trialResult,  // Brief feedback
  finished,     // Block completed
}

class RadarOrb {
  final int id;
  Offset position; // Normalized -0.85 to +0.85 (inside circle)
  Offset velocity;
  final bool isTarget;
  bool isSelected;
  bool isWrong;

  RadarOrb({
    required this.id,
    required this.position,
    required this.velocity,
    required this.isTarget,
    this.isSelected = false,
    this.isWrong = false,
  });
}

class RadarLevelConfig {
  final int level;
  final int totalOrbs;
  final int targetCount;
  final double speedFactor;
  final int trackingDurationMs;
  final int cueDurationMs;

  const RadarLevelConfig({
    required this.level,
    required this.totalOrbs,
    required this.targetCount,
    required this.speedFactor,
    required this.trackingDurationMs,
    this.cueDurationMs = 1800,
  });
}

class RadarGameProvider with ChangeNotifier {
  static const int totalTrialsCount = 10;
  static const int practiceTrialsCount = 2;
  static const int scoredTrialsCount = 8;
  static const int maxLevel = 15;

  static const Map<int, RadarLevelConfig> levelConfigs = {
    // Stage 1: Orbital Search (Lv 1 - 5)
    1: RadarLevelConfig(level: 1, totalOrbs: 4, targetCount: 2, speedFactor: 1.0, trackingDurationMs: 3500),
    2: RadarLevelConfig(level: 2, totalOrbs: 5, targetCount: 2, speedFactor: 1.1, trackingDurationMs: 3600),
    3: RadarLevelConfig(level: 3, totalOrbs: 5, targetCount: 2, speedFactor: 1.25, trackingDurationMs: 3800),
    4: RadarLevelConfig(level: 4, totalOrbs: 6, targetCount: 2, speedFactor: 1.35, trackingDurationMs: 4000),
    5: RadarLevelConfig(level: 5, totalOrbs: 6, targetCount: 3, speedFactor: 1.45, trackingDurationMs: 4200),

    // Stage 2: High-Density Tracking (Lv 6 - 10)
    6: RadarLevelConfig(level: 6, totalOrbs: 7, targetCount: 3, speedFactor: 1.55, trackingDurationMs: 4400),
    7: RadarLevelConfig(level: 7, totalOrbs: 7, targetCount: 3, speedFactor: 1.7, trackingDurationMs: 4600),
    8: RadarLevelConfig(level: 8, totalOrbs: 8, targetCount: 3, speedFactor: 1.85, trackingDurationMs: 4800),
    9: RadarLevelConfig(level: 9, totalOrbs: 8, targetCount: 3, speedFactor: 2.0, trackingDurationMs: 5000),
    10: RadarLevelConfig(level: 10, totalOrbs: 9, targetCount: 3, speedFactor: 2.15, trackingDurationMs: 5200),

    // Stage 3: Deep Peripheral Mastery (Lv 11 - 15)
    11: RadarLevelConfig(level: 11, totalOrbs: 9, targetCount: 4, speedFactor: 2.25, trackingDurationMs: 5300, cueDurationMs: 1600),
    12: RadarLevelConfig(level: 12, totalOrbs: 10, targetCount: 4, speedFactor: 2.35, trackingDurationMs: 5400, cueDurationMs: 1600),
    13: RadarLevelConfig(level: 13, totalOrbs: 10, targetCount: 4, speedFactor: 2.45, trackingDurationMs: 5500, cueDurationMs: 1500),
    14: RadarLevelConfig(level: 14, totalOrbs: 11, targetCount: 4, speedFactor: 2.55, trackingDurationMs: 5600, cueDurationMs: 1500),
    15: RadarLevelConfig(level: 15, totalOrbs: 11, targetCount: 4, speedFactor: 2.7, trackingDurationMs: 5800, cueDurationMs: 1400),
  };

  // State
  int _currentLevel = 1;
  int _currentTrialIndex = 0;
  RadarPhase _phase = RadarPhase.idle;
  List<RadarOrb> _orbs = [];

  Timer? _phaseTimer;
  Timer? _motionTicker;
  DateTime? _recallStartTime;
  double _radarSweepAngle = 0.0;

  // Aggregate Metrics
  int _totalTargetsIdentified = 0;
  int _totalTargetsPossible = 0;
  int _totalDistractorMistakes = 0;
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
  RadarPhase get phase => _phase;
  bool get isFinished => _phase == RadarPhase.finished;
  List<RadarOrb> get orbs => List.unmodifiable(_orbs);
  double get radarSweepAngle => _radarSweepAngle;
  SessionModel? get lastCompletedSession => _lastCompletedSession;
  List<TrialModel> get recordedTrials => List.unmodifiable(_recordedTrials);

  RadarLevelConfig get currentConfig =>
      levelConfigs[_currentLevel] ?? levelConfigs[1]!;

  int get targetCount => currentConfig.targetCount;
  int get remainingTargets =>
      _orbs.where((o) => o.isTarget && !o.isSelected).length;

  void startBlock(int level) {
    _currentLevel = level.clamp(1, maxLevel);
    _currentTrialIndex = 0;
    _totalTargetsIdentified = 0;
    _totalTargetsPossible = 0;
    _totalDistractorMistakes = 0;
    _perfectTrials = 0;
    _reactionTimesMs.clear();
    _recordedTrials.clear();
    _lastCompletedSession = null;

    _startTrial();
  }

  void _startTrial() {
    _phaseTimer?.cancel();
    _motionTicker?.cancel();

    // Spawn orbs inside unit circle
    final config = currentConfig;
    final total = config.totalOrbs;
    final targets = config.targetCount;

    // Pick unique target indices
    final targetIndices = <int>{};
    while (targetIndices.length < targets) {
      targetIndices.add(_random.nextInt(total));
    }

    _orbs = List.generate(total, (i) {
      // Polar coords distribution
      final angle = _random.nextDouble() * 2 * pi;
      final radius = 0.2 + (_random.nextDouble() * 0.65);
      final pos = Offset(cos(angle) * radius, sin(angle) * radius);

      // Random velocity vector
      final velAngle = _random.nextDouble() * 2 * pi;
      final baseSpeed = 0.007 * config.speedFactor;
      final vel = Offset(cos(velAngle) * baseSpeed, sin(velAngle) * baseSpeed);

      return RadarOrb(
        id: i,
        position: pos,
        velocity: vel,
        isTarget: targetIndices.contains(i),
      );
    });

    // Cue phase
    _phase = RadarPhase.cue;
    notifyListeners();

    _phaseTimer = Timer(Duration(milliseconds: config.cueDurationMs), () {
      _startTrackingPhase();
    });
  }

  void _startTrackingPhase() {
    _phase = RadarPhase.tracking;
    notifyListeners();

    final trackingDuration = currentConfig.trackingDurationMs;
    final startTime = DateTime.now();

    // Motion physics ticker (~30 FPS = 33ms)
    _motionTicker = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;

      _radarSweepAngle = (_radarSweepAngle + 0.08) % (2 * pi);

      // Advance each orb position
      for (final orb in _orbs) {
        var newPos = orb.position + orb.velocity;

        // Circular boundary bounce check (radius = 0.82)
        if (newPos.distance >= 0.82) {
          // Reflect velocity against radial normal
          final normal = newPos / newPos.distance;
          final dot = orb.velocity.dx * normal.dx + orb.velocity.dy * normal.dy;
          orb.velocity = orb.velocity - (normal * (2 * dot));
          newPos = orb.position + orb.velocity;
        }

        orb.position = newPos;
      }

      notifyListeners();

      if (elapsed >= trackingDuration) {
        timer.cancel();
        _startRecallPhase();
      }
    });
  }

  void _startRecallPhase() {
    _motionTicker?.cancel();
    _phaseTimer?.cancel();

    _phase = RadarPhase.recall;
    _recallStartTime = DateTime.now();
    notifyListeners();
  }

  void handleOrbTap(int id, {required bool sound, required bool haptics}) {
    if (_phase != RadarPhase.recall) return;

    final orbIndex = _orbs.indexWhere((o) => o.id == id);
    if (orbIndex == -1) return;

    final orb = _orbs[orbIndex];
    if (orb.isSelected || orb.isWrong) return;

    if (orb.isTarget) {
      // Correct Target Identified
      orb.isSelected = true;
      if (!isPractice) {
        _totalTargetsIdentified++;
      }
      SoundHapticService.triggerCorrect(sound, haptics);
      notifyListeners();

      // Check if all targets found
      if (remainingTargets == 0) {
        _finishCurrentTrial();
      }
    } else {
      // Distractor mistake
      orb.isWrong = true;
      if (!isPractice) {
        _totalDistractorMistakes++;
      }
      SoundHapticService.triggerMiss(sound, haptics);
      notifyListeners();

      // If made 2 or more mistakes, finish trial
      final wrongCount = _orbs.where((o) => o.isWrong).length;
      if (wrongCount >= 2) {
        _finishCurrentTrial();
      }
    }
  }

  void _finishCurrentTrial() {
    _phaseTimer?.cancel();
    _motionTicker?.cancel();

    final recallTimeMs = _recallStartTime != null
        ? DateTime.now().difference(_recallStartTime!).inMilliseconds
        : 0;

    final selectedTargetCount = _orbs.where((o) => o.isTarget && o.isSelected).length;
    final totalTrialTargets = currentConfig.targetCount;
    final isPerfect = selectedTargetCount == totalTrialTargets && _orbs.where((o) => o.isWrong).isEmpty;

    if (!isPractice) {
      _totalTargetsPossible += totalTrialTargets;
      if (isPerfect) {
        _perfectTrials++;
        _reactionTimesMs.add(recallTimeMs);
      }
    }

    _recordedTrials.add(
      TrialModel(
        trialNumber: _currentTrialIndex + 1,
        isPractice: isPractice,
        word: StroopItem.green,
        inkColor: StroopItem.green,
        reactionTimeMs: recallTimeMs,
        isCorrect: isPerfect,
        isTimeout: false,
      ),
    );

    _phase = RadarPhase.trialResult;
    notifyListeners();

    _phaseTimer = Timer(const Duration(milliseconds: 600), () {
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
    _motionTicker?.cancel();

    final totalTargets = max(1, _totalTargetsPossible);
    final accuracy = ((_totalTargetsIdentified / totalTargets) * 100).round().clamp(0, 100);

    // Median Reaction Time
    int medianRT = 1800;
    if (_reactionTimesMs.isNotEmpty) {
      final sorted = List<int>.from(_reactionTimesMs)..sort();
      final mid = sorted.length ~/ 2;
      medianRT = sorted.length.isOdd ? sorted[mid] : ((sorted[mid - 1] + sorted[mid]) ~/ 2);
    }

    // Speed Score
    final speed = (100 - (((medianRT - 800) / 2200) * 100)).round().clamp(0, 100);

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
      gameName: 'Focus Radar',
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
      timeouts: _totalDistractorMistakes,
      createdAt: DateTime.now(),
      synced: user?.isGuest == false,
      trials: _recordedTrials,
    );

    _lastCompletedSession = session;
    StorageService.saveRadarSession(session);

    _phase = RadarPhase.finished;
    notifyListeners();
  }

  void quitBlock() {
    _phaseTimer?.cancel();
    _motionTicker?.cancel();
    _phase = RadarPhase.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _motionTicker?.cancel();
    super.dispose();
  }
}
