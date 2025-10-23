// lib/contact_info.dart
class ContactInfo {
  final String name;
  final String role;
  final String phone;
  final String section;

  ContactInfo({
    required this.name,
    required this.role,
    required this.phone,
    required this.section,
  });
}

// Main Coordinator
// Joint Coordinator
// Finance
// Sponsorship
// Event
// Robodarshan
// Travel and Logistics
// Web Development
// App Development
// Design and Content
// Publicity
// Volunteer

/// Core team contacts (hardcoded for now)
final List<ContactInfo> coreTeamContacts = [
  ContactInfo(
    name: "Ayush Tejaswi",
    role: "Main Coordinator",
    phone: "8368033554",
    section: "Main Coordinator"
  ),
  ContactInfo(
    name: "Aaratrika Sarkar ",
    role: "Main Coordinator",
    phone: "9481961973",
    section: "Main Coordinator"
  ),
  ContactInfo(
    name: "Satish Gupta",
    role: "Main Coordinator",
    phone: "6291290730",
    section: "Main Coordinator"
  ),
  //
  ContactInfo(
    name: "Harshit Kumar",
    role: "Head",
    phone: "8809932888",
    section: "App Development"
  ),
  ContactInfo(
    name: "Subhranil Nandy",
    role: "Head",
    phone: "9123771737",
    section: "App Development"
  ),
  //
  ContactInfo(
    name: "Pranjal Diwakar",
    role: "Head",
    phone: "8355087594",
    section: "Joint Coordinator"
  ),
  ContactInfo(
    name: "Sohom Chakraborty",
    role: "Head",
    phone: "9331809512",
    section: "Joint Coordinator"
  ),
  //
  ContactInfo(
    name: "Arman Choudhary",
    role: "Head",
    phone: "9667251975",
    section: "Finance"
  ),
  ContactInfo(
    name: "Saurav Kumar",
    role: "Head",
    phone: "",
    section: "Finance"
  ),
  ContactInfo(
    name: "Shreyansh Srivastva",
    role: "Head",
    phone: "",
    section: "Finance"
  ),
  ContactInfo(
    name: "Ayush Ranjan",
    role: "Executive",
    phone: "",
    section: "Finance"
  ),
  //

];
