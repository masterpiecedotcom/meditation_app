import 'package:flutter/material.dart';
import '../providers/breathing_provider.dart'; // For BreathingPhase enum
import '../models/app_theme.dart';

class PhaseIndicator extends StatelessWidget {
  final String label;
  final IconData icon;
  final BreathingPhase phase;
  final bool isActive;
  final AppTheme theme; // Pass theme for colors

  const PhaseIndicator({
    super.key,
    required this.label,
    required this.icon,
    required this.phase,
    required this.isActive,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorColor = theme.getPhaseIndicatorColor(phase);
    final iconColor = theme.getPhaseIconColor(phase);
    // Determine text color based on overall theme brightness
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black87;
    final subtleTextColor = theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54;

    return AnimatedScale(
      scale: isActive ? 1.15 : 1.0, // Slightly larger scale when active
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular background for icon
          AnimatedContainer( // Animate border appearance
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: indicatorColor, // Use theme-based background
              shape: BoxShape.circle,
              border: isActive
                  ? Border.all(color: textColor.withAlpha(189), width: 2.0) // Thicker border when active
                  : Border.all(color: Colors.transparent, width: 2.0), // Keep space for border
              boxShadow: isActive ? [ // Add subtle glow when active
                BoxShadow(
                  color: indicatorColor.withAlpha(128),
                  blurRadius: 8.0,
                  spreadRadius: 1.0,
                )
              ] : null,
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 24), // Slightly larger icon
            ),
          ),
          const SizedBox(height: 8),
          // Label text
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? textColor : subtleTextColor, // Adjust color based on active state and theme
            ),
          ),
        ],
      ),
    );
  }
}
