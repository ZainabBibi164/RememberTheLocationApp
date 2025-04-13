class LocationNote {
  final int? id;
  final int userId;
  final String name;
  final String description;
  final String? imagePath;

  LocationNote({
    this.id,
    required this.userId,
    required this.name,
    required this.description,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,//
      'userId': userId,
      'name': name,
      'description': description,
      'imagePath': imagePath,
    };
  }
}