import 'package:flutter/material.dart';
import 'events_model.dart';
import 'events_info.dart';
import 'event_detail_page.dart'; // new page

class TechnicalContent extends StatelessWidget {
  final List<Event> technicalEvents =
      events.where((event) => event.category == "technical").toList();

  TechnicalContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: technicalEvents.length,
        controller: PageController(viewportFraction: 0.70),
        itemBuilder: (context, index) {
          final event = technicalEvents[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventDetailPage(event: event),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 6,
                clipBehavior: Clip.hardEdge,
                child: Column(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Image.asset(
                        event.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          event.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
