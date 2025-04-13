import '../models/sound_set.dart';

// Defines the predefined sound sets available in the app
// IMPORTANT: Ensure the asset paths match your actual file locations!
class SoundSets {

  // --- Sound Set Definitions ---

  static const SoundSet defaultTones = SoundSet(
    name: 'Default Tones', // Display name
    // Assumes sounds are directly in assets/audio/
    inhaleSoundPath: 'audio/inhale_tone.mp3',     // Replace with your file
    holdSoundPath: 'audio/hold_tone.mp3',         // Replace with your file
    exhaleSoundPath: 'audio/exhale_tone.mp3',     // Replace with your file
    completeSoundPath: 'audio/complete_tone.mp3', // Replace with your file
  );

  static const SoundSet natureSounds = SoundSet(
    name: 'Nature Sounds',
    // Assumes sounds are in assets/audio/nature/
    // Make sure this subfolder exists and contains these files if using this set
    inhaleSoundPath: 'audio/nature/inhale_wind.mp3',      // Example path
    holdSoundPath: 'audio/nature/hold_stream.mp3',     // Example path
    exhaleSoundPath: 'audio/nature/exhale_leaves.mp3',   // Example path
    completeSoundPath: 'audio/nature/complete_birds.mp3', // Example path
  );

  static const SoundSet calmBells = SoundSet(
    name: 'Calm Bells',
    // Assumes sounds are in assets/audio/bells/
    // Make sure this subfolder exists and contains these files if using this set
    inhaleSoundPath: 'audio/bells/inhale_bell_low.mp3',   // Example path
    holdSoundPath: 'audio/bells/hold_bell_mid.mp3',      // Example path
    exhaleSoundPath: 'audio/bells/exhale_bell_high.mp3',  // Example path
    completeSoundPath: 'audio/bells/complete_chime.mp3',  // Example path
  );

  // A sound set representing silence (no audio files)
  static const SoundSet silent = SoundSet(
    name: 'Silent',
    // No paths provided - the provider will handle null paths correctly
  );

  // --- List of Available Sound Sets ---
  static List<SoundSet> availableSoundSets = [
    defaultTones,
    natureSounds, // Add only if you have created the assets/audio/nature/ folder and files
    calmBells,    // Add only if you have created the assets/audio/bells/ folder and files
    silent,
    // Add more sound sets here as needed
  ];
}
