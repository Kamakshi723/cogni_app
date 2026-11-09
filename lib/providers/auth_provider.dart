import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = true;
  bool _isOffline = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  bool get isAuthenticated => _user != null;
  bool get hasConsent => _user?.consentAccepted ?? false;
  int get highestUnlockedLevel => StorageService.getHighestUnlockedLevel();

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _isOffline = StorageService.isOfflineMode();
    _user = StorageService.getUser();

    // 800ms minimum display per spec for Splash
    await Future.delayed(const Duration(milliseconds: 800));

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> acceptConsent() async {
    if (_user == null) {
      // Create guest or base user if not signed in yet starting at Level 1
      _user = UserModel(
        uid: const Uuid().v4(),
        name: 'Kashish',
        email: '',
        level: 1,
        isGuest: true,
        consentAccepted: true,
        consentAcceptedAt: DateTime.now(),
        consentVersion: '1.0',
        createdAt: DateTime.now(),
      );
    } else {
      _user = _user!.copyWith(
        consentAccepted: true,
        consentAcceptedAt: DateTime.now(),
        consentVersion: '1.0',
      );
    }
    await StorageService.saveUser(_user!);
    notifyListeners();
    return true;
  }

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final newUser = UserModel(
      uid: const Uuid().v4(),
      name: name.trim().isEmpty ? 'Kashish' : name.trim(),
      email: email.trim(),
      level: 1, // Start at Level 1
      isGuest: false,
      consentAccepted: true,
      consentAcceptedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    _user = newUser;
    await StorageService.saveUser(newUser);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    // Restore or create user
    final existingUser = StorageService.getUser();
    if (existingUser != null && existingUser.email == email.trim()) {
      _user = existingUser;
    } else {
      _user = UserModel(
        uid: const Uuid().v4(),
        name: 'Kashish',
        email: email.trim(),
        level: 1, // Start at Level 1
        isGuest: false,
        consentAccepted: true,
        consentAcceptedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
    }

    await StorageService.saveUser(_user!);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    final googleUser = UserModel(
      uid: const Uuid().v4(),
      name: 'Kashish',
      email: 'kashish@example.com',
      level: 1, // Start at Level 1
      isGuest: false,
      consentAccepted: true,
      consentAcceptedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    _user = googleUser;
    await StorageService.saveUser(googleUser);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInAsGuest() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    final guestUser = UserModel(
      uid: const Uuid().v4(),
      name: 'Guest Player',
      email: '',
      level: 1, // Start at Level 1
      isGuest: true,
      consentAccepted: true,
      consentAcceptedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    _user = guestUser;
    await StorageService.saveUser(guestUser);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateName(String newName) async {
    if (_user == null) return;
    _user = _user!.copyWith(name: newName);
    await StorageService.saveUser(_user!);
    notifyListeners();
  }

  Future<void> updatePreferences({
    bool? sound,
    bool? haptics,
    bool? colorBlindMode,
  }) async {
    if (_user == null) return;
    _user = _user!.copyWith(
      soundEnabled: sound ?? _user!.soundEnabled,
      hapticsEnabled: haptics ?? _user!.hapticsEnabled,
      colorBlindMode: colorBlindMode ?? _user!.colorBlindMode,
    );
    await StorageService.saveUser(_user!);
    notifyListeners();
  }

  void refreshFromStorage() {
    _user = StorageService.getUser();
    _isOffline = StorageService.isOfflineMode();
    notifyListeners();
  }

  Future<void> toggleOfflineMode() async {
    _isOffline = !_isOffline;
    await StorageService.setOfflineMode(_isOffline);
    notifyListeners();
  }

  Future<void> signOut() async {
    _user = null;
    await StorageService.clearUser();
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    _user = null;
    await StorageService.deleteAllData();
    notifyListeners();
  }
}
