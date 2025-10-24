import 'package:flutter/material.dart';
import 'package:instruo_application/helper/helper_functions.dart';
import '../widgets/app_drawer.dart';
import '../theme/theme.dart';

class Hackathon extends StatelessWidget {
  const Hackathon({super.key});

  @override
  Widget build(BuildContext context) {
    const hackathonName = "INSTRUO Hackathon";
    const hackathonImage = "assets/hackathon.jpeg"; // update path
    const hackathonDescription = """
🎓 **Exclusive for IIEST Shibpur Students!**

HackSprint Kolkata Edition — National Level Hackathon is happening at **IIEST Shibpur, West Bengal** on **1st & 2nd November 2025**, powered by **SR Technologies**.

🔥 **Get an exclusive 50% discount on your registration — only for IIEST students!**

🎯 **Workshops:**
• Artificial Intelligence / Machine Learning  
• MERN Stack Development with AI Integration

💡 **Hackathon Domains:**
AI & ML | Generative AI | MERN + AI | Healthcare | Open Innovation
""";

    const rulesFormLink =
        "https://forms.gle/oNfjrjwB5RS2YQwY8"; // replace with real GForm
    const websiteLink = "http://hacksprint.in/"; // replace with real website

    return Scaffold(
      drawer: AppDrawer(),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.4,
                pinned: true,
                backgroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    hackathonName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  background: Hero(
                    tag: hackathonName,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(hackathonImage, fit: BoxFit.cover),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black54],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Body content
              SliverToBoxAdapter(
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        SelectableText(
                          hackathonDescription,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating buttons (Website + Form)
          Positioned(
            bottom: 30,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Website / Register Button
                FloatingActionButton.extended(
                  heroTag: "websiteBtn",
                  backgroundColor: AppTheme.primaryBlue,
                  onPressed: () {
                    launchDialer(websiteLink, context, isUrl: true);
                  },
                  icon: const Icon(Icons.web),
                  label: const Text("Visit Website / Register"),
                ),
                const SizedBox(height: 12),

                // Google Form Button
                FloatingActionButton.extended(
                  heroTag: "formBtn",
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.9),
                  onPressed: () {
                    launchDialer(rulesFormLink, context, isUrl: true);
                  },
                  icon: const Icon(Icons.description),
                  label: const Text("Fill After Registration"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
