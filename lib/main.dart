import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:instruo_application/home_page.dart';
import 'package:instruo_application/firebase_options.dart';
import 'package:instruo_application/screens/timeline/timeline_page.dart';
import 'package:instruo_application/splash_screen.dart';
import 'theme/theme.dart';
import 'theme/theme_controller.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

/// A small controller that holds the active [ThemeMode].
///
/// It's intentionally simple and uses [ChangeNotifier] so the app can
/// rebuild when the mode changes without adding extra packages.
// ThemeController and ThemeToggleButton moved to separate files to avoid
// circular imports and keep code modular.

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Rebuild the MaterialApp whenever the ThemeController notifies.
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'INSTRUO',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          // Use our controller's mode. We intentionally do NOT use
          // ThemeMode.system here (per request).
          themeMode: ThemeController.instance.mode,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          home: SplashScreen(), // Start with Home page
          routes: {
            '/home': (context) => HomePage(), // Add this
            '/timeline': (context) => const TimelinePage(),
          },
        );
      },
    );
  }
}
