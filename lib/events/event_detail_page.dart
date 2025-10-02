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
      length: 3, // Details, Rules, Coordinators
      child: Scaffold(
        // ✅ Top AppBar
        appBar: CustomAppBar(
          title: event.name,
        ),

        // ✅ Left drawer (sidebar)
        drawer: AppDrawer(),

        // ✅ Floating circular register button with label
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                Material(
                elevation: 6,
                shape: const CircleBorder(),
                color: Colors.transparent,
                child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  // gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    // Add your registration logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Registering for ${event.name}..."),
                        backgroundColor: AppTheme.primaryBlue,
                      ),
                    );
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
              const SizedBox(height: 4),
              Text(
                "Register",
                style: Theme.of(context).popupMenuTheme.textStyle
              ),
            ],
          ),
        ),

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
                unselectedLabelColor: Theme.of(context).popupMenuTheme.textStyle?.color, // unselected tab text color
                tabs: const [
                  Tab(text: "Details"),
                  Tab(text: "Rules"),
                  Tab(text: "Coordinators"),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
