import 'package:flutter/material.dart';
import "../constants/sound_constants.dart";
import "../models/sound_set.dart";

class SoundProvider with ChangeNotifier {
  SoundSet _currentSoundSet = SoundSets.defaultTones; // Initial sound set

  SoundSet get currentSoundSet => _currentSoundSet;
  List<SoundSet> get availableSoundSets => SoundSets.availableSoundSets;

  void setSoundSet(SoundSet soundSet) {
    if (_currentSoundSet != soundSet) {
      _currentSoundSet = soundSet;
      notifyListeners();
    }
  }
}
