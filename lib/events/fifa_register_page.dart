import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instruo_application/widgets/my_button.dart';
import 'events_model.dart';
import '../widgets/my_textfield.dart';
import '../widgets/custom_app_bar.dart';
import '../helper/helper_functions.dart';
import '../theme/theme.dart';

class FifaRegisterPage extends StatefulWidget {
  final Event event;

  const FifaRegisterPage({super.key, required this.event});

  @override
  State<FifaRegisterPage> createState() => _FifaRegisterPageState();
}

class _FifaRegisterPageState extends State<FifaRegisterPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  // Will you bring your own controller? true == yes, false == no, null == not selected
  bool? _bringingOwnController;
  
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  List<Map<String, dynamic>> _selectedMembers = [];
  // Payment screenshot state
  File? _selectedPaymentSSFile;
  bool _isUploadingPaymentSS = false;
  // track current user's iiestian flag so fee calculation is correct
  bool _currentUserIsIIESTian = true;
  // ID card upload is handled in profile_page.dart; no local state required here
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
        final iiestian = userData?['iiestian'] ?? false;
        final idCard = userData?['ID_card'] ?? '';

        // store current user's iiestian flag for fee calculations
        setState(() {
          _currentUserIsIIESTian = iiestian == true;
        });

        if (phone.isEmpty || department.isEmpty || year.isEmpty) {
          displayMessageToUser("Please complete your profile first", context);
          Navigator.pop(context);
          return;
        }
        if (iiestian && idCard.isEmpty) {
          print("ID Card: $idCard");
          displayMessageToUser("Please upload your IIEST ID card in profile", context);
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
              'name': data['name'] ?? '',
              'phone': data['phone'] ?? '',
              'department': data['department'] ?? '',
              'collegeName': data['collegeName'] ?? '',
              'year': data['year'] ?? '',
              'iiestian': data['iiestian'] ?? false,
              'ID_card': data['ID_card'],
            };
          })
          .where((user) {
            final hasBasic = user['name']!.isNotEmpty &&
                user['phone']!.isNotEmpty &&
                user['department']!.isNotEmpty &&
                user['collegeName']!.isNotEmpty &&
                user['year']!.isNotEmpty;

            // If iiestian is true, require ID_card to be present and non-empty
            final isIIESTian = (user.containsKey('iiestian') && user['iiestian'] == true);
            final hasIdCard = user.containsKey('ID_card') && (user['ID_card'] != null) && user['ID_card'].toString().isNotEmpty;

            return hasBasic && (isIIESTian ? hasIdCard : true);
          }) // Only include users with complete profiles
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
      // When the search query is empty, show all available users
      setState(() {
        _filteredUsers = List<Map<String, dynamic>>.from(_allUsers);
      });
      return;
    }

    final filtered = _allUsers.where((user) {
      final name = user['name'].toString().toLowerCase();
      final phone = user['phone'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();
      
      return name.contains(searchQuery) || 
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

    setState(() {
      _isRegistering = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // Count non-IIESTIAN users (they pay)
      int nonIIESTIANCount = 0;
      // include current user
      if (!_currentUserIsIIESTian) nonIIESTIANCount += 1;
      // include selected members
      nonIIESTIANCount += _selectedMembers.where((m) => (m['iiestian'] == null || m['iiestian'] == false)).length;

      final totalAmount = widget.event.fee * nonIIESTIANCount;

      // If payment is required (amount > 0) ensure a payment screenshot is provided
      if (totalAmount > 0 && _selectedPaymentSSFile == null) {
        // show snackbar error and abort
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment of ₹$totalAmount required for non-IIESTIAN members. Please upload payment screenshot.')),
        );
        setState(() { _isRegistering = false; });
        return;
      }

      String? paymentDownloadUrl;
      // If a new payment ss is selected, upload it
      if (_selectedPaymentSSFile != null) {
        final safeName = (_teamNameController.text.isNotEmpty) ? _teamNameController.text.replaceAll(' ', '_') : currentUser!.uid;
        String filePath = 'payments/${safeName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageRef = firebase_storage.FirebaseStorage.instance.ref().child(filePath);

        try {
          setState(() { _isUploadingPaymentSS = true; });
          final uploadTask = storageRef.putFile(_selectedPaymentSSFile!);
          final snapshot = await uploadTask.whenComplete(() => {});
          paymentDownloadUrl = await snapshot.ref.getDownloadURL();
          setState(() { _isUploadingPaymentSS = false; });
        } catch (e) {
          setState(() { _isUploadingPaymentSS = false; _isRegistering = false; });
          displayMessageToUser('Failed to upload payment screenshot: $e', context);
          return;
        }
      }

      // Use a single batched write to create the team and update Events and Users
      final batch = firestore.batch();

      // Create a new Team document with a generated ID and include tid in the document
      final teamRef = firestore.collection('Teams').doc(); // generated id
      final teamId = teamRef.id;
      final Map<String, dynamic> teamData = {
        'name': _teamNameController.text.trim(),
        'members': [currentUser!.email!, ..._selectedMembers.map((m) => m['email']).toList()],
        'lead': currentUser!.email!,
        'eventId': widget.event.id,
        'createdAt': FieldValue.serverTimestamp(),
        'tid': teamId,
      };

      // attach payment screenshot url if available
      if (paymentDownloadUrl != null && paymentDownloadUrl.isNotEmpty) {
        teamData['payment_ss'] = paymentDownloadUrl;
      }

      // attach controller bringing choice
      if (_bringingOwnController != null) {
        teamData['bringing_own_controller'] = _bringingOwnController;
      } else {
        teamData['bringing_own_controller'] = null;
      }

      batch.set(teamRef, teamData);

      // Update Events collection - add team id to event's teams array (merge)
      final eventRef = firestore.collection('Events').doc(widget.event.id);
      batch.set(eventRef, {
        'teams': FieldValue.arrayUnion([teamId])
      }, SetOptions(merge: true));

      // Update Users collection - add event to each member's eventsRegistered list (merge)
      final currentUserRef = firestore.collection('Users').doc(currentUser!.email!);
      batch.set(currentUserRef, {
        'eventsRegistered': FieldValue.arrayUnion([widget.event.id])
      }, SetOptions(merge: true));

      for (final member in _selectedMembers) {
        final memberRef = firestore.collection('Users').doc(member['email']);
        batch.set(memberRef, {
          'eventsRegistered': FieldValue.arrayUnion([widget.event.id])
        }, SetOptions(merge: true));
      }

      // Commit all writes in one atomic operation
      await batch.commit();
      //////////////////////////////////////////////
      
      displayMessageToUser(
        "Successfully registered for ${widget.event.name}!", 
        context, 
        isError: false
      );
      
      Navigator.pop(context);
    } catch (e) {
      displayMessageToUser("Registration failed: $e", context, durationSeconds: 4);
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  // ID card selection handled in profile page

  // Payment screenshot pick (separate from ID card)
  Future<void> _pickPaymentImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          _selectedPaymentSSFile = File(picked.path);
        });
      }
    } catch (e) {
      displayMessageToUser('Payment screenshot selection failed.', context);
    }
  }

  // Show confirmation dialog before finalizing registration
  void _onRegisterPressed() {
    // Pre-checks: team size and payment screenshot requirement

    if (_teamNameController.text.trim().isEmpty) {
      displayMessageToUser(
        "Please enter team name", 
        context
      );
      return;
    }

    final totalMembers = _selectedMembers.length + 1; // +1 for current user
    if (totalMembers < widget.event.minTeamSize) {
      displayMessageToUser(
        "Minimum team size is ${widget.event.minTeamSize}. You have $totalMembers member(s)",
        context,
      );
      return;
    }

    // compute total amount similar to _registerForEvent for display
    int nonIIESTIANCount = 0;
    if (!_currentUserIsIIESTian) nonIIESTIANCount += 1;
    nonIIESTIANCount += _selectedMembers.where((m) => (m['iiestian'] == null || m['iiestian'] == false)).length;
    final totalAmount = nonIIESTIANCount >= 1 ? widget.event.fee : 0;


    // If payment is required ensure a payment screenshot is provided BEFORE showing confirmation
    if (totalAmount > 0 && _selectedPaymentSSFile == null) {
      displayMessageToUser('Payment of ₹$totalAmount required. Please upload payment screenshot.', context, durationSeconds: 4);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Registration', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You are about to register for "${widget.event.name}"'),
              const SizedBox(height: 8),
                if (totalAmount > 0) ...[
                const SizedBox(height: 8),
                Text('Total amount due: ₹$totalAmount', style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
              ],
              Text('Please ensure the payment screenshot (if any) is clear and all details are correct. Registration will be unmodifiable afterwards without coordinator intervention.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _registerForEvent();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.event.name,
        showBackButton: true,
        showProfileButton: false,
      ),
      body: _isLoadingUsers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Info Card
                  Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryBlue.withOpacity(0.1),
                                  AppTheme.secondaryPurple.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.event,
                                      color: AppTheme.primaryBlue,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Event Details",
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppTheme.primaryBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  context,
                                  Icons.people,
                                  "Team Size",
                                  "${widget.event.minTeamSize} - ${widget.event.maxTeamSize} members",
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  context,
                                  Icons.currency_rupee,
                                  "Registration Fee",
                                  "₹${widget.event.fee} (non-IIESTians)",
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Team/Individual Name Section
                        _buildSectionHeader(
                          context,
                          widget.event.maxTeamSize == 1 ? "Participant Details" : "Team Details",
                          Icons.edit,
                        ),
                        const SizedBox(height: 12),
                        MyTextField(
                          controller: _teamNameController,
                          labelText: "Team Name",
                          hintText: "Enter your team name",
                        ),
                        const SizedBox(height: 24),
                        // Will you bring your own controller? question
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "Will you bring your own controller?",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool?>(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                                // dense: true,
                                visualDensity: const VisualDensity(horizontal: -4.0),
                                value: true,
                                groupValue: _bringingOwnController,
                                title: const Text('Yes'),
                                onChanged: (val) {
                                  setState(() { _bringingOwnController = val; });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool?>(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                                // dense: true,
                                visualDensity: const VisualDensity(horizontal: -4.0),
                                value: false,
                                groupValue: _bringingOwnController,
                                title: const Text('No'),
                                onChanged: (val) {
                                  setState(() { _bringingOwnController = val; });
                                },
                              ),
                            ),
                          ],
                        ),

                        // Team Members Section (only if maxTeamSize > 1)
                        if (widget.event.maxTeamSize > 1) ...[
                          _buildSectionHeader(
                            context,
                            "Team Members (${_selectedMembers.length}/${widget.event.maxTeamSize - 1})",
                            Icons.group_add,
                          ),
                          const SizedBox(height: 12),

                          // Add Member Button
                          if (_selectedMembers.length < widget.event.maxTeamSize - 1)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showSearch = !_showSearch;
                                    if (!_showSearch) {
                                      _searchController.clear();
                                      _filteredUsers = [];
                                    }
                                  });
                                },
                                icon: Icon(_showSearch ? Icons.close : Icons.person_add),
                                label: Text(_showSearch ? "Cancel" : "Add Team Member"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _showSearch 
                                      ? Colors.grey.withOpacity(0.1)
                                      : AppTheme.primaryBlue.withOpacity(0.1),
                                  foregroundColor: _showSearch 
                                      ? Theme.of(context).textTheme.bodyMedium?.color
                                      : AppTheme.primaryBlue,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                          // Search Section
                          if (_showSearch) ...[
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Search Team Members",
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    MyTextField(
                                      controller: _searchController,
                                      labelText: "Search Members",
                                      hintText: "Type name or phone number...",
                                      onChanged: _searchUsers,
                                      suffixIcon: _searchController.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.clear),
                                              onPressed: () {
                                                setState(() {
                                                  _searchController.clear();
                                                  _filteredUsers = [];
                                                });
                                              },
                                            )
                                          : const Icon(Icons.search),
                                    ),
                                    
                                    // Search Results
                                    if (_filteredUsers.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Text(
                                        "Search Results",
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        constraints: const BoxConstraints(maxHeight: 300),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _filteredUsers.length,
                                          itemBuilder: (context, index) {
                                            final user = _filteredUsers[index];
                                            return Column(
                                              children: [
                                                ListTile(
                                                  contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: 16, vertical: 8
                                                  ),
                                                  leading: CircleAvatar(
                                                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                                                    child: Text(
                                                      user['name'][0].toUpperCase(),
                                                      style: TextStyle(
                                                        color: AppTheme.primaryBlue,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    user['name'],
                                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                                  ),
                                                  subtitle: Text(
                                                    "${user['collegeName']} • ${user['department']}\n${user['phone']}",
                                                    style: Theme.of(context).textTheme.bodySmall,
                                                  ),
                                                  isThreeLine: true,
                                                  onTap: () => _addMember(user),
                                                  trailing: Icon(
                                                    Icons.add_circle_outline, 
                                                    color: AppTheme.primaryBlue,
                                                  ),
                                                ),
                                                if (index < _filteredUsers.length - 1)
                                                  Divider(
                                                    height: 1,
                                                    thickness: 0.5,
                                                    color: Colors.grey.shade400,
                                                    indent: 16,
                                                    endIndent: 16,
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ] else if (_searchController.text.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.search_off,
                                              color: Colors.grey.shade400,
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "No members found",
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "1. Ask them to complete their profile\n2. IIESTians need to upload their IDs",
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Selected Members Section
                          if (_selectedMembers.isNotEmpty) ...[
                            // Text(
                            //   "Added Team Members",
                            //   style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            //     fontWeight: FontWeight.w600,
                            //     color: AppTheme.primaryBlue,
                            //   ),
                            // ),
                            const SizedBox(height: 12),
                            ..._selectedMembers.asMap().entries.map((entry) {
                              final index = entry.key;
                              final member = entry.value;
                              return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: CircleAvatar(
                                      backgroundColor: AppTheme.secondaryPurple.withOpacity(0.1),
                                      child: Text(
                                        member['name'][0].toUpperCase(),
                                        style: TextStyle(
                                          color: AppTheme.secondaryPurple,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      member['name'],
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      "${member['collegeName']} • ${member['department']}\n${member['phone']}",
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                      onPressed: () => _removeMember(index),
                                      tooltip: "Remove member",
                                    ),
                                  ),
                                );
                            }).toList(),
                            const SizedBox(height: 16),
                          ],
                        ],
                        const SizedBox(height: 32),
                        // UPI QR Code
                        _buildSectionHeader(
                          context,
                          "Payment Details",
                          Icons.payment,
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/upi_qr.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Payment Screenshot upload (for non-IIESTIAN payments)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Upload Payment Screenshot:",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    onPressed: (_selectedPaymentSSFile != null || _isUploadingPaymentSS)
                                        ? () => displayMessageToUser("Please remove the existing payment screenshot before uploading a new one.", context)
                                        : () => _pickPaymentImage(ImageSource.gallery),
                                    icon: const Icon(Icons.upload_file, color: AppTheme.primaryBlue, size: 24.0),
                                  ),
                                  const Text('or'),
                                  IconButton(
                                    onPressed: (_selectedPaymentSSFile != null || _isUploadingPaymentSS)
                                        ? () => displayMessageToUser("Please remove the existing payment screenshot before uploading a new one.", context)
                                        : () => _pickPaymentImage(ImageSource.camera),
                                    icon: Icon(Icons.camera_alt_outlined, color: AppTheme.primaryBlue, size: 24.0),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildPaymentSSPreview(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        // Register Button at bottom of content
                        const SizedBox(height: 32),
                        _isRegistering
                            ? Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Registering...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : MyButton(
                                text: 'Register for Event',
                                onTap: _onRegisterPressed,
                              ),
                        // const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // ID card preview and upload removed from this page; handled in profile_page.dart

  Widget _buildPaymentSSPreview() {
    final double previewHeight = 150;
    if (_selectedPaymentSSFile != null) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedPaymentSSFile!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Positioned(
            right: 6,
            top: 6,
            child: IconButton(
                    onPressed: () {
                      setState(() { _selectedPaymentSSFile = null; });
                    },
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

    // Only local selection is supported in this page; no existing remote URL

    return Container(
      height: previewHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text('No payment screenshot uploaded', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
      ),
    );
  }


  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryBlue,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.primaryBlue,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}