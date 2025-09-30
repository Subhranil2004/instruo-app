import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_app_bar.dart';

class WorkshopsPage extends StatefulWidget {
  const WorkshopsPage({super.key});

  @override
  State<WorkshopsPage> createState() => _WorkshopsPageState();
}

class _WorkshopsPageState extends State<WorkshopsPage> {
  final List<Map<String, String>> workshopEvents = [
    {"name": "Flutter Workshop", "image": "assets/fest.png"},
    {"name": "Dart Workshop", "image": "assets/fest.png"},
    {"name": "Firebase Workshop", "image": "assets/fest.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "WORKSHOPS",
        showBackButton: false,
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