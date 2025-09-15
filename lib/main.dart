import 'package:flutter/material.dart';
import 'screens/login_page.dart'; // Import your login page
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'College Fest',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(), // Start with login page
      routes: {
        '/home': (context) => HomePage(), // For navigation after login/skip
        '/login': (context) => LoginPage(), // Optional: if you need back to login
      },
    );
  }
}
