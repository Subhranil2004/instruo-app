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
    {"title": "", "image": "assets/events/technical.jpeg"},
    {"title": "", "image": "assets/events/general.jpg"},
    {"title": "", "image": "assets/events/robotics.jpg"},
    {"title": "", "image": "assets/events/gaming.jpg"},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: const CustomAppBar(
        title: "HOME",
        showBackButton: false,
      ),
      drawer: AppDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🖼️ Background Image
          Image.asset(
            'assets/bg_image.png',
            fit: BoxFit.contain,
          ),

          // Semi-transparent overlay
          Container(
            color: theme.colorScheme.shadow.withOpacity(0.4),
          ),

          // 🧱 Main Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 24,
              bottom: 80,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 💫 Welcome Section
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradient.createShader(bounds),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Text(
                        "Welcome To",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "INSTRUO'14",
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 40,
                          letterSpacing: 1.4,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black38,
                              offset: Offset(2, 3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Fest Website Button
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withOpacity(0.15),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(2, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      launchDialer("https://instruo.tech/", context,
                          isUrl: true);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.public_rounded,
                          color: AppTheme.primaryBlue,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Visit Fest Website",
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🧩 Event Tiles Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: eventTypes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    // ✨ REDUCED SPACING: Changed axis spacing to 12
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final event = eventTypes[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventsContainer(initialIndex: index),
                          ),
                        );
                      },
                      child: Card(
                        // ✨ ADD THIS LINE to make the card's background transparent
                        color: Colors.transparent, 
                        
                        // ✨ SET THIS TO 0 as transparent cards don't have shadows
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                              color: Colors.white.withOpacity(0.2), width: 1),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              event["image"]!,
                              fit: BoxFit.cover,
                              opacity: const AlwaysStoppedAnimation(0.65),
                            ),
                           
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  event["title"]!,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                    shadows: const [
                                      Shadow(
                                        blurRadius: 6,
                                        color: Colors.black45,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}