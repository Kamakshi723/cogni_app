import 'package:flutter/services.dart';

class SoundHapticService {
  static void triggerTap(bool hapticsEnabled) {
    if (hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  static void triggerCorrect(bool soundEnabled, bool hapticsEnabled) {
    if (hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    if (soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  static void triggerMiss(bool soundEnabled, bool hapticsEnabled) {
    if (hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    if (soundEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  static void triggerLevelUp(bool soundEnabled, bool hapticsEnabled) {
    if (hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    if (soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}
