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
      duration: const Duration(milliseconds: 200), // Adjust this value for speed
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
          const SizedBox(height: 8),
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No events scheduled for ${_dayTitle(dayIdx)}.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final e = events[i];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 72,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.time,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 6,
                                      width: 6,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.title,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.place,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            e.venue,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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