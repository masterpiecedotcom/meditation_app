import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/breathing_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/breathing_circle.dart';
import '../widgets/controls_row.dart';
import '../widgets/phase_indicator.dart';
import '../constants/app_constants.dart';
import '../models/app_theme.dart'; // Import AppTheme
// import '../services/ad_service.dart'; // Uncomment for AdMob

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {

  // @override
  // void initState() { // Uncomment for AdMob
  //   super.initState();
  //   // Optionally load interstitial ad when screen loads
  //   // AdService.instance.loadInterstitialAd();
  // }

  @override
  Widget build(BuildContext context) {
    // Access providers using 'watch' where UI needs to rebuild on change
    final breathingProvider = context.watch<BreathingProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final currentTheme = themeProvider.currentTheme;

    // Determine text color based on theme brightness for better contrast
    final textColor = currentTheme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black87; // Use slightly off-black for light themes
    final subtleTextColor = currentTheme.brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;


    return Scaffold(
      // Use AnimatedContainer for smooth background transitions
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500), // Theme change animation speed
        curve: Curves.easeInOut,
        decoration: currentTheme.backgroundDecoration, // Get decoration from theme
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView( // Allows scrolling if content overflows
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    '4-7-8 Breathing',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor, // Use dynamic text color
                      shadows: currentTheme.brightness == Brightness.dark ? [ // Only add shadow on dark themes?
                        Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2))
                      ] : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    'A simple technique for relaxation and stress relief',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: subtleTextColor), // Use dynamic subtle text color
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Breathing Circle Widget
                  BreathingCircle(
                    phase: breathingProvider.currentPhase,
                    // Show initial duration when idle, otherwise current time
                    timerText: breathingProvider.isRunning || breathingProvider.currentPhase != BreathingPhase.idle
                        ? breathingProvider.currentTime.toString()
                        : inhaleDuration.toString(),
                    scale: breathingProvider.circleScale,
                    theme: currentTheme, // Pass theme for colors
                  ),
                  const SizedBox(height: 40),

                  // Phase Indicators Row
                  _buildPhaseIndicators(context, breathingProvider, currentTheme),
                  const SizedBox(height: 40),

                  // Start/Pause Button
                  ElevatedButton(
                    onPressed: breathingProvider.toggleStartPause,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentTheme.buttonBackgroundColor ?? Theme.of(context).colorScheme.primary, // Fallback to theme primary
                      foregroundColor: currentTheme.buttonTextColor ?? Theme.of(context).colorScheme.onPrimary, // Fallback to theme onPrimary
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14), // Slightly larger padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4, // Slightly less elevation
                      shadowColor: Colors.black.withOpacity(0.4),
                    ).copyWith(
                      overlayColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                            // Use HSLColor to darken/lighten based on brightness
                            final baseColor = currentTheme.buttonBackgroundColor ?? Theme.of(context).colorScheme.primary;
                            final hslColor = HSLColor.fromColor(baseColor);
                            final adjustedColor = hslColor.withLightness((hslColor.lightness * 0.9).clamp(0.0, 1.0)).toColor();
                            return adjustedColor;
                          }
                          return null;
                        },
                      ),
                    ),
                    child: Text(
                      breathingProvider.startButtonText,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16, // Slightly larger font
                          color: currentTheme.buttonTextColor ?? Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Controls Row Widget (Sound Toggle, Cycle Count, Theme/Sound Buttons)
                  ControlsRow(textColor: textColor), // Pass text color for icons/labels
                  const SizedBox(height: 40),

                  // Instructions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add padding
                    child: Text(
                      'Breathe in for $inhaleDuration seconds, hold for $holdDuration seconds, exhale for $exhaleDuration seconds.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium // Slightly larger instruction text
                          ?.copyWith(color: subtleTextColor, height: 1.4), // Add line height
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8), // Increase spacing
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Repeat for $totalCycles cycles for best results.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: subtleTextColor, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // --- AdMob Banner Placeholder ---
      // bottomNavigationBar: AdService.instance.buildBannerWidget(), // Uncomment for AdMob
    );
  }

  // Builds the row of phase indicators (Inhale, Hold, Exhale)
  Widget _buildPhaseIndicators(BuildContext context, BreathingProvider provider, AppTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        PhaseIndicator(
          label: 'Inhale',
          icon: Icons.arrow_upward, // Using Material icons now
          phase: BreathingPhase.inhale,
          isActive: provider.currentPhase == BreathingPhase.inhale,
          theme: theme, // Pass theme for colors
        ),
        PhaseIndicator(
          label: 'Hold',
          icon: Icons.pause,
          phase: BreathingPhase.hold,
          isActive: provider.currentPhase == BreathingPhase.hold,
          theme: theme,
        ),
        PhaseIndicator(
          label: 'Exhale',
          icon: Icons.arrow_downward,
          phase: BreathingPhase.exhale,
          isActive: provider.currentPhase == BreathingPhase.exhale,
          theme: theme,
        ),
      ],
    );
  }
}
