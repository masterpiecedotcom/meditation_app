import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../constants/app_constants.dart';
import 'sound_provider.dart'; // Import SoundProvider

// Define the phases
enum BreathingPhase { inhale, hold, exhale, idle }

class BreathingProvider with ChangeNotifier {
  final SoundProvider _soundProvider; // Inject SoundProvider

  // State variables
  BreathingPhase _currentPhase = BreathingPhase.idle;
  int _currentTime = inhaleDuration;
  int _currentCycle = 0;
  bool _isRunning = false;
  bool _soundEnabled = true;
  Timer? _timer;
  double _circleScale = 1.0; // For circle animation

  // Audio players
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Getters
  BreathingPhase get currentPhase => _currentPhase;
  int get currentTime => _currentTime;
  int get currentCycle => _currentCycle;
  bool get isRunning => _isRunning;
  bool get soundEnabled => _soundEnabled;
  String get startButtonText => _isRunning
      ? 'Pause'
      : (_currentPhase == BreathingPhase.idle ? 'Start Breathing' : 'Resume');
  double get circleScale => _circleScale;

  // Constructor requires SoundProvider
  BreathingProvider(this._soundProvider);

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose(); // Release audio player resources
    super.dispose();
  }

  // --- Actions ---

  // Toggle Start/Pause/Resume
  void toggleStartPause() {
    if (_isRunning) {
      _pauseBreathing();
    } else {
      _startBreathing();
    }
  }

  // Toggle Sound Enabled/Disabled
  void toggleSoundEnabled() {
    _soundEnabled = !_soundEnabled;
    if (!_soundEnabled) {
      _audioPlayer.stop(); // Stop any playing sound if disabled
    }
    notifyListeners();
  }

  // Reset to initial state
  void reset() {
    _timer?.cancel();
    _isRunning = false;
    _currentPhase = BreathingPhase.idle;
    _currentTime = inhaleDuration;
    _currentCycle = 0;
    _circleScale = 1.0;
    _audioPlayer.stop();
    notifyListeners();
  }

  // --- Internal Logic ---

  // Start or resume breathing
  void _startBreathing() {
    _isRunning = true;
    if (_currentPhase == BreathingPhase.idle) {
      _currentCycle = 0; // Start from cycle 0 if idle
      _currentPhase = BreathingPhase.inhale;
      _currentTime = inhaleDuration;
      _playSound(_soundProvider.currentSoundSet.inhaleSoundPath);
    } else {
      // If resuming, continue playing sound if it was paused
      if (_soundEnabled) _audioPlayer.resume();
    }

    _tick(); // Start the first tick immediately
    _timer?.cancel(); // Ensure previous timer is cancelled
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  // Pause breathing
  void _pauseBreathing() {
    _isRunning = false;
    _timer?.cancel();
    _audioPlayer.pause(); // Pause sound instead of stopping
    notifyListeners();
  }

  // Timer tick logic
  void _tick() {
    if (!_isRunning) return;

    _currentTime--;

    // Update circle scale based on phase
    _updateCircleScale();

    if (_currentTime <= 0) {
      _nextPhase();
    } else {
      notifyListeners(); // Update UI for timer countdown
    }
  }

  // Update circle scale animation
  void _updateCircleScale() {
    final duration = _getPhaseDuration(_currentPhase);
    if (duration == 0) return; // Avoid division by zero

    switch (_currentPhase) {
      case BreathingPhase.inhale:
      // Scale up from 1.0 to 1.3
        _circleScale = 1.0 + (0.3 * (1.0 - _currentTime / duration));
        break;
      case BreathingPhase.exhale:
      // Scale down from 1.3 to 1.0
        _circleScale = 1.3 - (0.3 * (1.0 - _currentTime / duration));
        break;
      case BreathingPhase.hold:
      // For hold, it should stay at max scale
        _circleScale = 1.3;
        break;
      case BreathingPhase.idle:
        _circleScale = 1.0; // Reset scale when idle
        break;
    }
    // Clamp scale just in case
    _circleScale = _circleScale.clamp(1.0, 1.3);
  }

  // Move to the next phase
  void _nextPhase() {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        _currentPhase = BreathingPhase.hold;
        _currentTime = holdDuration;
        _playSound(_soundProvider.currentSoundSet.holdSoundPath);
        break;
      case BreathingPhase.hold:
        _currentPhase = BreathingPhase.exhale;
        _currentTime = exhaleDuration;
        _playSound(_soundProvider.currentSoundSet.exhaleSoundPath);
        break;
      case BreathingPhase.exhale:
        _currentCycle++;
        if (_currentCycle >= totalCycles) {
          _playSound(_soundProvider.currentSoundSet.completeSoundPath);
          reset(); // End of cycles
          // AdService.instance.showInterstitialAd(); // Uncomment for AdMob - Show ad after cycles
          return; // Exit early after reset
        } else {
          _currentPhase = BreathingPhase.inhale;
          _currentTime = inhaleDuration;
          _playSound(_soundProvider.currentSoundSet.inhaleSoundPath);
        }
        break;
      case BreathingPhase.idle:
        reset();
        return;
    }
    _updateCircleScale(); // Update scale immediately for the new phase
    notifyListeners(); // Update UI for phase change
  }

  // Play sound if enabled
  void _playSound(String? soundPath) {
    if (_soundEnabled && soundPath != null && soundPath.isNotEmpty) {
      try {
        _audioPlayer.play(AssetSource(soundPath));
      } catch (e) {
        print("Error playing sound '$soundPath': $e");
        // Optionally notify the user or disable sounds for this set
      }
    }
  }

  // Helper to get duration for a phase
  int _getPhaseDuration(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return inhaleDuration;
      case BreathingPhase.hold:
        return holdDuration;
      case BreathingPhase.exhale:
        return exhaleDuration;
      case BreathingPhase.idle:
        return inhaleDuration; // Default duration when idle
    }
  }
}
