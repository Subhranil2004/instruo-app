import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/theme.dart'; // app's theme
import '../widgets/app_drawer.dart';
import '../widgets/custom_app_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  final String youtubeUrl = "https://www.youtube.com/watch?v=dQw4w9WgXcQ";

  Future<void> _openYouTube() async {
    final Uri url = Uri.parse(youtubeUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not open the video.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar:  CustomAppBar(
        title: "CAMPUS DIRECTION",
        showBackButton: false,
        showProfileButton: false,
      ),
      drawer: AppDrawer(), //  app drawer
      backgroundColor: theme.colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- College & Fest Logos ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/college_logo.png',
                  height: 90,
                ),
                const SizedBox(width: 20),
                Image.asset(
                  'assets/images/fest_logo.png',
                  height: 90,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- Embedded YouTube Video Placeholder ---
            GestureDetector(
              onTap: _openYouTube,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      'https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg', // Thumbnail preview
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      color: Colors.black54,
                      height: 200,
                      width: double.infinity,
                    ),
                    Icon(
                      Icons.play_circle_fill,
                      size: 64,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- Description Section ---
            Divider(
              color: theme.colorScheme.primary,
              thickness: 1.5,
            ),
            const SizedBox(height: 12),
            Text(
              "Instruo is the annual techno-management fest of IIEST Shibpur. "
              "It brings together creativity, innovation, and intellect through "
              "various technical competitions, workshops, and cultural performances. "
              "Join us for an unforgettable experience celebrating technology and talent!",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Divider(
              color: theme.colorScheme.primary,
              thickness: 1.5,
            ),
          ],
        ),
      ),
    );
  }
}
