import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import '../models/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  AppTheme _currentTheme = AppThemes.defaultGradient; // Initial theme

  AppTheme get currentTheme => _currentTheme;
  List<AppTheme> get availableThemes => AppThemes.availableThemes;

  void setTheme(AppTheme theme) {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      notifyListeners();
    }
  }
}
