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
🎓 Exclusive for IIEST Shibpur Students!

HackSprint Kolkata Edition — National Level Hackathon is happening at IIEST Shibpur, West Bengal on 1st & 2nd November 2025, powered by SR Technologies.

🔥 Get an exclusive 50% discount on your registration — only for IIEST students!

🎯 Workshops:
• Artificial Intelligence / Machine Learning  
• MERN Stack Development with AI Integration

💡 Hackathon Domains:
AI & ML | Generative AI | MERN + AI | Healthcare | Open Innovation
""";

    const rulesFormLink =
        "https://forms.gle/oNfjrjwB5RS2YQwY8"; // replace with real GForm
    const websiteLink = "https://hacksprint.in/register/iiest"; // replace with real website

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
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 150),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        SelectableText(
                          hackathonDescription,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 24),

                        // Coordinators title
                        Text(
                          "Coordinators",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        // Hardcoded coordinators
                        Column(
                          children: const [
                            CoordinatorCard(
                              name: "Shreyansh",
                              phone: "8478090242",
                            ),
                            CoordinatorCard(
                              name: "Sujaan Sharma",
                              phone: "9462480435",
                            ),
                          ],
                        ),
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

// Reusable Coordinator Card
class CoordinatorCard extends StatelessWidget {
  final String name;
  final String phone;

  const CoordinatorCard({super.key, required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
            radius: 24,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Coordinator",
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.green),
            onPressed: () => launchDialer(phone, context),
          ),
        ],
      ),
    );
  }
}
