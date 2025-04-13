import 'package:flutter/material.dart';
import '../providers/breathing_provider.dart'; // For BreathingPhase enum

// Defines the properties of a background theme
class AppTheme {
  final String name; // Unique name for identification and display
  final BoxDecoration backgroundDecoration; // How the background looks
  final Brightness brightness; // Determines default dark/light text/icon colors
  final Color primarySeedColor; // Seed color for ColorScheme generation

  // Optional specific colors for UI elements (override ColorScheme if needed)
  final Color? buttonBackgroundColor;
  final Color? buttonTextColor;

  // Functions to get phase-specific colors, allowing themes to customize them
  final Color Function(BreathingPhase phase) getPhaseColor;
  final Color Function(BreathingPhase phase) getPhaseIndicatorColor;
  final Color Function(BreathingPhase phase) getPhaseIconColor;


  const AppTheme({
    required this.name,
    required this.backgroundDecoration,
    required this.brightness,
    required this.primarySeedColor, // Added seed color
    this.buttonBackgroundColor, // Made optional
    this.buttonTextColor,     // Made optional
    required this.getPhaseColor,
    required this.getPhaseIndicatorColor,
    required this.getPhaseIconColor,
  });

  // --- Default Color Logic (static methods for reuse) ---

  // Default logic for the main breathing circle color based on phase
  static Color defaultGetPhaseColor(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale: return Colors.blue.withOpacity(0.4);
      case BreathingPhase.hold: return Colors.yellow.withOpacity(0.4);
      case BreathingPhase.exhale: return Colors.green.withOpacity(0.4);
      case BreathingPhase.idle:
      default: return Colors.white.withOpacity(0.15); // Slightly more opaque idle
    }
  }

  // Default logic for the small indicator circle background color
  static Color defaultGetPhaseIndicatorColor(BreathingPhase phase) {
    // Often the same as the main phase color, but could differ
    return defaultGetPhaseColor(phase);
  }

  // Default logic for the icon color within the small indicator circle
  static Color defaultGetPhaseIconColor(BreathingPhase phase) {
    // Colors matching original CSS concept
    switch (phase) {
      case BreathingPhase.inhale: return Colors.lightGreenAccent.shade400;
      case BreathingPhase.hold: return Colors.yellowAccent.shade400;
      case BreathingPhase.exhale: return Colors.lightBlueAccent.shade400;
      case BreathingPhase.idle: return Colors.grey.shade400;
    }
  }

  // --- Equality Override ---
  // Needed for comparing themes (e.g., in SelectorDialog)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppTheme &&
              runtimeType == other.runtimeType &&
              name == other.name; // Compare based on unique name

  @override
  int get hashCode => name.hashCode; // Hash based on unique name
}
