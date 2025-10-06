class Event {
  final String id;
  final String category;
  final String name;
  final String image;
  final String description;
  final int minTeamSize;
  final int maxTeamSize;
  final int fee;

  Event({
    required this.id,
    required this.category,
    required this.name,
    required this.image,
    required this.description,
    required this.minTeamSize,
    required this.maxTeamSize,
    this.fee = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "category": category,
      "name": name,
      "image": image,
      "description": description,
      "minTeamSize": minTeamSize,
      "maxTeamSize": maxTeamSize,
      "fee": fee,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map["id"] ?? "",
      category: map["category"] ?? "",
      name: map["name"] ?? "",
      image: map["image"] ?? "",
      description: map["description"] ?? "",
      minTeamSize: map["minTeamSize"] ?? 1,
      maxTeamSize: map["maxTeamSize"] ?? 1,
      fee: map["fee"] ?? 0,
    );
  }
}
