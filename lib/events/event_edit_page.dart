import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'events_model.dart';
import '../widgets/custom_app_bar.dart';
import '../helper/helper_functions.dart';
import '../theme/theme.dart';

class EventEditPage extends StatefulWidget {
  final Event event;

  const EventEditPage({super.key, required this.event});

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  Map<String, dynamic>? _teamData;
  String _teamId = '';

  @override
  void initState() {
    super.initState();
    _loadRegistrationData();
  }

  Future<void> _loadRegistrationData() async {
    if (currentUser == null) {
      displayMessageToUser("User not logged in", context);
      Navigator.pop(context);
      return;
    }

    try {
      // Find the team document for this user and event
      final teamsQuery = await FirebaseFirestore.instance
          .collection('Teams')
          .where('eventId', isEqualTo: widget.event.id)
          .where('members', arrayContains: currentUser!.email!)
          .get();

      if (teamsQuery.docs.isNotEmpty) {
        final teamDoc = teamsQuery.docs.first;
        setState(() {
          _teamData = teamDoc.data();
          _teamId = teamDoc.id;
          _isLoading = false;
        });
      } else {
        displayMessageToUser("Registration not found", context);
        Navigator.pop(context);
      }
    } catch (e) {
      displayMessageToUser("Error loading registration: $e", context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Edit Registration",
        showBackButton: true,
        showProfileButton: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Team Size: ${widget.event.minTeamSize} - ${widget.event.maxTeamSize}",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            "Registration Fee: ₹${widget.event.fee}",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Current Registration Info
                  Text(
                    "Current Registration",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),

                  // Team/Individual Name
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event.maxTeamSize == 1 ? "Name" : "Team Name",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _teamData?['name'] ?? 'Unknown',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Team Members (if applicable)
                  if (widget.event.maxTeamSize > 1 && _teamData != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      "Team Members",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    
                    // Display team members
                    ...(_teamData!['members'] as List<dynamic>).map((memberEmail) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(memberEmail.toString()[0].toUpperCase()),
                          ),
                          title: Text(memberEmail.toString()),
                          subtitle: memberEmail == _teamData!['lead'] 
                              ? const Text("Team Leader")
                              : null,
                          trailing: memberEmail == _teamData!['lead']
                              ? Icon(Icons.star, color: AppTheme.primaryBlue)
                              : null,
                        ),
                      );
                    }).toList(),
                  ],

                  const SizedBox(height: 24),

                  // Edit Options (Coming Soon)
                  Card(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.construction,
                            size: 48,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Edit Functionality Coming Soon",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "You can currently view your registration details. Editing capabilities will be available soon.",
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Registration Details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Registration Details",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.group, size: 16, color: AppTheme.primaryBlue),
                              const SizedBox(width: 8),
                              Text("Team ID: $_teamId"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.event, size: 16, color: AppTheme.primaryBlue),
                              const SizedBox(width: 8),
                              Text("Event: ${widget.event.name}"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}