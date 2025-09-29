import 'package:flutter/material.dart';

import '../events/technical_page.dart';
import '../events/general_page.dart';
import '../events/robotics_page.dart';
import '../events/gaming_page.dart';

/// Bottom navigation used across event pages: Technical, General, Robotics, Gaming
class EventsBottomNav extends StatelessWidget {
  final int currentIndex; // 0: Technical, 1: General, 2: Robotics, 3: Gaming

  const EventsBottomNav({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return; // no-op if already on the tab

    Widget target;
    switch (index) {
      case 0:
        target = TechnicalPage();
        break;
      case 1:
        target = GeneralPage();
        break;
      case 2:
        target = RoboticsPage();
        break;
      case 3:
      default:
        target = GamingPage();
        break;
    }

    // Replace to avoid stacking multiple pages while switching tabs
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (i) => _navigate(context, i),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.engineering),
          label: 'Technical',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'General',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.precision_manufacturing),
          label: 'Robotics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_esports),
          label: 'Gaming',
        ),
      ],
    );
  }
}
