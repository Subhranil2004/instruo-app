import 'package:flutter/material.dart';
import 'package:instruo_application/theme/theme_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        final isDark = ThemeController.instance.isDark;
        return IconButton(
          tooltip: isDark ? 'Switch to light theme' : 'Switch to dark theme',
          icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode, size: 26,),
          onPressed: () => ThemeController.instance.toggle(),
        );
      },
    );
  }
}
