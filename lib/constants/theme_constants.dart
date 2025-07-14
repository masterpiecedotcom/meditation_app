import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../providers/breathing_provider.dart'; // For BreathingPhase enum

// Defines the predefined themes available in the app
class AppThemes {

  // --- Theme Definitions ---

  static final AppTheme defaultGradient = AppTheme(
    name: 'Sunset Gradient', // Display name
    brightness: Brightness.dark, // Dark theme base
    primarySeedColor: const Color(0xFFb21f1f), // Use red as seed
    backgroundDecoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF1a2a6c), // Dark Blue
          Color(0xFFb21f1f), // Dark Red
          Color(0xFFfdbb2d), // Orange/Yellow
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    // Specific button colors for this theme
    buttonBackgroundColor: Colors.white.withAlpha(51), // ~20% opacity
    buttonTextColor: Colors.white,
    // Use default phase color logic
    getPhaseColor: AppTheme.defaultGetPhaseColor,
    getPhaseIndicatorColor: AppTheme.defaultGetPhaseIndicatorColor,
    getPhaseIconColor: AppTheme.defaultGetPhaseIconColor,
  );

  static final AppTheme oceanBlue = AppTheme(
    name: 'Ocean Blue',
    brightness: Brightness.dark,
    primarySeedColor: const Color(0xFF4364F7), // Medium blue seed
    backgroundDecoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF6FB1FC)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    buttonBackgroundColor: Colors.white.withAlpha(77), // ~30% opacity
    buttonTextColor: Colors.white,
    // Custom phase circle colors for this theme
    getPhaseColor: (phase) {
      switch (phase) {
        case BreathingPhase.inhale: return Colors.cyan.withAlpha(128); // ~50% opacity
        case BreathingPhase.hold: return Colors.lightBlue.withAlpha(128); // ~50% opacity
        case BreathingPhase.exhale: return Colors.teal.withAlpha(128); // ~50% opacity
        case BreathingPhase.idle: return Colors.blueGrey.withAlpha(77); // ~30% opacity
      }
    },
    // Use default logic for indicator background and icon colors
    getPhaseIndicatorColor: (phase) => AppTheme.defaultGetPhaseColor(phase).withAlpha(128), // Use default but more opaque
    getPhaseIconColor: AppTheme.defaultGetPhaseIconColor,
  );

  static final AppTheme forestGreen = AppTheme(
    name: 'Forest Green',
    brightness: Brightness.dark,
    primarySeedColor: const Color(0xFF71B280), // Light green seed
    backgroundDecoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF134E5E), Color(0xFF71B280)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    buttonBackgroundColor: Colors.white.withAlpha(64), // ~25% opacity
    buttonTextColor: Colors.white,
    // Custom phase circle colors
    getPhaseColor: (phase) {
      switch (phase) {
        case BreathingPhase.inhale: return Colors.lightGreen.withAlpha(77); // ~30% opacity
        case BreathingPhase.hold: return Colors.lime.withAlpha(77); // ~30% opacity
        case BreathingPhase.exhale: return Colors.teal.withAlpha(77); // ~30% opacity
        case BreathingPhase.idle: return Colors.green.withAlpha(26); // ~10% opacity
      }
    },
    // Use default logic for indicator background and icon colors
    getPhaseIndicatorColor: (phase) => AppTheme.defaultGetPhaseColor(phase).withAlpha(102), // ~40% opacity
    getPhaseIconColor: AppTheme.defaultGetPhaseIconColor,
  );

  static final AppTheme simpleLight = AppTheme(
    name: 'Simple Light',
    brightness: Brightness.light, // Light theme base
    primarySeedColor: Colors.cyan, // Cyan seed color
    backgroundDecoration: const BoxDecoration(
      color: Color(0xFFE0F7FA), // Light cyan background
    ),
    // Let button colors be derived from ColorScheme by not providing them
    buttonBackgroundColor: null,
    buttonTextColor: null,
    // Custom phase circle colors for light theme
    getPhaseColor: (phase) {
      switch (phase) {
        case BreathingPhase.inhale: return Colors.lightBlue.shade100;
        case BreathingPhase.hold: return Colors.yellow.shade100;
        case BreathingPhase.exhale: return Colors.green.shade100;
        case BreathingPhase.idle: return Colors.blueGrey.shade50;
      }
    },
    // Custom indicator background colors
    getPhaseIndicatorColor: (phase) {
      switch (phase) {
        case BreathingPhase.inhale: return Colors.lightBlue.shade200;
        case BreathingPhase.hold: return Colors.yellow.shade200;
        case BreathingPhase.exhale: return Colors.green.shade200;
        case BreathingPhase.idle: return Colors.blueGrey.shade100;
      }
    },
    // Custom indicator icon colors for light theme
    getPhaseIconColor: (phase) {
      switch (phase) {
        case BreathingPhase.inhale: return Colors.green.shade800;
        case BreathingPhase.hold: return Colors.orange.shade800;
        case BreathingPhase.exhale: return Colors.blue.shade800;
        case BreathingPhase.idle: return Colors.grey.shade700;
      }
    },
  );

  // --- List of Available Themes ---
  static List<AppTheme> availableThemes = [
    defaultGradient,
    oceanBlue,
    forestGreen,
    simpleLight,
    // Add more themes here as needed
  ];
}
