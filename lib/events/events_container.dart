import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_app_bar.dart';
import 'event_content.dart';

/// Container widget that holds all event pages with smooth transitions
/// and a constant "EVENTS" app bar. Uses PageView for swipe support.
class EventsContainer extends StatefulWidget {
  final int initialIndex;

  const EventsContainer({super.key, this.initialIndex = 0});

  @override
  State<EventsContainer> createState() => _EventsContainerState();
}

class _EventsContainerState extends State<EventsContainer> {
  late int _currentIndex;
  late PageController _pageController;

  // Define the list of event categories
  final List<String> _eventCategories = [
    'technical',
    'general',
    'robotics',
    'gaming',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Called when bottom nav is tapped
  void _onTabChanged(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "EVENTS",
        showBackButton: false,
      ),
      drawer: AppDrawer(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _eventCategories
            .map((category) => EventContent(category: category))
            .toList(),
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
