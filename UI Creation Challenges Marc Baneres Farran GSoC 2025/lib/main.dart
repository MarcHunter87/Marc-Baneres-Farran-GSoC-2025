import 'package:flutter/material.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/screens/home_screen.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/screens/voice_screen.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/screens/maps_screen.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LG Web App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF101418),
          onSurface: Color(0xFFE0E2E8),
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    VoiceScreen(),
    MapsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.mic),
            label: 'Voice',
          ),
          NavigationDestination(
            icon: Icon(Icons.map),
            label: 'Maps',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
