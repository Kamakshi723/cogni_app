import 'package:flutter/material.dart';

enum StroopItem {
  red,
  green,
  blue,
  yellow,
}

class StroopColors {
  // Private constructor to prevent instantiation
  StroopColors._();

  static const Color red = Color(0xFFE5484D);
  static const Color green = Color(0xFF12A594); // Teal-leaning, colourblind-safe
  static const Color blue = Color(0xFF3E63DD);
  static const Color yellow = Color(0xFFFFC53D);

  static Color getColor(StroopItem item) {
    switch (item) {
      case StroopItem.red:
        return red;
      case StroopItem.green:
        return green;
      case StroopItem.blue:
        return blue;
      case StroopItem.yellow:
        return yellow;
    }
  }

  static String getName(StroopItem item) {
    switch (item) {
      case StroopItem.red:
        return 'Red';
      case StroopItem.green:
        return 'Green';
      case StroopItem.blue:
        return 'Blue';
      case StroopItem.yellow:
        return 'Yellow';
    }
  }

  /// Distinct symbols for Colour-blind mode:
  /// Red: ●
  /// Green: ▲
  /// Blue: ■
  /// Yellow: ★
  static String getSymbol(StroopItem item) {
    switch (item) {
      case StroopItem.red:
        return '●';
      case StroopItem.green:
        return '▲';
      case StroopItem.blue:
        return '■';
      case StroopItem.yellow:
        return '★';
    }
  }

  /// Yellow uses dark text (#14161A) for contrast; others use pure white (#FFFFFF).
  static Color getTextColor(StroopItem item) {
    switch (item) {
      case StroopItem.yellow:
        return const Color(0xFF14161A);
      case StroopItem.red:
      case StroopItem.green:
      case StroopItem.blue:
        return const Color(0xFFFFFFFF);
    }
  }
}
