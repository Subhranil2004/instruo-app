import 'package:flutter/material.dart';

class GamingContent extends StatelessWidget {
  final List<Map<String, String>> gamingEvents = [
    {"name": "BGMI Tournament", "image": "assets/fest.png"},
    {"name": "FIFA Challenge", "image": "assets/fest.png"},
    {"name": "Valorant Cup", "image": "assets/fest.png"},
  ];

  GamingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: PageView.builder(
            itemCount: gamingEvents.length,
            controller: PageController(viewportFraction: 0.85),
            itemBuilder: (context, index) {
              final event = gamingEvents[index];
              return Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 30.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Image.asset(
                            event["image"]!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          event["name"]!,
                          style: Theme.of(context).textTheme.titleLarge,
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
    );
  }
}
