import 'package:flutter/material.dart';
import 'events_model.dart';
import "../theme/theme.dart";
import "../widgets/app_drawer.dart";
import "../widgets/custom_app_bar.dart";

class EventDetailPage extends StatelessWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Details, Rules, Coordinators, Register
      child: Scaffold(
        // ✅ Top AppBar
        appBar: const CustomAppBar(
          title: "INSTRUO'14",
        ),

        // ✅ Left drawer (sidebar)
        drawer: AppDrawer(),

        body: Column(
          children: [
            // Top image (fixed 40% of screen)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              child: Image.asset(
                event.image,
                fit: BoxFit.cover,
              ),
            ),

            // Tab bar directly below image

            Container(
              color: Theme.of(context).colorScheme.surface, // background of tab bar
              child: TabBar(
                indicatorColor: AppTheme.primaryBlue,      // underline for selected tab
                labelColor: AppTheme.primaryBlue,          // selected tab text color
                unselectedLabelColor: AppTheme.textSecondary, // unselected tab text color
                tabs: const [
                  Tab(text: "Details"),
                  Tab(text: "Rules"),
                  Tab(text: "Coordinators"),
                  Tab(text: "Register"),
                ],
              ),
            ),


            // TabBarView content
            Expanded(
              child: TabBarView(
                children: [
                  // Details tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(event.description),
                  ),

                  // Rules tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(event.category),
                  ),

                  // Coordinators tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(event.category),
                  ),

                  // Register tab
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Add your registration logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Registering for ${event.name}...")),
                        );
                      },
                      child: const Text("Register Now"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
