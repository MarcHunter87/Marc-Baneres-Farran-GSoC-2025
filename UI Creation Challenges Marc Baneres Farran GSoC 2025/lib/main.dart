import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:lottie/lottie.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
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

class NavigationItem {
  final Widget icon;
  final String label;
  NavigationItem({required this.icon, required this.label});
}

class AnimatedBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final List<NavigationItem> items;

  const AnimatedBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final double indicatorWidth = width / items.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: indicatorWidth * selectedIndex,
                bottom: 0,
                child: Container(
                  width: indicatorWidth,
                  height: 4,
                  color: Colors.white,
                ),
              ),
              Row(
                children: items.asMap().entries.map((entry) {
                  int idx = entry.key;
                  NavigationItem item = entry.value;
                  return Expanded(
                    child: InkWell(
                      onTap: () => onTap(idx),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                              child: item.icon,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
