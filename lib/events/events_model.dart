class Event {
  final String id;
  final String category;
  final String name;
  final String image;
  final String description;
  final String rules;
  final int minTeamSize;
  final int maxTeamSize;
  final int fee;
  final String coordinator;
  final String phone;

  Event({
    required this.id,
    required this.category,
    required this.name,
    required this.image,
    required this.description,
    required this.rules,
    required this.minTeamSize,
    required this.maxTeamSize,
    this.fee = 0,
    required this.coordinator,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "category": category,
      "name": name,
      "image": image,
      "description": description,
      "rules": rules,
      "minTeamSize": minTeamSize,
      "maxTeamSize": maxTeamSize,
      "fee": fee,
      "coordinator": coordinator,
      "phone": phone,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map["id"] ?? "",
      category: map["category"] ?? "",
      name: map["name"] ?? "",
      image: map["image"] ?? "",
      description: map["description"] ?? "",
      rules: map["rules"] ?? "",
      minTeamSize: map["minTeamSize"] ?? 1,
      maxTeamSize: map["maxTeamSize"] ?? 1,
      fee: map["fee"] ?? 0,
      coordinator: map["coordinator"] ?? "",
      phone: map["phone"] ?? "",
    );
  }
}
