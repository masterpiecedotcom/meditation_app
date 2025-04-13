// Defines the paths for a set of sounds used during the breathing exercise
class SoundSet {
  final String name; // Unique name for identification and display
  final String? inhaleSoundPath; // Path relative to assets folder
  final String? holdSoundPath;   // Path relative to assets folder
  final String? exhaleSoundPath; // Path relative to assets folder
  final String? completeSoundPath; // Path relative to assets folder

  const SoundSet({
    required this.name,
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
