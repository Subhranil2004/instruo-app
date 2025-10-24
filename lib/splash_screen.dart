import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instruo_application/theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    Future.delayed(const Duration(milliseconds: 5550), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(colors: [AppTheme.primaryBlue, AppTheme.secondaryPurple], begin: Alignment.topLeft, end: Alignment.bottomRight),
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: Image.asset(
            'assets/instruo-app-splashscreen.gif',
            // width: 200,
            // height: 200,
          ),
        ),
      ),
    );
  }
}