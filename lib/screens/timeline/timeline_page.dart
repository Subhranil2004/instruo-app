import 'package:flutter/material.dart';
import 'package:instruo_application/widgets/app_drawer.dart';
import 'package:instruo_application/widgets/custom_app_bar.dart';

import '../../theme/theme.dart';
import '../../widgets/timeline_navbar.dart';
import 'timeline_data.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  int _dayIndex = 0; // State to track the selected day
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _dayIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDayChanged(int index) {
    setState(() {
      _dayIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 50), // Adjust this value for speed
      curve: Curves.fastOutSlowIn,
    );
  }

  String _dayTitle(int idx) {
    switch (idx) {
      case 1:
        return 'Day 2';
      case 2:
        return 'Day 3';
      case 0:
      default:
        return 'Day 1';
    }
  }

  Widget _buildDayContent(int dayIdx) {
  final events = timelineData[dayIdx] ?? [];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Events',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.9),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No events scheduled for ${_dayTitle(dayIdx)}.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final e = events[index];
                    return _buildEventTile(e, index + 1);
                  },
                ),
        ),
      ],
    ),
  );
}

Widget _buildEventTile(dynamic e, int eventNumber) {
  // Use dynamic type if your timelineData entries are not typed
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 4,
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
            child: Text(
              eventNumber.toString(),
              style: const TextStyle(
                  color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildInfoChip(Icons.access_time, e.time,
                        AppTheme.primaryBlue),
                    _buildInfoChip(Icons.place, e.venue, AppTheme.secondaryPurple),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildInfoChip(IconData icon, String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Flexible( // ✅ allows text to wrap instead of overflowing
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            softWrap: true,
          ),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "TIMELINE",
        showBackButton: false,
        showProfileButton: false,
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: TimelineBottomNav(
        currentIndex: _dayIndex,
        onTap: _onDayChanged,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onDayChanged,
        itemCount: timelineData.length,
        itemBuilder: (context, index) {
          return _buildDayContent(index);
        },
      ),
    );
  }
}