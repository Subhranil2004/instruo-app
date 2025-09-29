import 'package:flutter/material.dart';

/// Bottom navigation used across event pages: Technical, General, Robotics, Gaming
///
/// Usage:
///   Scaffold(
///     // ...
///     bottomNavigationBar: EventsBottomNav(currentIndex: 0),
///   );
/// Set `currentIndex` to the active tab: 0=Technical, 1=General, 2=Robotics, 3=Gaming.
class EventsBottomNav extends StatelessWidget {
  final int currentIndex; // 0: Technical, 1: General, 2: Robotics, 3: Gaming

  const EventsBottomNav({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return; // no-op if already on the tab

    String routeName;
    switch (index) {
      case 0:
        routeName = '/events/technical';
        break;
      case 1:
        routeName = '/events/general';
        break;
      case 2:
        routeName = '/events/robotics';
        break;
      case 3:
      default:
        routeName = '/events/gaming';
        break;
    }

    // Replace to avoid stacking multiple pages while switching tabs
    Navigator.of(context).pushReplacementNamed(routeName);
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
