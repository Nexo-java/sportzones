/// Sport venue model
class SportModel {
  final String id;
  final String name;
  final String description;
  final String type;
  final String? imageUrl;
  final double pricePerHour;
  final String location;

  SportModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.imageUrl,
    required this.pricePerHour,
    required this.location,
  });

  factory SportModel.fromJson(Map<String, dynamic> json) {
    return SportModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      imageUrl: json['image_url'],
      pricePerHour: (json['price_per_hour'] ?? 0).toDouble(),
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'image_url': imageUrl,
      'price_per_hour': pricePerHour,
      'location': location,
    };
  }
}
