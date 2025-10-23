import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instruo_application/widgets/custom_app_bar.dart';
import 'widgets/app_drawer.dart';
import 'events/events_container.dart';
import 'theme/theme.dart';
import 'helper/helper_functions.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      if (mounted) setState(() {});
    }
  }

  final List<Map<String, String>> eventTypes = [
    {"title": "Technical", "image": "assets/events/tech.png"},
    {"title": "Robotics", "image": "assets/events/robotics.png"},
    {"title": "Gaming", "image": "assets/events/gaming.png"},
    {"title": "General", "image": "assets/events/general.png"},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: "HOME",
        showBackButton: false,
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          // 🟩 Fixed Header Section (like WhatsApp stories top bar)
          const SizedBox(height: 30),
          Column(
            children: [
              Image.asset("assets/fest_logo.png", height: 90),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: Text(
                  "INSTRUO 2025",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black26,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 100),

          // 🟦 Free-flowing horizontal scroll section
          SizedBox(
            height: 300,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double cardWidth = constraints.maxWidth * 0.9;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: eventTypes.length,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) {
                    final event = eventTypes[index];

                    return AnimatedBuilder(
                      animation: Scrollable.of(context)!.position,
                      builder: (context, child) {
                        // Get scroll offset and calculate dynamic scaling
                        final scrollOffset =
                            Scrollable.of(context)!.position.pixels;
                        final itemOffset = index * (cardWidth + 16);
                        final diff = (scrollOffset - itemOffset) / cardWidth;
                        final scale = (1 - diff.abs() * 0.15).clamp(0.9, 1.0);

                        return Transform.scale(
                          scale: scale,
                          alignment: Alignment.center,
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          int initialIndex = eventTypes.indexOf(event);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventsContainer(initialIndex: initialIndex),
                            ),
                          );
                        },
                        child: Container(
                          width: cardWidth,
                          margin: const EdgeInsets.only(right: 16),
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Event Image
                                Image.asset(
                                  event["image"]!,
                                  fit: BoxFit.cover,
                                ),

                                // Gradient overlay for readability
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.6),
                                        Colors.transparent
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),

                                // Event Title
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      event["title"]!,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        shadows: const [
                                          Shadow(
                                            blurRadius: 4,
                                            color: Colors.black54,
                                            offset: Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
