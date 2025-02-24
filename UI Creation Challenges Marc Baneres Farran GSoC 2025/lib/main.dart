import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:lottie/lottie.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/components/animated_bottom_navigation_bar.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/screens/home_screen.dart';
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
        scaffoldBackgroundColor: const Color(0xFFE0E0E0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111111),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SettingsPage(),
  ];

  late AnimationController _homeController;
  late AnimationController _settingsController;

  @override
  void initState() {
    super.initState();
    _homeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _settingsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _homeController.dispose();
    _settingsController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      if (index == 0) {
        _homeController.reset();
        _homeController.forward();
      } else if (index == 1) {
        _settingsController.reset();
        _settingsController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onDestinationSelected,
        items: [
          NavigationItem(
            icon: Lottie.asset(
              Icons8.home,
              controller: _homeController,
              height: 30,
            ),
            label: 'Home',
          ),
          NavigationItem(
            icon: Lottie.asset(
              Icons8.settings,
              controller: _settingsController,
              height: 30,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
