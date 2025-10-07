import 'package:flutter/material.dart';
import 'package:instruo_application/widgets/app_drawer.dart';
import 'package:instruo_application/widgets/custom_app_bar.dart';

import '../../theme/theme.dart';
import '../../widgets/timeline_navbar.dart';
import 'timeline_data.dart';

/// TimelinePage shows events for a specific day (0..2).
/// Routes expected (optional): /timeline/day1, /timeline/day2, /timeline/day3
class TimelinePage extends StatelessWidget {
  final int dayIndex; // 0 = Day 1, 1 = Day 2, 2 = Day 3

  const TimelinePage({super.key, this.dayIndex = 0});

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

  @override
  Widget build(BuildContext context) {
    final events = timelineData[dayIndex] ?? [];

    return Scaffold(
       appBar:  CustomAppBar(
        title: "TIMELINE",
        showBackButton: false,
        // onBackPressed: () {
        //   Navigator.pushReplacementNamed(context, '/home'); // Navigate to the home route
        // },
        showProfileButton: false,
      ),
      drawer: AppDrawer(),
      bottomNavigationBar: TimelineBottomNav(currentIndex: dayIndex),
      body: SafeArea(
        child: Padding(
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
                              'No events scheduled for ${_dayTitle(dayIndex)}.',
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
        ),
      ),
    );
  }
}
