import 'package:flutter/material.dart';
import 'package:instruo_application/theme/theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/events_bottom_nav.dart';

class WorkshopsPage extends StatelessWidget {
  final List<Map<String, String>> workshopEvents = [
    {"name": "Flutter Workshop", "image": "assets/fest.png"},
    {"name": "Dart Workshop", "image": "assets/fest.png"},
    {"name": "Firebase Workshop", "image": "assets/fest.png"},
  ];

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
      body: Column(
        children: [
          SizedBox(height: 20),
          Expanded(
            child: PageView.builder(
              itemCount: workshopEvents.length,
              controller: PageController(viewportFraction: 0.85),
              itemBuilder: (context, index) {
                final event = workshopEvents[index];
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
                            borderRadius: BorderRadius.vertical(
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
      ),
      // bottomNavigationBar: const EventsBottomNav(currentIndex: 1),
    );
  }
}