import '../models/sound_set.dart';

// Defines the predefined sound sets available in the app
// IMPORTANT: Ensure the asset paths match your actual file locations!
class SoundSets {

  // --- Sound Set Definitions ---

  static const SoundSet defaultTones = SoundSet(
    name: 'Default Tones', // Display name
    isContinuous: false, // Discrete sounds for each phase
    // Provide paths for discrete sounds:
    inhaleSoundPath: 'audio/inhale.mp3',     // Replace with your file
    holdSoundPath: 'audio/hold.mp3',         // Replace with your file
    exhaleSoundPath: 'audio/exhale.mp3',     // Replace with your file
    completeSoundPath: 'audio/complete_tone.mp3', // Replace with your file
    // loopSoundPath is not needed here
  );

  static const SoundSet natureSounds = SoundSet(
    name: 'Jungle Rain',
    isContinuous: true, // This set plays a continuous loop
    // Provide path for the loop sound:
    loopSoundPath: 'audio/jungle-rain.wav', // Replace with your actual looping nature sound file
    // Discrete paths are not needed here
  );

  static const SoundSet calmBells = SoundSet(
    name: 'Night Ambience', // Updated name slightly
    isContinuous: true, // This set plays a continuous loop
    // Provide path for the loop sound:
    loopSoundPath: 'audio/night-ambience.mp3', // Replace with your actual looping bells sound file
    // Discrete paths are not needed here
  );

  static const SoundSet thunderstorm = SoundSet(
    name: 'Calm Thunderstorm', // Updated name slightly
    isContinuous: true, // This set plays a continuous loop
    // Provide path for the loop sound:
    loopSoundPath: 'audio/calm-thunderstorm.wav', // Replace with your actual looping bells sound file
    // Discrete paths are not needed here
  );

  static const SoundSet river = SoundSet(
    name: 'Calm River', // Updated name slightly
    isContinuous: true, // This set plays a continuous loop
    // Provide path for the loop sound:
    loopSoundPath: 'audio/calm-river.mp3', // Replace with your actual looping bells sound file
    // Discrete paths are not needed here
  );

  static const SoundSet birds = SoundSet(
    name: 'Birds', // Updated name slightly
    isContinuous: true, // This set plays a continuous loop
    // Provide path for the loop sound:
    loopSoundPath: 'audio/birds-singing-in-the-forest.mp3', // Replace with your actual looping bells sound file
    // Discrete paths are not needed here
  );

  // A sound set representing silence (no audio files)
  static const SoundSet silent = SoundSet(
    name: 'Silent',
    isContinuous: false, // Treated as discrete, but has no paths
    // No paths needed
  );

  // --- List of Available Sound Sets ---
  static List<SoundSet> availableSoundSets = [
    defaultTones,
    natureSounds, // Add only if you have created the assets/audio/nature/ folder and looping file
    calmBells,
    thunderstorm,
    river,
    birds,// Add only if you have created the assets/audio/bells/ folder and looping file
    silent,
    // Add more sound sets here as needed
  ];
}
