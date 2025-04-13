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
        // Note: Animated gradient background requires a stateful widget
        // or a custom painter setup for continuous animation.
        // Using a static gradient here for simplicity in refactoring.
      ),
    ),
    // Specific button colors for this theme
    buttonBackgroundColor: Colors.white.withOpacity(0.2),
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
    buttonBackgroundColor: Colors.white.withOpacity(0.3),
    buttonTextColor: Colors.white,
    // Custom phase circle colors for this theme
    getPhaseColor: (phase) {
      switch (phase) {
        case BreathingPhase.inhale: return Colors.cyan.withOpacity(0.5);
        case BreathingPhase.hold: return Colors.lightBlue.withOpacity(0.5);
        case BreathingPhase.exhale: return Colors.teal.withOpacity(0.5);
        case BreathingPhase.idle:
        default: return Colors.blueGrey.withOpacity(0.3);
      }
    },
    // Use default logic for indicator background and icon colors
    getPhaseIndicatorColor: AppTheme.defaultGetPhaseIndicatorColor,
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
    buttonBackgroundColor: Colors.white.withOpacity(0.25),
    buttonTextColor: Colors.white,
    // Custom phase circle colors
    getPhaseColor: (phase) {
      switch (phase) {
        case BreathingPhase.inhale: return Colors.lightGreen.withOpacity(0.4);
        case BreathingPhase.hold: return Colors.lime.withOpacity(0.4);
        case BreathingPhase.exhale: return Colors.teal.withOpacity(0.4);
        case BreathingPhase.idle:
        default: return Colors.green.withOpacity(0.2);
      }
    },
    // Use default logic for indicator background and icon colors
    getPhaseIndicatorColor: AppTheme.defaultGetPhaseIndicatorColor,
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
        case BreathingPhase.idle:
        default: return Colors.blueGrey.shade50;
      }
    },
    // Custom indicator background colors
    getPhaseIndicatorColor: (phase) {
      switch (phase) {
        case BreathingPhase.inhale: return Colors.lightBlue.shade200;
        case BreathingPhase.hold: return Colors.yellow.shade200;
        case BreathingPhase.exhale: return Colors.green.shade200;
        case BreathingPhase.idle:
        default: return Colors.blueGrey.shade100;
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
