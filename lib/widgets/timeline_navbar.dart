import 'package:flutter/material.dart';


class TimelineBottomNav extends StatelessWidget {
  final int currentIndex; // 0: Day 1, 1: Day 2, 2: Day 3

  const TimelineBottomNav({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return; // no-op if already on the tab

    String routeName;
    switch (index) {
      case 0:
        routeName = '/timeline/day1';
        break;
      case 1:
        routeName = '/timeline/day2';
        break;
      case 2:
      default:
        routeName = '/timeline/day3';
        break;
    }

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
          icon: Icon(Icons.calendar_today),
          label: 'Day 1',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_view_day),
          label: 'Day 2',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Day 3',
        ),
      ],
    );
  }
}
