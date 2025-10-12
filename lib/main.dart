import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:instruo_application/home_page.dart';
import 'package:instruo_application/firebase_options.dart';
import 'package:instruo_application/screens/timeline/timeline_page.dart';
import 'theme/theme.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      home: HomePage(), // Start with Home page
      routes: {
        '/home': (context) => HomePage(), // Add this
        '/timeline': (context) => const TimelinePage(),
      },

    );
  }
}
