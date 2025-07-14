import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/breathing_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/breathing_circle.dart';
import '../widgets/controls_row.dart';
import '../widgets/phase_indicator.dart';
import '../constants/app_constants.dart';
import '../models/app_theme.dart';
import '../services/ad_service.dart'; // Uncomment for AdMob

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {

  @override
  void initState() {
    super.initState();
    // Set up the listener to rebuild the UI when the ad loads or fails
    AdService.instance.setBannerListener(() {
      if (mounted) { // Check if the widget is still in the tree
        setState(() {});
      }
    });

    // Load the ads for this screen
    AdService.instance.loadBannerAd();
    AdService.instance.loadInterstitialAd();
  }

  @override
  void dispose() {
    // Clean up the listener and dispose the ad to prevent memory leaks
    AdService.instance.removeBannerListener();
    AdService.instance.disposeBannerAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breathingProvider = context.watch<BreathingProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final currentTheme = themeProvider.currentTheme;

    final textColor = currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black87;
    final subtleTextColor = currentTheme.brightness == Brightness.dark ? Colors.white70 : Colors.black54;
    final bool showRestartButton = breathingProvider.isRunning || breathingProvider.currentPhase != BreathingPhase.idle;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: currentTheme.backgroundDecoration,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    '4-7-8 Breathing',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      shadows: currentTheme.brightness == Brightness.dark ? [
                        Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withAlpha(77),
                            offset: const Offset(0, 2))
                      ] : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    'A simple technique for relaxation and stress relief',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: subtleTextColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Breathing Circle Widget
                  BreathingCircle(
                    phase: breathingProvider.currentPhase,
                    timerText: breathingProvider.isRunning || breathingProvider.currentPhase != BreathingPhase.idle
                        ? breathingProvider.currentTime.toString()
                        : inhaleDuration.toString(),
                    scale: breathingProvider.circleScale,
                    theme: currentTheme,
                  ),
                  const SizedBox(height: 40),

                  // Phase Indicators Row
                  _buildPhaseIndicators(context, breathingProvider, currentTheme),
                  const SizedBox(height: 40),

                  // Start/Pause and Restart Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: breathingProvider.toggleStartPause,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentTheme.buttonBackgroundColor ?? Theme.of(context).colorScheme.primary,
                          foregroundColor: currentTheme.buttonTextColor ?? Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 4,
                        ),
                        child: Text(
                          breathingProvider.startButtonText,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: currentTheme.buttonTextColor ?? Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                      if (showRestartButton) const SizedBox(width: 16),
                      AnimatedOpacity(
                        opacity: showRestartButton ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: IgnorePointer(
                          ignoring: !showRestartButton,
                          child: showRestartButton
                              ? ElevatedButton.icon(
                            onPressed: breathingProvider.reset,
                            icon: const Icon(Icons.refresh, size: 20),
                            label: const Text('Restart'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (currentTheme.buttonBackgroundColor ?? Theme.of(context).colorScheme.secondary).withAlpha(180),
                              foregroundColor: currentTheme.buttonTextColor ?? Theme.of(context).colorScheme.onSecondary,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 2,
                            ),
                          )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Controls Row Widget
                  ControlsRow(textColor: textColor),
                  const SizedBox(height: 40),

                  // Instructions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Breathe in for $inhaleDuration seconds, hold for $holdDuration seconds, exhale for $exhaleDuration seconds.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: subtleTextColor, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Repeat for $totalCycles cycles for best results.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: subtleTextColor, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // --- AdMob Banner ---
      // This now rebuilds correctly when the ad is loaded
      bottomNavigationBar: AdService.instance.buildBannerWidget(),
    );
  }

  Widget _buildPhaseIndicators(BuildContext context, BreathingProvider provider, AppTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        PhaseIndicator(label: 'Inhale', icon: Icons.arrow_upward, phase: BreathingPhase.inhale, isActive: provider.currentPhase == BreathingPhase.inhale, theme: theme),
        PhaseIndicator(label: 'Hold', icon: Icons.pause, phase: BreathingPhase.hold, isActive: provider.currentPhase == BreathingPhase.hold, theme: theme),
        PhaseIndicator(label: 'Exhale', icon: Icons.arrow_downward, phase: BreathingPhase.exhale, isActive: provider.currentPhase == BreathingPhase.exhale, theme: theme),
      ],
    );
  }
}
