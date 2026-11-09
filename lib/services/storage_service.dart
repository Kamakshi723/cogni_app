import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';

class StorageService {
  static const String _userKey = 'cogni_user_data';
  static const String _sessionsKey = 'cogni_sessions_data';
  static const String _isOfflineModeKey = 'cogni_offline_mode';
  static const String _unlockedLevelKey = 'cogni_highest_unlocked_level';

  // Memory Matrix Keys
  static const String _matrixUnlockedLevelKey = 'cogni_matrix_highest_unlocked_level';
  static const String _matrixSessionsKey = 'cogni_matrix_sessions_data';

  // Speed Tap Keys
  static const String _speedTapUnlockedLevelKey = 'cogni_speed_tap_highest_unlocked_level';
  static const String _speedTapSessionsKey = 'cogni_speed_tap_sessions_data';

  // Focus Radar Keys
  static const String _radarUnlockedLevelKey = 'cogni_radar_highest_unlocked_level';
  static const String _radarSessionsKey = 'cogni_radar_sessions_data';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('StorageService must be initialized before use.');
    }
    return _prefs!;
  }

  // --- User Operations ---
  static UserModel? getUser() {
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveUser(UserModel user) async {
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<void> clearUser() async {
    await prefs.remove(_userKey);
  }

  // --- Stroop: 15 Levels & Progression Operations ---
  static int getHighestUnlockedLevel() {
    final saved = prefs.getInt(_unlockedLevelKey);
    if (saved != null) return saved.clamp(1, 15);
    final user = getUser();
    return (user?.level ?? 1).clamp(1, 15);
  }

  static Future<void> unlockLevel(int level) async {
    final current = getHighestUnlockedLevel();
    final newLevel = max(current, level).clamp(1, 15);
    await prefs.setInt(_unlockedLevelKey, newLevel);

    final user = getUser();
    if (user != null && user.level < newLevel) {
      await saveUser(user.copyWith(level: newLevel));
    }
  }

  static int getBestScoreForLevel(int level) {
    final sessions = getSessions();
    final levelSessions = sessions.where((s) => s.levelBefore == level).toList();
    if (levelSessions.isEmpty) return 0;
    return levelSessions.map((s) => s.score).reduce(max);
  }

  static bool isLevelCompleted(int level) {
    if (level < getHighestUnlockedLevel()) return true;
    return getBestScoreForLevel(level) >= 60;
  }

  // --- Memory Matrix: 15 Levels & Progression Operations ---
  static int getMatrixHighestUnlockedLevel() {
    final saved = prefs.getInt(_matrixUnlockedLevelKey);
    if (saved != null) return saved.clamp(1, 15);
    return 1;
  }

  static Future<void> unlockMatrixLevel(int level) async {
    final current = getMatrixHighestUnlockedLevel();
    final newLevel = max(current, level).clamp(1, 15);
    await prefs.setInt(_matrixUnlockedLevelKey, newLevel);
  }

  static int getMatrixBestScoreForLevel(int level) {
    final sessions = getMatrixSessions();
    final levelSessions = sessions.where((s) => s.levelBefore == level).toList();
    if (levelSessions.isEmpty) return 0;
    return levelSessions.map((s) => s.score).reduce(max);
  }

  static bool isMatrixLevelCompleted(int level) {
    if (level < getMatrixHighestUnlockedLevel()) return true;
    return getMatrixBestScoreForLevel(level) >= 60;
  }

  static List<SessionModel> getMatrixSessions() {
    final raw = prefs.getString(_matrixSessionsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final sessions = list
          .map((item) => SessionModel.fromJson(item as Map<String, dynamic>))
          .toList();
      sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sessions;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveMatrixSession(SessionModel session) async {
    final sessions = getMatrixSessions();
    sessions.insert(0, session);
    final capped = sessions.take(50).toList();
    final jsonList = capped.map((s) => s.toJson()).toList();
    await prefs.setString(_matrixSessionsKey, jsonEncode(jsonList));

    if (session.levelChange > 0) {
      await unlockMatrixLevel(session.levelAfter);
    }
  }

  // --- Speed Tap Operations ---
  static int getSpeedTapHighestUnlockedLevel() {
    return prefs.getInt(_speedTapUnlockedLevelKey) ?? 1;
  }

  static Future<void> unlockSpeedTapLevel(int level) async {
    final current = getSpeedTapHighestUnlockedLevel();
    if (level > current) {
      await prefs.setInt(_speedTapUnlockedLevelKey, level.clamp(1, 15));
    }
  }

  static int getSpeedTapBestScoreForLevel(int level) {
    final sessions = getSpeedTapSessions();
    final matching = sessions.where((s) => s.levelBefore == level).toList();
    if (matching.isEmpty) return 0;
    return matching.map((s) => s.score).reduce(max);
  }

  static bool isSpeedTapLevelCompleted(int level) {
    if (level < getSpeedTapHighestUnlockedLevel()) return true;
    return getSpeedTapBestScoreForLevel(level) >= 60;
  }

  static List<SessionModel> getSpeedTapSessions() {
    final raw = prefs.getString(_speedTapSessionsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final sessions = list
          .map((item) => SessionModel.fromJson(item as Map<String, dynamic>))
          .toList();
      sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sessions;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveSpeedTapSession(SessionModel session) async {
    final sessions = getSpeedTapSessions();
    sessions.insert(0, session);
    final capped = sessions.take(50).toList();
    final jsonList = capped.map((s) => s.toJson()).toList();
    await prefs.setString(_speedTapSessionsKey, jsonEncode(jsonList));

    if (session.levelChange > 0) {
      await unlockSpeedTapLevel(session.levelAfter);
    }
  }

  // --- Focus Radar Operations ---
  static int getRadarHighestUnlockedLevel() {
    return prefs.getInt(_radarUnlockedLevelKey) ?? 1;
  }

  static Future<void> unlockRadarLevel(int level) async {
    final current = getRadarHighestUnlockedLevel();
    if (level > current) {
      await prefs.setInt(_radarUnlockedLevelKey, level.clamp(1, 15));
    }
  }

  static int getRadarBestScoreForLevel(int level) {
    final sessions = getRadarSessions();
    final matching = sessions.where((s) => s.levelBefore == level).toList();
    if (matching.isEmpty) return 0;
    return matching.map((s) => s.score).reduce(max);
  }

  static bool isRadarLevelCompleted(int level) {
    if (level < getRadarHighestUnlockedLevel()) return true;
    return getRadarBestScoreForLevel(level) >= 60;
  }

  static List<SessionModel> getRadarSessions() {
    final raw = prefs.getString(_radarSessionsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final sessions = list
          .map((item) => SessionModel.fromJson(item as Map<String, dynamic>))
          .toList();
      sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sessions;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveRadarSession(SessionModel session) async {
    final sessions = getRadarSessions();
    sessions.insert(0, session);
    final capped = sessions.take(50).toList();
    final jsonList = capped.map((s) => s.toJson()).toList();
    await prefs.setString(_radarSessionsKey, jsonEncode(jsonList));

    if (session.levelChange > 0) {
      await unlockRadarLevel(session.levelAfter);
    }
  }

  // --- Stroop Sessions Operations ---
  static List<SessionModel> getSessions() {
    final raw = prefs.getString(_sessionsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final sessions = list
          .map((item) => SessionModel.fromJson(item as Map<String, dynamic>))
          .toList();
      // Sorted by createdAt descending (most recent first)
      sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sessions;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveSession(SessionModel session) async {
    final sessions = getSessions();
    // Add to beginning
    sessions.insert(0, session);
    // Limit to 50 sessions per spec
    final capped = sessions.take(50).toList();
    final jsonList = capped.map((s) => s.toJson()).toList();
    await prefs.setString(_sessionsKey, jsonEncode(jsonList));

    // Also update user's lastSessionAt and level
    final user = getUser();
    if (user != null) {
      final updatedUser = user.copyWith(
        level: session.levelAfter,
        lastSessionAt: session.createdAt,
      );
      await saveUser(updatedUser);
    }
  }

  // --- Export Data ---
  static String exportAllData() {
    final user = getUser();
    final sessions = getSessions();
    final matrixSessions = getMatrixSessions();
    final speedTapSessions = getSpeedTapSessions();
    final radarSessions = getRadarSessions();
    final exportMap = {
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'Cogni - Short focus games',
      'version': '1.0.0',
      'user': user?.toJson(),
      'highestUnlockedLevel': getHighestUnlockedLevel(),
      'matrixHighestUnlockedLevel': getMatrixHighestUnlockedLevel(),
      'speedTapHighestUnlockedLevel': getSpeedTapHighestUnlockedLevel(),
      'radarHighestUnlockedLevel': getRadarHighestUnlockedLevel(),
      'sessionsCount': sessions.length,
      'matrixSessionsCount': matrixSessions.length,
      'speedTapSessionsCount': speedTapSessions.length,
      'radarSessionsCount': radarSessions.length,
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'matrixSessions': matrixSessions.map((s) => s.toJson()).toList(),
      'speedTapSessions': speedTapSessions.map((s) => s.toJson()).toList(),
      'radarSessions': radarSessions.map((s) => s.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(exportMap);
  }

  // --- Delete Account & All Data ---
  static Future<void> deleteAllData() async {
    await prefs.remove(_userKey);
    await prefs.remove(_sessionsKey);
    await prefs.remove(_matrixSessionsKey);
    await prefs.remove(_speedTapSessionsKey);
    await prefs.remove(_radarSessionsKey);
    await prefs.remove(_isOfflineModeKey);
    await prefs.remove(_unlockedLevelKey);
    await prefs.remove(_matrixUnlockedLevelKey);
    await prefs.remove(_speedTapUnlockedLevelKey);
    await prefs.remove(_radarUnlockedLevelKey);
  }

  // --- Offline Flag Simulation ---
  static bool isOfflineMode() {
    return prefs.getBool(_isOfflineModeKey) ?? false;
  }

  static Future<void> setOfflineMode(bool offline) async {
    await prefs.setBool(_isOfflineModeKey, offline);
  }
}
