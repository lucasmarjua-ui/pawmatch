class Dog {
  final String id;
  final String name;
  final String breed;
  final int ageInMonths;
  final String ownerName;
  final String photoUrl;
  final String description;

  Dog({
    required this.id,
    required this.name,
    required this.breed,
    required this.ageInMonths,
    required this.ownerName,
    required this.photoUrl,
    required this.description,
  });

  // Convierte un documento de Firestore en un objeto Dog
  factory Dog.fromMap(Map<String, dynamic> map, String documentId) {
    return Dog(
      id: documentId,
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      ageInMonths: map['ageInMonths'] ?? 0,
      ownerName: map['ownerName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      description: map['description'] ?? '',
    );
  }

  // Convierte un objeto Dog en un mapa para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'breed': breed,
      'ageInMonths': ageInMonths,
      'ownerName': ownerName,
      'photoUrl': photoUrl,
      'description': description,
    };
  }
}