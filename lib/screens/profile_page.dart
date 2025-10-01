import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instruo_application/widgets/custom_app_bar.dart';
import 'package:instruo_application/widgets/my_textfield.dart';
import 'package:instruo_application/helper/helper_functions.dart';

import '../events/events_info.dart';
import '../events/events_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();

  String? _selectedYear;
  bool _isIIESTian = true;
  bool _isLoading = false;
  bool _isDataLoaded = false;
  bool _isEditing = false;
  bool _isCoordinating = false;
  
  String _userName = ''; // New state variable for the user's name
  List<dynamic> _coordinatingEventsIds = [];
  List<Event> _coordinatingEvents = [];

  final List<String> _yearOptions = [
    "UG1", "UG2", "UG3", "UG4", "UG5",
    "PG1", "PG2", "PhD"
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _departmentController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserDetails() async {
    if (currentUser != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser!.email)
            .get();

        if (doc.exists) {
          var userData = doc.data();
          setState(() {
            _userName = userData?['name'] ?? 'N/A'; // Fetch the name
            _phoneController.text = userData?['phone'] ?? '';
            _departmentController.text = userData?['department'] ?? '';
            String? firestoreYear = userData?['year'];
            if (firestoreYear != null && _yearOptions.contains(firestoreYear)) {
              _selectedYear = firestoreYear;
            }
            _isCoordinating = userData?['isCoordinator'] ?? false;
            _coordinatingEventsIds = userData?['coordinatingEvents'] ?? [];
            _coordinatingEvents = events.where((event) => _coordinatingEventsIds.contains(event.id)).toList();
            _isIIESTian = userData?['iiestian'] ?? true;
            _collegeController.text = userData?['collegeName'] ?? '';
            _isDataLoaded = true;
          });
        }
      } catch (e) {
        print("Error fetching user details: $e");
        setState(() {
          _isDataLoaded = true;
        });
      }
    }
  }

  Future<void> updateProfile() async {
    if (currentUser != null) {
      if (_phoneController.text.trim().isEmpty ||
          _departmentController.text.trim().isEmpty ||
          _selectedYear == null ||
          (!_isIIESTian && _collegeController.text.trim().isEmpty)) {
        displayMessageToUser("Please fill all required fields", context);
        return;
      }

      if(_phoneController.text.trim().length != 10 || int.tryParse(_phoneController.text.trim()) == null) {
        displayMessageToUser("Please enter a valid 10-digit phone number", context);
        return;
      }

      setState(() => _isLoading = true);

      try {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser!.email)
            .update({
          'phone': _phoneController.text.trim(),
          'department': _departmentController.text.trim(),
          'year': _selectedYear,
          'iiestian': _isIIESTian,
          'collegeName': _isIIESTian ? "IIEST" : _collegeController.text.trim(),
        });

        displayMessageToUser('✅ Profile updated successfully!', context, isError: false);
        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        displayMessageToUser('Failed to update profile.', context);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "PROFILE",
        showBackButton: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: !_isDataLoaded
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.account_circle, size: 100),
                    const SizedBox(height: 20),
                    
                    // Display the name here
                    Center(
                      child: Text(
                        _userName,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Center(
                      child: Text(
                        "Email: ${currentUser?.email ?? ''}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),

                    const SizedBox(height: 20),
                    
                    _isEditing
                        ? Column(
                            children: [
                              MyTextField(
                                labelText: 'Phone Number',
                                hintText: '1234567890',
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 15),
                              MyTextField(
                                hintText: 'Enter CAPS abbr. (e.g., CST, IT)',
                                labelText: 'Department',
                                controller: _departmentController,
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(height: 15),
                              DropdownButtonFormField<String>(
                                value: _selectedYear,
                                items: _yearOptions
                                    .map((year) => DropdownMenuItem(
                                        value: year, child: Text(year)))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedYear = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Year',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              SwitchListTile(
                                title: const Text("Are you from IIEST?"),
                                value: _isIIESTian,
                                onChanged: (val) {
                                  setState(() {
                                    _isIIESTian = val;
                                  });
                                },
                              ),
                              if (!_isIIESTian)
                                Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    MyTextField(
                                      hintText: 'College Name',
                                      controller: _collegeController,
                                      labelText: 'College Name',
                                    ),
                                  ],
                                ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDataRow('Phone Number', _phoneController.text),
                              _buildDataRow('Department', _departmentController.text),
                              if (_selectedYear != null)
                                _buildDataRow('Year', _selectedYear!),
                              _buildDataRow('College', _isIIESTian ? "IIEST" : _collegeController.text),
                            ],
                          ),
                    
                    const SizedBox(height: 25),
                    
                    _isEditing
                        ? ElevatedButton(
                            onPressed: _isLoading ? null : updateProfile,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Save"),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                            child: const Text("Edit"),
                          ),
                    
                    if (_isCoordinating && !_isEditing) ...[
                      const SizedBox(height: 20),
                      const Text(
                        "Coordinating Events",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Divider(),
                      if (_coordinatingEvents.isEmpty)
                        const Text("No events assigned yet.")
                      else
                        // Corrected: Use an Expanded widget to allow scrolling within the Column.
                        ListView.builder(
                          shrinkWrap: true, // This is crucial for nesting
                          physics: const NeverScrollableScrollPhysics(), // Prevents scrolling for the inner ListView
                          itemCount: _coordinatingEvents.length,
                          itemBuilder: (context, index) {
                            final event = _coordinatingEvents[index];
                            return ListTile(
                              title: Text(event.name),
                              trailing: Text(event.category.toUpperCase()), 
                            );
                          },
                        ),
                    ], 
                  ],
                ),
              ),
      ),
    );
  }
}