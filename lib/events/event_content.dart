import 'package:flutter/material.dart';
import 'events_model.dart';
import 'events_info.dart';
import 'event_detail_page.dart';

class EventContent extends StatelessWidget {
  final String category;

  const EventContent({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final List<Event> filteredEvents =
        events.where((event) => event.category == category).toList();

    if (filteredEvents.isEmpty) {
      return const Center(
        child: Text('No events found for this category.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: ListView.builder(
        itemCount: filteredEvents.length,
        itemBuilder: (context, index) {
          final event = filteredEvents[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 600),
                    pageBuilder: (_, __, ___) => EventDetailPage(event: event),
                  ),
                );
              },
              child: Hero(
                tag: event.name, // unique hero tag for animation
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Background image
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: Image.asset(
                          event.image,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Gradient overlay (for readability)
                      Container(
                        height: 120,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black87,
                            ],
                          ),
                        ),
                      ),

                      // Event name text
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Text(
                          event.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 6.0,
                                    color: Colors.black45,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
