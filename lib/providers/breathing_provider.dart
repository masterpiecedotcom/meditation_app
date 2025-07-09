import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart'; // Import the vibration package

import '../constants/app_constants.dart';
import 'sound_provider.dart'; // Import SoundProvider
import '../models/sound_set.dart'; // Import SoundSet model

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
  bool _vibrationEnabled = true; // New state for vibration
  Timer? _timer;
  double _circleScale = 1.0; // For circle animation

  // Audio players
  final AudioPlayer _discreteAudioPlayer = AudioPlayer(); // For phase-specific sounds
  final AudioPlayer _loopAudioPlayer = AudioPlayer();   // For continuous background loops
  bool _isLoopPlaying = false; // Track if the loop player is active

  // Getters
  BreathingPhase get currentPhase => _currentPhase;
  int get currentTime => _currentTime;
  int get currentCycle => _currentCycle;
  bool get isRunning => _isRunning;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled; // Getter for vibration state
  String get startButtonText => _isRunning
      ? 'Pause'
      : (_currentPhase == BreathingPhase.idle ? 'Start Breathing' : 'Resume');
  double get circleScale => _circleScale;

  // Constructor requires SoundProvider and sets up listener
  BreathingProvider(this._soundProvider) {
    // Configure loop player defaults
    _loopAudioPlayer.setReleaseMode(ReleaseMode.loop); // Ensure it loops
    _loopAudioPlayer.setVolume(0.5); // Set a default volume for loops (adjust as needed)

    // Listen for changes in the selected sound set
    _soundProvider.addListener(_handleSoundSetChange);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _discreteAudioPlayer.dispose(); // Release audio player resources
    _loopAudioPlayer.dispose();     // Release loop player resources
    _soundProvider.removeListener(_handleSoundSetChange); // Clean up listener
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
      // Stop both players if sound is disabled
      _discreteAudioPlayer.stop();
      _loopAudioPlayer.pause(); // Pause loop instead of stop, to resume easily
      _isLoopPlaying = false; // Consider loop stopped when sound is off
    } else {
      // If sound enabled, running, and continuous set selected, resume loop
      if (_isRunning && _soundProvider.currentSoundSet.isContinuous) {
        _startOrUpdateLoop(); // This will resume or start the loop
      }
    }
    notifyListeners();
  }

  // Toggle Vibration Enabled/Disabled
  void toggleVibrationEnabled() async {
    _vibrationEnabled = !_vibrationEnabled;
    // Vibrate once on toggle to give feedback
    if (_vibrationEnabled) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 100);
      }
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
    _discreteAudioPlayer.stop();
    _loopAudioPlayer.stop(); // Stop loop completely on reset
    _isLoopPlaying = false;
    notifyListeners();
  }

  // --- Internal Logic ---

  // Handles changes in the selected SoundSet from SoundProvider
  void _handleSoundSetChange() {
    // Stop any currently playing sounds (discrete or loop)
    _discreteAudioPlayer.stop();
    _loopAudioPlayer.stop(); // Stop previous loop if set changes
    _isLoopPlaying = false;

    // If the exercise is currently running, start the new sound type immediately
    if (_isRunning && _soundEnabled) {
      if (_soundProvider.currentSoundSet.isContinuous) {
        _startOrUpdateLoop(); // Start the new loop
      } else {
        // Play the discrete sound for the current phase if applicable
        _playDiscreteSound(_getCurrentPhaseSoundPath());
      }
    }
    // No need to notifyListeners here unless this change affects UI directly
  }

  // Starts or updates the continuous loop based on current state
  void _startOrUpdateLoop() {
    final currentSet = _soundProvider.currentSoundSet;

    // Conditions to play loop: sound enabled, set is continuous, path exists
    if (_soundEnabled && currentSet.isContinuous && currentSet.loopSoundPath != null) {
      _discreteAudioPlayer.stop(); // Ensure discrete sounds are stopped

      // Start playing only if not already playing this loop
      if (!_isLoopPlaying || _loopAudioPlayer.source?.toString() != AssetSource(currentSet.loopSoundPath!).toString()) {
        _loopAudioPlayer.play(AssetSource(currentSet.loopSoundPath!)).then((_) {
          _isLoopPlaying = true; // Mark as playing *after* successful start
          debugPrint("Loop started: ${currentSet.loopSoundPath}");
        }).catchError((error) {
          _isLoopPlaying = false; // Failed to start
          debugPrint("Error starting loop ${currentSet.loopSoundPath}: $error");
        });
      } else if (_loopAudioPlayer.state == PlayerState.paused) {
        // If already playing this loop but paused (e.g. sound toggled off/on)
        _loopAudioPlayer.resume();
        _isLoopPlaying = true;
        debugPrint("Loop resumed: ${currentSet.loopSoundPath}");
      }
    } else {
      // Conditions not met, stop the loop if it's playing
      if (_isLoopPlaying || _loopAudioPlayer.state == PlayerState.playing || _loopAudioPlayer.state == PlayerState.paused) {
        _loopAudioPlayer.stop();
        _isLoopPlaying = false;
        debugPrint("Loop stopped.");
      }
    }
  }

  // Start or resume breathing
  void _startBreathing() {
    _isRunning = true;

    // Set up phase and time regardless of sound type, if starting from idle.
    if (_currentPhase == BreathingPhase.idle) {
      _currentCycle = 0;
      _currentPhase = BreathingPhase.inhale;
      _currentTime = inhaleDuration;
      // Vibrate on start if enabled
      _vibrateIfEnabled();
    }

    // Handle audio based on sound type
    if (_soundProvider.currentSoundSet.isContinuous) {
      _startOrUpdateLoop(); // Start/resume the loop
    } else {
      _loopAudioPlayer.stop(); // Ensure loop is stopped
      _isLoopPlaying = false;
      // If just starting, play the first sound. Otherwise, resume the paused sound.
      if (_currentPhase == BreathingPhase.inhale && _currentTime == inhaleDuration) {
        _playDiscreteSound(_soundProvider.currentSoundSet.inhaleSoundPath);
      } else {
        if (_soundEnabled) _discreteAudioPlayer.resume();
      }
    }

    // Start the timer
    _tick();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  // Pause breathing
  void _pauseBreathing() {
    _isRunning = false;
    _timer?.cancel();
    _discreteAudioPlayer.pause(); // Pause discrete sounds
    _loopAudioPlayer.pause();     // Pause loop sound
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

  // Update circle scale animation (no changes needed here)
  void _updateCircleScale() {
    final duration = _getPhaseDuration(_currentPhase);
    if (duration == 0) return;
    switch (_currentPhase) {
      case BreathingPhase.inhale: _circleScale = 1.0 + (0.3 * (1.0 - _currentTime / duration)); break;
      case BreathingPhase.exhale: _circleScale = 1.3 - (0.3 * (1.0 - _currentTime / duration)); break;
      case BreathingPhase.hold: _circleScale = 1.3; break;
      case BreathingPhase.idle: _circleScale = 1.0; break;
    }
    _circleScale = _circleScale.clamp(1.0, 1.3);
  }

  // Move to the next phase
  void _nextPhase() {
    String? soundToPlay; // Sound path for discrete sounds

    // Vibrate at the transition to the new phase
    _vibrateIfEnabled();

    switch (_currentPhase) {
      case BreathingPhase.inhale:
        _currentPhase = BreathingPhase.hold;
        _currentTime = holdDuration;
        soundToPlay = _soundProvider.currentSoundSet.holdSoundPath;
        break;
      case BreathingPhase.hold:
        _currentPhase = BreathingPhase.exhale;
        _currentTime = exhaleDuration;
        soundToPlay = _soundProvider.currentSoundSet.exhaleSoundPath;
        break;
      case BreathingPhase.exhale:
        _currentCycle++;
        // **CHANGE**: Removed the check for totalCycles to allow for infinite looping.
        // The cycle now always resets to the inhale phase.
        _currentPhase = BreathingPhase.inhale;
        _currentTime = inhaleDuration;
        soundToPlay = _soundProvider.currentSoundSet.inhaleSoundPath;
        break;
      case BreathingPhase.idle:
        reset();
        return;
    }

    _playDiscreteSound(soundToPlay); // Play the discrete sound for the new phase
    _updateCircleScale(); // Update scale immediately for the new phase
    notifyListeners(); // Update UI for phase change
  }

  // Play sound using the discrete player IF conditions met
  void _playDiscreteSound(String? soundPath) {
    // Only play if sound enabled, set is NOT continuous, and path is valid
    if (_soundEnabled && !_soundProvider.currentSoundSet.isContinuous && soundPath != null && soundPath.isNotEmpty) {
      try {
        _discreteAudioPlayer.play(AssetSource(soundPath));
      } catch (e) {
        debugPrint("Error playing discrete sound '$soundPath': $e");
      }
    }
  }

  // Helper to vibrate if the feature is enabled
  void _vibrateIfEnabled() async {
    if (_vibrationEnabled) {
      if (await Vibration.hasVibrator()) {
        // A short, distinct vibration for phase changes
        Vibration.vibrate(duration: 150, amplitude: 128);
      }
    }
  }

  // Helper to get the sound path for the current phase (for discrete sounds)
  String? _getCurrentPhaseSoundPath() {
    if (_soundProvider.currentSoundSet.isContinuous) return null;
    switch(_currentPhase) {
      case BreathingPhase.inhale: return _soundProvider.currentSoundSet.inhaleSoundPath;
      case BreathingPhase.hold: return _soundProvider.currentSoundSet.holdSoundPath;
      case BreathingPhase.exhale: return _soundProvider.currentSoundSet.exhaleSoundPath;
      case BreathingPhase.idle: return null; // Or maybe inhale sound?
    }
  }


  // Helper to get duration for a phase (no changes needed)
  int _getPhaseDuration(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale: return inhaleDuration;
      case BreathingPhase.hold: return holdDuration;
      case BreathingPhase.exhale: return exhaleDuration;
      case BreathingPhase.idle: return inhaleDuration;
    }
  }
}
