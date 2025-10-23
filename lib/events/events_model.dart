class Coordinator {
  final String name;
  final String phone;

  Coordinator({
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
    };
  }

  factory Coordinator.fromMap(Map<String, dynamic> map) {
    return Coordinator(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}

class Event {
  final String id;
  final String category;
  final String name;
  final String image;
  final String description;
  final String rules;
  final int minTeamSize;
  final int maxTeamSize;
  final int iiestFee;
  final int fee;
  final List<Coordinator> coordinators;
  final Map<String, int> prizePool; // keys: "first", "second", "third", ...
  final String gform; // Google Form link

  Event({
    required this.id,
    required this.category,
    required this.name,
    required this.image,
    required this.description,
    required this.rules,
    required this.minTeamSize,
    required this.maxTeamSize,
    this.iiestFee = 0,
    this.fee = 0,
    required this.coordinators,
    required this.prizePool,
    required this.gform, // add here
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'image': image,
      'description': description,
      'rules': rules,
      'minTeamSize': minTeamSize,
      'maxTeamSize': maxTeamSize,
      'fee': fee,
      'iiestFee': iiestFee,
      'coordinators': coordinators.map((c) => c.toMap()).toList(),
      'prizePool': prizePool,
      'gform': gform, // add here
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      rules: map['rules'] ?? '',
      minTeamSize: map['minTeamSize'] ?? 1,
      maxTeamSize: map['maxTeamSize'] ?? 1,
    iiestFee: map['iiestFee'] ?? 0,
    fee: map['fee'] ?? 0,
      coordinators: (map['coordinators'] as List?)
              ?.map((c) => Coordinator.fromMap(c))
              .toList() ??
          [],
      prizePool: Map<String, int>.from(map['prizePool'] ?? {}),
      gform: map['gform'] ?? '', // add here
    );
  }
}
