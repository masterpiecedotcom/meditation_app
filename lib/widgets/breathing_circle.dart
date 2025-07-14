import 'package:flutter/material.dart';
import '../providers/breathing_provider.dart'; // For BreathingPhase enum
import '../models/app_theme.dart';

class BreathingCircle extends StatelessWidget {
  final BreathingPhase phase;
  final String timerText;
  final double scale;
  final AppTheme theme; // Pass theme for colors

  const BreathingCircle({
    super.key,
    required this.phase,
    required this.timerText,
    required this.scale,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final phaseColor = theme.getPhaseColor(phase);
    // Determine text color based on the brightness of the phase color for contrast
    final textColor = ThemeData.estimateBrightnessForColor(phaseColor) == Brightness.dark
        ? Colors.white // Light text on dark background
        : Colors.black87; // Dark text on light background


    return AnimatedContainer(
      duration: const Duration(milliseconds: 500), // Animation speed for color/scale change
      curve: Curves.easeInOut,
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: phaseColor,
        boxShadow: theme.brightness == Brightness.dark ? [ // Only show shadow on dark themes?
          BoxShadow(
            color: Colors.black.withAlpha(102), // Darker shadow
            blurRadius: 25, // Slightly smaller blur
            spreadRadius: 2, // Slight spread
          )
        ] : [ // Lighter shadow for light themes
          BoxShadow(
            color: Colors.grey.withAlpha(125),
            blurRadius: 20,
            spreadRadius: 1,
          )
        ],
      ),
      transformAlignment: Alignment.center,
      transform: Matrix4.identity()..scale(scale), // Apply scale animation
      child: Center(
        child: Text(
          timerText,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 60, // Slightly smaller font size?
            color: textColor, // Use contrast-based text color
            shadows: theme.brightness == Brightness.dark ? [ // Subtle shadow for text on dark bg
              Shadow(
                  blurRadius: 4.0,
                  color: Colors.black.withAlpha(125),
                  offset: const Offset(0, 2))
            ] : null, // No text shadow on light bg
          ),
        ),
      ),
    );
  }
}
