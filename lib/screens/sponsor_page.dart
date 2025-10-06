import 'package:flutter/material.dart';
import 'package:instruo_application/widgets/custom_app_bar.dart';

class SponsorsPage extends StatelessWidget {
  // Placeholder list of sponsors
  final List<Map<String, String>> sponsors = [
    {
      "name": "Sponsor 1",
      "imageUrl": "https://via.placeholder.com/150"
    },
    {
      "name": "Sponsor 2",
      "imageUrl": "https://via.placeholder.com/150"
    },
    {
      "name": "Sponsor 3",
      "imageUrl": "https://via.placeholder.com/150"
    },
    {
      "name": "Sponsor 4",
      "imageUrl": "https://via.placeholder.com/150"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  CustomAppBar(
        title: "SPONSORS",
        showBackButton: true,
        onBackPressed: () {
          Navigator.pushReplacementNamed(context, '/home'); // Navigate to the home route
        },
        showProfileButton: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: sponsors.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 sponsors per row
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final sponsor = sponsors[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(
                        sponsor['imageUrl']!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    sponsor['name']!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
