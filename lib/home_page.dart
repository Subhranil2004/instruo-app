import 'package:flutter/material.dart';
import 'event_type_page.dart';
import 'widgets/app_drawer.dart';

import 'events/technical_page.dart';
import 'events/robotics_page.dart';
import 'events/gaming_page.dart';
import 'events/general_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;

  final List<Map<String, String>> eventTypes = [
    {"title": "Technical", "image": "assets/tech.png"},
    {"title": "Robotics", "image": "assets/robotics.png"},
    {"title": "Gaming", "image": "assets/gaming.png"},
    {"title": "General", "image": "assets/general.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("INSTRUO'14"),
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
              PopupMenuItem(value: 'profile', child: Text('Profile')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          SizedBox(height: 20),
          Column(
            children: [
              Image.asset("assets/fest_logo.png", height: 100),
              SizedBox(height: 10),
              Text(
                "INSTRUO 2025",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: eventTypes.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final event = eventTypes[index];
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                    }
                    return Center(
                      child: SizedBox(
                        height: Curves.easeOut.transform(value) * 300,
                        child: child,
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      Widget nextPage;
                      switch (event["title"]) {
                        case "Technical":
                          nextPage = TechnicalPage();
                          break;
                        case "Robotics":
                          nextPage = RoboticsPage();
                          break;
                        case "Gaming":
                          nextPage = GamingPage();
                          break;
                        case "General":
                          nextPage = GeneralPage();
                          break;
                        default:
                          nextPage = EventTypePage(title: event["title"]!);
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => nextPage),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
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
                              event["title"]!,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }
}
