import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/app_drawer.dart';
import 'helper/helper_functions.dart';

class EventTypePage extends StatefulWidget {
  final String title;

  const EventTypePage({super.key, required this.title});

  @override
  State<EventTypePage> createState() => _EventTypePageState();
}

class _EventTypePageState extends State<EventTypePage> {
  User? currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  void _checkCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userData = await AppBarAuthHelper.loadUserData(currentUser);
      if (mounted) {
        setState(() {});
      }
    }
  }

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
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => AppBarAuthHelper.handleMenuAction(
              value, 
              context, 
              onStateChange: () {
                setState(() {
                  currentUser = null;
                  userData = null;
                });
                _checkCurrentUser();
              }
            ),
            itemBuilder: (context) => AppBarAuthHelper.buildMenuItems(currentUser, userData),
            icon: Icon(
              currentUser != null ? Icons.account_circle : Icons.account_circle_outlined,
            ),
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
    );
  }
}
