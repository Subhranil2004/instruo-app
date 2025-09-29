import 'package:flutter/material.dart';
import 'event_type_page.dart';
import 'widgets/app_drawer.dart';
import 'events/technical_page.dart';
import 'events/robotics_page.dart';
import 'events/gaming_page.dart';
import 'events/general_page.dart';
import 'theme/theme.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color bgTop = isDark ? AppTheme.surfaceDark : AppTheme.backgroundLight;
    final Color bgBottom = isDark ? AppTheme.backgroundDark : AppTheme.backgroundGradientEnd;

    return Scaffold(
      appBar: AppBar(
        title: const Text("INSTRUO'14"),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgTop, bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
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
                            nextPage =
                                EventTypePage(title: event["title"]!);
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => nextPage),
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
