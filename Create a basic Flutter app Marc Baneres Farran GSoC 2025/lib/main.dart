import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:create_a_basic_flutter_app_marc_baneres_farran_gsoc_2025/screens/home_screen.dart';
import 'package:create_a_basic_flutter_app_marc_baneres_farran_gsoc_2025/screens/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsPage(),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE0E0E0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111111),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
    );
  }
}
