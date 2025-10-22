import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:instruo_application/widgets/custom_app_bar.dart';
import 'package:instruo_application/widgets/my_textfield.dart';
import 'package:instruo_application/helper/helper_functions.dart';
import '../theme/theme.dart';

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
  File? _selectedIdCardFile;
  String? _existingIdCardUrl;
  bool _isUploadingIdCard = false;
  bool _isDeletingIdCard = false;
  String _userName = ''; // New state variable for the user's name
  List<dynamic> _coordinatingEventsIds = [];
  List<Event> _coordinatingEvents = [];
  List<Event> _registeredEvents = [];

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
            _coordinatingEventsIds = List<String>.from(userData?['coordinatingEvents'] ?? []);
            _coordinatingEvents = events
                .where((event) => _coordinatingEventsIds.contains(event.id))
                .toList();

            // Convert eventsRegistered IDs to List<String> and map to Event objects
            List<String> registeredIds = List<String>.from(userData?['eventsRegistered'] ?? []);
            _registeredEvents = events
                .where((event) => registeredIds.contains(event.id))
                .toList();
            _existingIdCardUrl = userData?['ID_card'];
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
        String collegeName = _isIIESTian ? "IIEST" : _collegeController.text.trim();
        // bool isIIESTian = _isIIESTian || collegeName.toUpperCase() == "IIEST";
        
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser!.email)
            .update({
          'phone': _phoneController.text.trim(),
          'department': _departmentController.text.trim(),
          'year': _selectedYear,
          'iiestian': _isIIESTian,
          'collegeName': collegeName,
          // if image already uploaded previously, keep it; otherwise update later after upload
        });

        // If a new ID card image is selected, upload it and update Firestore with download URL
        if (_isIIESTian && _selectedIdCardFile != null) {
          final userDocRef = FirebaseFirestore.instance.collection('Users').doc(currentUser!.email);
          // Use the fetched user name (sanitized) or fallback to uid if not available
          final safeName = (_userName.isNotEmpty) ? _userName.replaceAll(' ', '_') : currentUser!.uid;
          String filePath = 'id_cards/${safeName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final storageRef = firebase_storage.FirebaseStorage.instance.ref().child(filePath);

          try {
            setState(() { _isUploadingIdCard = true; });
            final uploadTask = storageRef.putFile(_selectedIdCardFile!);
            final snapshot = await uploadTask.whenComplete(() => {});
            final downloadUrl = await snapshot.ref.getDownloadURL();

            await FirebaseFirestore.instance.runTransaction((transaction) async {
              transaction.update(userDocRef, {'ID_card': downloadUrl});
            });

            setState(() {
              _existingIdCardUrl = downloadUrl;
              _selectedIdCardFile = null; // clear local selection after upload
              _isUploadingIdCard = false;
            });
          } catch (e) {
            // If upload fails, notify user but don't rollback other profile updates
            displayMessageToUser('Failed to upload ID card image.', context);
            setState(() { _isUploadingIdCard = false; });
          }
        }

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          _selectedIdCardFile = File(picked.path);
        });
      }
    } catch (e) {
      displayMessageToUser('Image selection failed.', context);
    }
  }

  Future<void> _deleteIdCard() async {
    // If a local selection exists, just remove it
    if (_selectedIdCardFile != null) {
      setState(() {
        _selectedIdCardFile = null;
      });
      return;
    }

    // Otherwise, delete the remote image from Storage (if possible) and remove field from Firestore
    if (_existingIdCardUrl == null || _existingIdCardUrl!.isEmpty || currentUser == null) return;

    setState(() { _isDeletingIdCard = true; });

    try {
      // Try to derive storage reference from URL
      final storageRef = firebase_storage.FirebaseStorage.instance.refFromURL(_existingIdCardUrl!);
      await storageRef.delete();
    } catch (e) {
      // If deletion from storage fails, still attempt to clear Firestore field
      print('Failed to delete storage file: $e');
    }

    try {
      await FirebaseFirestore.instance.collection('Users').doc(currentUser!.email).update({'ID_card': FieldValue.delete()});
    } catch (e) {
      print('Failed to clear ID_card field: $e');
    }

    setState(() {
      _existingIdCardUrl = null;
      _isDeletingIdCard = false;
    });
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
    // print("Coordinator events: ${_coordinatingEvents.length}");
                      // print("Coordinator event IDs: $_coordinatingEventsIds");
    return Scaffold(
      appBar: const CustomAppBar(
        title: "PROFILE",
        showBackButton: true,
        showProfileButton: false,
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
                        ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
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
                                (!_isIIESTian)
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 10),
                                          MyTextField(
                                            hintText: 'College Name',
                                            controller: _collegeController,
                                            labelText: 'College Name',
                                          ),
                                        ],
                                      ),
                                    )
                                  : Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              "Upload IIEST ID Card:",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            // const SizedBox(width: 8),
                                            IconButton(
                                              onPressed: (_selectedIdCardFile != null || (_existingIdCardUrl != null && _existingIdCardUrl!.isNotEmpty) || _isDeletingIdCard || _isUploadingIdCard)
                                                  ? () => displayMessageToUser("Please remove the existing ID card before uploading a new one.", context)
                                                  : () => _pickImage(ImageSource.gallery),
                                              icon: const Icon(Icons.upload_file, color: AppTheme.primaryBlue, size: 24.0),
                                            ),
                                            const Text('or'),
                                            IconButton(
                                              onPressed: (_selectedIdCardFile != null || (_existingIdCardUrl != null && _existingIdCardUrl!.isNotEmpty) || _isDeletingIdCard || _isUploadingIdCard)
                                                  ? () => displayMessageToUser("Please remove the existing ID card before uploading a new one.", context)
                                                  : () => _pickImage(ImageSource.camera),
                                              icon: Icon(Icons.camera_alt_outlined, color: AppTheme.primaryBlue, size: 24.0),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // show preview underneath upload row while editing
                                        _buildIdCardPreview(),
                                      ],
                                    ),
                                  )
                              ],
                            ),
                        )
                        : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDataRow('Phone Number', _phoneController.text),
                                _buildDataRow('Department', _departmentController.text),
                                if (_selectedYear != null)
                                  _buildDataRow('Year', _selectedYear!),
                                _buildDataRow('College', _isIIESTian ? "IIEST" : _collegeController.text),
                                // NOTE: preview is shown in editing mode under upload controls; when not editing we don't show the preview here
                              ],
                            ),
                        ),
                    
                    const SizedBox(height: 25),
                    
                    _isEditing
                        ? ElevatedButton(
                            onPressed: (_isLoading || _isUploadingIdCard) ? null : updateProfile,
                            child: (_isLoading || _isUploadingIdCard)
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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
                      const Divider(
                        indent: 18.0,
                        endIndent: 18.0,
                      ),
                      if (_coordinatingEventsIds.isNotEmpty && _coordinatingEventsIds.first == "all")
                        // Aesthetic banner for full-access coordinators
                        gigaCoordinatorBanner(context)
                      else if (_coordinatingEvents.isEmpty)
                        const Text("No events assigned yet.")
                      else
                        // Make only the list scrollable by bounding its height
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.height * 0.25, // max 35%
                                  ), // ~40% of screen height
                            child: ListView.builder(
                              // Let this ListView handle its own scrolling
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _coordinatingEvents.length,
                              itemBuilder: (context, index) {
                                final event = _coordinatingEvents[index];
                                return ListTile(
                                  title: Text(event.name),
                                  trailing: Text(event.category.toUpperCase()), 
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                    if (!_isEditing) ...[
                      const SizedBox(height: 20),
                      const Text(
                        "Registered Events",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Divider(
                        indent: 18.0,
                        endIndent: 18.0,
                      ),
                      if (_registeredEvents.isEmpty)
                        const Text("Not registered for any events yet.")
                      else
                        // Make only the list scrollable by bounding its height
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.height * 0.25, // max 35%
                                  ),  // ~40% of screen height
                            child: ListView.builder(
                              // Let this ListView handle its own scrolling
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _registeredEvents.length,
                              itemBuilder: (context, index) {
                                final event = _registeredEvents[index];
                                return ListTile(
                                  title: Text(event.name),
                                  trailing: Text(event.category.toUpperCase()), 
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Container gigaCoordinatorBanner(BuildContext context) {
    return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: const Icon(Icons.workspace_premium, color: Colors.white),
                          ),
                          title: Text(
                            "Giga Coordinator",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          subtitle: Text(
                            "Access to all events ✨",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.95),
                                ),
                          ),
                          trailing: const Icon(Icons.verified, color: Colors.white),
                        ),
                      );
  }

  Widget _buildIdCardPreview() {
    final double previewHeight = 150;
    if (_selectedIdCardFile != null) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            // height: previewHeight,
            // width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedIdCardFile!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Positioned(
            right: 6,
            top: 6,
            child: _isDeletingIdCard
                ? const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2))
                : IconButton(
                    onPressed: _deleteIdCard,
                    icon: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.delete, size: 18, color: Colors.redAccent),
                    ),
                  ),
          ),
        ],
      );
    }

    if (_existingIdCardUrl != null && _existingIdCardUrl!.isNotEmpty) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            // height: previewHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _existingIdCardUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stack) => const Center(child: Icon(Icons.broken_image)),
              ),
            ),
          ),
          Positioned(
            right: 6,
            top: 6,
            child: _isDeletingIdCard
                ? const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2))
                : IconButton(
                    onPressed: _deleteIdCard,
                    icon: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.delete, size: 18, color: Colors.redAccent),
                    ),
                  ),
          ),
        ],
      );
    }

    return Container(
      height: previewHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text('No ID card uploaded', style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}