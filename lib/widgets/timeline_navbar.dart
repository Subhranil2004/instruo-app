import 'package:flutter/material.dart';

class TimelineBottomNav extends StatelessWidget {
  final int currentIndex; // 0: Day 1, 1: Day 2, 2: Day 3
  // Change the onTap parameter's type to `void Function(int)`
  final void Function(int) onTap;

  const TimelineBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: onTap, // Directly pass the onTap function
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