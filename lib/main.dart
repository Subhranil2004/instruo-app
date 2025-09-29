import 'package:flutter/material.dart';
import 'screens/login_page.dart'; // Import your login page
import 'home_page.dart';
import 'theme/theme.dart';
import 'events/technical_page.dart';
import 'events/general_page.dart';
import 'events/robotics_page.dart';
import 'events/gaming_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'College Fest',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: LoginPage(), // Start with login page
      routes: {
        '/home': (context) => HomePage(), // For navigation after login/skip
        '/login': (context) => LoginPage(), // Optional: if you need back to login
        // Event pages (used by bottom navigation)
        '/events/technical': (context) => TechnicalPage(),
        '/events/general': (context) => GeneralPage(),
        '/events/robotics': (context) => RoboticsPage(),
        '/events/gaming': (context) => GamingPage(),
      },
    );
  }
}
