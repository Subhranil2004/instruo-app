import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'events_model.dart';
import '../widgets/my_textfield.dart';
import '../widgets/custom_app_bar.dart';
import '../helper/helper_functions.dart';
import '../theme/theme.dart';

class EventRegisterPage extends StatefulWidget {
  final Event event;

  const EventRegisterPage({super.key, required this.event});

  @override
  State<EventRegisterPage> createState() => _EventRegisterPageState();
}

class _EventRegisterPageState extends State<EventRegisterPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  List<Map<String, dynamic>> _selectedMembers = [];
  bool _isLoadingUsers = true;
  bool _showSearch = false;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _checkUserAndProfile();
    _loadUsers();
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkUserAndProfile() async {
    // Check if user is logged in
    if (currentUser == null) {
      displayMessageToUser("Please login or register first", context);
      Navigator.pop(context);
      return;
    }

    try {
      // Check if profile is complete
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser!.email)
          .get();

      if (doc.exists) {
        final userData = doc.data();
        final phone = userData?['phone'] ?? '';
        final department = userData?['department'] ?? '';
        final year = userData?['year'] ?? '';

        if (phone.isEmpty || department.isEmpty || year.isEmpty) {
          displayMessageToUser("Please complete your profile first", context);
          Navigator.pop(context);
          return;
        }
      } else {
        displayMessageToUser("Please complete your profile first", context);
        Navigator.pop(context);
        return;
      }
    } catch (e) {
      displayMessageToUser("Error checking profile: $e", context);
      Navigator.pop(context);
    }
  }

  Future<void> _loadUsers() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .get();

      final users = querySnapshot.docs
          .where((doc) => doc.id != currentUser?.email) // Exclude current user
          .map((doc) {
            final data = doc.data();
            return {
              'email': doc.id,
              'name': data['name'] ?? 'Unknown',
              'phone': data['phone'] ?? 'N/A',
              'department': data['department'] ?? 'N/A',
            };
          })
          .where((user) => user['name'] != 'Unknown') // Only include users with names
          .toList();

      setState(() {
        _allUsers = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      displayMessageToUser("Error loading users: $e", context);
    }
  }

  void _searchUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = [];
      });
      return;
    }

    final filtered = _allUsers.where((user) {
      final name = user['name'].toString().toLowerCase();
      final email = user['email'].toString().toLowerCase();
      final phone = user['phone'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();
      
      return name.contains(searchQuery) || 
            //  email.contains(searchQuery) || 
             phone.contains(searchQuery);
    }).toList();

    setState(() {
      _filteredUsers = filtered;
    });
  }

  void _addMember(Map<String, dynamic> user) {
    // Check if user is already selected
    if (_selectedMembers.any((member) => member['email'] == user['email'])) {
      displayMessageToUser("User already added to team", context);
      return;
    }

    // Check max team size
    if (_selectedMembers.length >= widget.event.maxTeamSize - 1) { // -1 for current user
      displayMessageToUser("Maximum team size (${widget.event.maxTeamSize}) reached", context);
      return;
    }

    setState(() {
      _selectedMembers.add(user);
      _searchController.clear();
      _filteredUsers = [];
      _showSearch = false;
    });
  }

  void _removeMember(int index) {
    setState(() {
      _selectedMembers.removeAt(index);
    });
  }

  Future<void> _registerForEvent() async {
    if (_teamNameController.text.trim().isEmpty) {
      displayMessageToUser(
        widget.event.maxTeamSize == 1 ? "Please enter your name" : "Please enter team name", 
        context
      );
      return;
    }

    final totalMembers = _selectedMembers.length + 1; // +1 for current user
    
    if (totalMembers < widget.event.minTeamSize) {
      displayMessageToUser(
        "Minimum team size is ${widget.event.minTeamSize}. You have $totalMembers member(s)", 
        context
      );
      return;
    }

    if (totalMembers > widget.event.maxTeamSize) {
      displayMessageToUser(
        "Maximum team size is ${widget.event.maxTeamSize}. You have $totalMembers member(s)", 
        context
      );
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      
      // Create team document
      final teamDoc = await firestore.collection('Teams').add({
        'name': _teamNameController.text.trim(),
        'members': [currentUser!.email!, ..._selectedMembers.map((m) => m['email']).toList()],
        // use uid instead?
        'lead': currentUser!.email!,
        'eventId': widget.event.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      final teamId = teamDoc.id;
      
      // Update the team document with its own ID
      await teamDoc.update({'tid': teamId});
      
      // Update Events collection - add team to event's teams list
      final eventDoc = firestore.collection('Events').doc(widget.event.id);
      await eventDoc.set({
        'teams': FieldValue.arrayUnion([teamId])
      }, SetOptions(merge: true));
      
      // Update Users collection - add event to each member's eventsRegistered list
      // Note: Commented out as Users collection doesn't have this field yet
      
      final batch = firestore.batch();
      
      // Add event to current user's eventsRegistered
      final currentUserDoc = firestore.collection('Users').doc(currentUser!.email!);
      batch.update(currentUserDoc, {
        'eventsRegistered': FieldValue.arrayUnion([widget.event.id])
      });
      
      // Add event to each team member's eventsRegistered
      for (final member in _selectedMembers) {
        final memberDoc = firestore.collection('Users').doc(member['email']);
        batch.update(memberDoc, {
          'eventsRegistered': FieldValue.arrayUnion([widget.event.id])
        });
      }
      
      await batch.commit();
      
      
      displayMessageToUser(
        "Successfully registered for ${widget.event.name}!", 
        context, 
        isError: false
      );
      
      Navigator.pop(context);
    } catch (e) {
      displayMessageToUser("Registration failed: $e", context);
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "${widget.event.name}",
        showBackButton: true,
        showProfileButton: false,
      ),
      body: _isLoadingUsers
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
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
                                // Text(
                                //   widget.event.name,
                                //   style: Theme.of(context).textTheme.titleLarge,
                                // ),
                                // const SizedBox(height: 8),
                                Text(
                                  "Team Size: ${widget.event.minTeamSize} - ${widget.event.maxTeamSize}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  "Registration Fee: ₹${widget.event.fee} (for non-IIESTians)",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Team/Individual Name
                        MyTextField(
                          controller: _teamNameController,
                          labelText: widget.event.maxTeamSize == 1 ? "Your Name" : "Team Name",
                          hintText: widget.event.maxTeamSize == 1 
                              ? "Enter your name" 
                              : "Enter team name",
                        ),
                        const SizedBox(height: 20),

                        // Team Members Section (only if maxTeamSize > 1)
                        if (widget.event.maxTeamSize > 1) ...[
                          Text(
                            "Team Members",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),

                          // Selected Members
                          ..._selectedMembers.asMap().entries.map((entry) {
                            final index = entry.key;
                            final member = entry.value;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(member['name'][0].toUpperCase()),
                                ),
                                title: Text(member['name']),
                                subtitle: Text("${member['phone']}"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _removeMember(index),
                                ),
                                // isThreeLine: true,
                              ),
                            );
                          }).toList(),

                          // Add Member Button
                          if (_selectedMembers.length < widget.event.maxTeamSize - 1)
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showSearch = true;
                                });
                              },
                              icon: const Icon(Icons.person_add),
                              label: const Text("Add Member"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                                foregroundColor: AppTheme.primaryBlue,
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Search Section
                          if (_showSearch) ...[
                            MyTextField(
                              controller: _searchController,
                              labelText: "Search Members",
                              hintText: "Type name, email or phone...",
                              onChanged: _searchUsers,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _showSearch = false;
                                    _searchController.clear();
                                    _filteredUsers = [];
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Search Results
                            if (_filteredUsers.isNotEmpty)
                              Container(
                                constraints: const BoxConstraints(maxHeight: 300),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _filteredUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = _filteredUsers[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: index > 0 ? Border(
                                          top: BorderSide(color: Colors.grey.shade200),
                                        ) : null,
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                                          child: Text(
                                            user['name'][0].toUpperCase(),
                                            style: TextStyle(color: AppTheme.primaryBlue),
                                          ),
                                        ),
                                        title: Text(user['name']),
                                        subtitle: Text("${user['email']}\n${user['phone']}"),
                                        onTap: () => _addMember(user),
                                        isThreeLine: true,
                                        trailing: Icon(Icons.add_circle_outline, color: AppTheme.primaryBlue),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ],

                        const SizedBox(height: 100), // Space for fixed button
                      ],
                    ),
                  ),
                ),

                // Fixed Register Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isRegistering ? null : _registerForEvent,
                    child: _isRegistering
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Register"),
                  ),
                ),
              ],
            ),
    );
  }
}