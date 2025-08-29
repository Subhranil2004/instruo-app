import 'package:flutter/material.dart';
import 'widgets/app_drawer.dart';

class EventTypePage extends StatelessWidget {
  final String title;

  EventTypePage({required this.title});

  // Dummy event data for now (replace with Firestore later)
  final List<Map<String, String>> sampleEvents = [
    {"name": "Event 1", "image": "assets/fest.png"},
    {"name": "Event 2", "image": "assets/fest.png"},
    {"name": "Event 3", "image": "assets/fest.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
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
              PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: PageView.builder(
              itemCount: sampleEvents.length,
              controller: PageController(viewportFraction: 0.85),
              itemBuilder: (context, index) {
                final event = sampleEvents[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
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
}
