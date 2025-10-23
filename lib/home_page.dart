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
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;
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
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            const SizedBox(height: 40),
            Column(
              children: [
                Image.asset("assets/fest_logo.png", height: 100),
                const SizedBox(height: 20),
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
            const SizedBox(height: 20),
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
                          height: Curves.easeOut.transform(value) * 320,
                          child: child,
                        ),
                      );
                    },
                    child: GestureDetector(
                      onTap: () {
                        int initialIndex;
                        switch (event["title"]) {
                          case "Technical":
                            initialIndex = 0;
                            break;
                          case "General":
                            initialIndex = 1;
                            break;
                          case "Robotics":
                            initialIndex = 2;
                            break;
                          case "Gaming":
                            initialIndex = 3;
                            break;
                          default:
                            return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventsContainer(initialIndex: initialIndex),
                          ),
                        );
                      },
                      child: Card(
                        elevation: theme.cardTheme.elevation,
                        shape: theme.cardTheme.shape,
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                event["image"]!,
                                fit: BoxFit.cover,
                              ),
                            ),
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
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  event["title"]!,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
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
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
