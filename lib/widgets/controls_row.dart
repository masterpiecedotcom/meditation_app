import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Keep for icons

import '../providers/breathing_provider.dart';
import '../providers/sound_provider.dart';
import '../providers/theme_provider.dart';
import '../models/app_theme.dart';
import '../models/sound_set.dart';
import 'selector_dialog.dart'; // Import the dialog

class ControlsRow extends StatelessWidget {
  final Color textColor; // Pass text color for consistency

  const ControlsRow({super.key, required this.textColor});

  // Function to show the theme selection dialog
  void _showThemeDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return SelectorDialog<AppTheme>(
          title: 'Select Theme',
          items: themeProvider.availableThemes,
          currentItem: themeProvider.currentTheme,
          itemBuilder: (item) => Text(item.name), // Display theme name
          onItemSelected: (selectedTheme) {
            themeProvider.setTheme(selectedTheme);
            Navigator.of(dialogContext).pop(); // Close dialog
          },
        );
      },
    );
  }

  // Function to show the sound selection dialog
  void _showSoundDialog(BuildContext context) {
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return SelectorDialog<SoundSet>(
          title: 'Select Sound Set',
          items: soundProvider.availableSoundSets,
          currentItem: soundProvider.currentSoundSet,
          itemBuilder: (item) => Text(item.name), // Display sound set name
          onItemSelected: (selectedSoundSet) {
            soundProvider.setSoundSet(selectedSoundSet);
            Navigator.of(dialogContext).pop(); // Close dialog
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // Use watch only if the widget needs to rebuild when provider state changes
    final breathingProvider = context.watch<BreathingProvider>();

    // Use theme colors for icons if desired, or keep fixed colors
    final iconColorActive = Colors.greenAccent[400] ?? Colors.green;
    final iconColorMuted = Colors.redAccent[100] ?? Colors.red;
    final controlIconColor = textColor.withOpacity(0.8); // Color for theme/sound icons

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0), // No horizontal padding needed if using spaceEvenly
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space out buttons evenly
        crossAxisAlignment: CrossAxisAlignment.start, // Align tops of columns
        children: [
          // Sound On/Off Toggle
          _buildControlButton(
            context: context,
            icon: breathingProvider.soundEnabled
                ? FontAwesomeIcons.volumeUp
                : FontAwesomeIcons.volumeMute,
            color: breathingProvider.soundEnabled ? iconColorActive : iconColorMuted,
            label: 'Sound',
            tooltip: breathingProvider.soundEnabled ? 'Mute Sound' : 'Unmute Sound',
            onPressed: breathingProvider.toggleSoundEnabled,
            textColor: textColor,
          ),

          // Theme Selector Button
          _buildControlButton(
            context: context,
            icon: Icons.palette_outlined, // Palette icon for theme
            color: controlIconColor,
            label: 'Theme',
            tooltip: 'Change Theme',
            onPressed: () => _showThemeDialog(context),
            textColor: textColor,
          ),

          // Sound Set Selector Button
          _buildControlButton(
            context: context,
            icon: Icons.music_note_outlined, // Music note icon for sound set
            color: controlIconColor,
            label: 'Sounds',
            tooltip: 'Change Sounds',
            onPressed: () => _showSoundDialog(context),
            textColor: textColor,
          ),


          // Cycle Count Display (using the same button style for consistency)
          _buildDisplayColumn(
            context: context,
            label: 'Cycle',
            value: breathingProvider.currentCycle.toString(),
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  // Helper to build consistent control buttons (using IconButton for semantics)
  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required String tooltip,
    required VoidCallback onPressed,
    required Color textColor,
  }) {
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(color: textColor.withOpacity(0.8));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: FaIcon(icon), // Use FaIcon for FontAwesome
          color: color,
          iconSize: 24,
          tooltip: tooltip,
          onPressed: onPressed,
          padding: const EdgeInsets.all(12.0), // Adjust padding as needed
          constraints: const BoxConstraints(), // Remove default constraints if needed
        ),
        // const SizedBox(height: 0), // Reduce space
        Text(label, style: labelStyle),
      ],
    );
  }

  // Helper to build the cycle count display column
  Widget _buildDisplayColumn({
    required BuildContext context,
    required String label,
    required String value,
    required Color textColor,
  }) {
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(color: textColor.withOpacity(0.8));
    final valueStyle = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: textColor);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Add some padding to align baseline with IconButton visual center
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 12.0), // Match IconButton padding roughly
          child: Text(value, style: valueStyle),
        ),
        // const SizedBox(height: 0),
        Text(label, style: labelStyle),
      ],
    );
  }
}
