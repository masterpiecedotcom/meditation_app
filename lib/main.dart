import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/breathing_provider.dart';
import 'providers/sound_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/breathing_screen.dart';
// import 'services/ad_service.dart'; // Uncomment for AdMob

void main() {
  // WidgetsFlutterBinding.ensureInitialized(); // Uncomment for AdMob
  // AdService.instance.initialize(); // Uncomment for AdMob

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SoundProvider()),
        // BreathingProvider depends on SoundProvider, so provide SoundProvider first
        // Use ChangeNotifierProxyProvider if BreathingProvider needs to react to SoundProvider changes
        ChangeNotifierProxyProvider<SoundProvider, BreathingProvider>(
            create: (context) => BreathingProvider(context.read<SoundProvider>()),
            update: (context, soundProvider, previousBreathingProvider) {
              // Optionally, you could preserve state if needed, but usually recreating is fine
              // if the dependency changes fundamentally.
              // For this case, simply providing the latest soundProvider might be enough.
              // If BreathingProvider held state dependent on the *specific* SoundProvider instance,
              // more complex update logic would be needed.
              return previousBreathingProvider ?? BreathingProvider(soundProvider);
              // Or simply: return BreathingProvider(soundProvider); if recreating is always okay.
            }
        ),
      ],
      child: const BreathingApp(),
    ),
  );
}

class BreathingApp extends StatelessWidget {
  const BreathingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use GoogleFonts and apply base text color based on theme brightness
    final textTheme = Theme.of(context).textTheme;
    final poppinsTextTheme = GoogleFonts.poppinsTextTheme(textTheme);

    // Listen to theme brightness to set default text color
    // Use watch here to rebuild MaterialApp if brightness changes
    final brightness = context.watch<ThemeProvider>().currentTheme.brightness;
    final defaultTextColor = brightness == Brightness.dark ? Colors.white : Colors.black;

    return MaterialApp(
      title: '4-7-8 Breathing App',
      theme: ThemeData(
        // Use theme colors for a more integrated look
        colorScheme: ColorScheme.fromSeed(
          seedColor: context.watch<ThemeProvider>().currentTheme.primarySeedColor, // Use a seed color from theme
          brightness: brightness,
        ),
        textTheme: poppinsTextTheme.apply(
          bodyColor: defaultTextColor,
          displayColor: defaultTextColor,
        ),
        brightness: brightness, // Set brightness from theme provider
      ),
      home: const BreathingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
