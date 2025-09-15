// lib/contact_info.dart

class ContactInfo {
  final String name;
  final String role;
  final String phone;

  ContactInfo({
    required this.name,
    required this.role,
    required this.phone,
  });
}

/// Core team contacts (hardcoded for now)
final List<ContactInfo> coreTeamContacts = [
  ContactInfo(
    name: "Ajeet Kumar",
    role: "Fest Coordinator",
    phone: "+919161705253",
  ),
  ContactInfo(
    name: "Rohit Mehta",
    role: "Technical Head",
    phone: "+919123456780",
  ),
  ContactInfo(
    name: "Sneha Das",
    role: "Robotics Head",
    phone: "+919988776655",
  ),
  ContactInfo(
    name: "Arjun Verma",
    role: "Gaming Head",
    phone: "+919012345678",
  ),
  // ➕ add more here (40+ people if needed)
];
