// Defines the paths and playback type for a set of sounds
class SoundSet {
  final String name; // Unique name for identification and display
  final bool isContinuous; // True if this set uses a continuous loop
  final String? loopSoundPath; // Path for the continuous loop audio (if isContinuous is true)
  final String? inhaleSoundPath; // Path for discrete inhale sound (if isContinuous is false)
  final String? holdSoundPath;   // Path for discrete hold sound (if isContinuous is false)
  final String? exhaleSoundPath; // Path for discrete exhale sound (if isContinuous is false)
  final String? completeSoundPath; // Path for discrete completion sound (if isContinuous is false)

  const SoundSet({
    required this.name,
    this.isContinuous = false, // Default to discrete sounds
    this.loopSoundPath,
    this.inhaleSoundPath,
    this.holdSoundPath,
    this.exhaleSoundPath,
    this.completeSoundPath,
  });

  // --- Equality Override ---
  // Needed for comparing sound sets (e.g., in SelectorDialog)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SoundSet &&
              runtimeType == other.runtimeType &&
              name == other.name; // Compare based on unique name

  @override
  int get hashCode => name.hashCode; // Hash based on unique name
}
