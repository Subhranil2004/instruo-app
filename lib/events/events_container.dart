import 'package:flutter/material.dart';
import 'package:instruo_application/theme/theme.dart';
import '../widgets/app_drawer.dart';
import 'technical_content.dart';
import 'general_content.dart';
import 'robotics_content.dart';
import 'gaming_content.dart';

/// Container widget that holds all event pages with smooth bottom nav transitions
/// and a constant "EVENTS" app bar. Uses IndexedStack to keep all pages in memory.
class EventsContainer extends StatefulWidget {
  final int initialIndex;

  const EventsContainer({super.key, this.initialIndex = 0});

  @override
  State<EventsContainer> createState() => _EventsContainerState();
}

class _EventsContainerState extends State<EventsContainer> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EVENTS"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                // TODO: Navigate to profile page
              } else if (value == 'logout') {
                // TODO: Handle logout
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            icon: const Icon(Icons.account_circle),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          TechnicalContent(),
          GeneralContent(),
          RoboticsContent(),
          GamingContent(),
        ],
      ),
      bottomNavigationBar: EventsBottomNavLocal(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}

/// Local bottom nav that handles tab switching within EventsContainer
class EventsBottomNavLocal extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const EventsBottomNavLocal({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
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