// Los distintos motivos por los que un dueño puede estar en PawMatch.
// Un perro puede tener varios a la vez (ej: busca compañero de paseo Y cría).
enum MatchPurpose {
  walkingBuddy,
  playdates,
  breeding;

  String get label {
    switch (this) {
      case MatchPurpose.walkingBuddy:
        return 'Walking buddy';
      case MatchPurpose.playdates:
        return 'Playdates';
      case MatchPurpose.breeding:
        return 'Breeding';
    }
  }

  // Para guardar/leer en Firestore como texto plano
  String get storageKey => name;

  static MatchPurpose fromStorageKey(String key) {
    return MatchPurpose.values.firstWhere(
      (p) => p.storageKey == key,
      orElse: () => MatchPurpose.walkingBuddy,
    );
  }
}

// PawMatch es una app de citas para perros Y personas — esto matiza qué
// tipo de conexión busca el DUEÑO, por encima de lo que busca el perro.
// "Playdates"/"Breeding" son casi siempre puramente caninos; "Walking
// buddy" es el terreno ambiguo — puede ser solo un paseo compartido o una
// cita disimulada con el perro de excusa. Este campo quita la ambigüedad.
enum OwnerIntent {
  datingToo,
  dogsOnly;

  String get label {
    switch (this) {
      case OwnerIntent.datingToo:
        return 'Open to dating too';
      case OwnerIntent.dogsOnly:
        return 'Here for the dogs only';
    }
  }

  String get emoji => this == OwnerIntent.datingToo ? '💕' : '🐾';

  String get storageKey => name;

  static OwnerIntent fromStorageKey(String key) {
    return OwnerIntent.values.firstWhere(
      (i) => i.storageKey == key,
      orElse: () => OwnerIntent.dogsOnly,
    );
  }
}

class Dog {
  final String id;
  final String name;
  final String breed;
  final int ageInMonths;
  final String photoUrl;
  final String description;

  // Qué busca este perfil (puede ser más de uno)
  final List<MatchPurpose> purposes;

  // Rasgos cortos tipo "Energetic", "Good with kids" — dan personalidad
  // al perfil de un vistazo, antes de leer la descripción completa.
  final List<String> personalityTags;

  // Distancia al usuario actual — puramente de exhibición hasta que haya
  // geolocalización real.
  final double distanceKm;

  // Datos del DUEÑO — antes solo teníamos "ownerName", ahora el dueño
  // tiene presencia propia, porque el objetivo también es que se
  // conozcan las personas, no solo los perros.
  final String ownerName;
  final String ownerPhotoUrl;
  final String ownerBio;

  // Aficiones del DUEÑO — "Hiking", "Coffee"... complementan ownerBio para
  // que, si el owner busca algo más que un paseo, el otro lado tenga de
  // qué hablar más allá del perro.
  final List<String> ownerInterests;

  // Qué busca el DUEÑO, no el perro — ver OwnerIntent arriba.
  final OwnerIntent ownerIntent;

  Dog({
    required this.id,
    required this.name,
    required this.breed,
    required this.ageInMonths,
    required this.photoUrl,
    required this.description,
    required this.purposes,
    required this.ownerName,
    this.personalityTags = const [],
    this.distanceKm = 0,
    this.ownerPhotoUrl = '',
    this.ownerBio = '',
    this.ownerInterests = const [],
    this.ownerIntent = OwnerIntent.dogsOnly,
  });

  bool get isLookingForWalkingBuddy => purposes.contains(MatchPurpose.walkingBuddy);
  bool get isLookingForPlaydates => purposes.contains(MatchPurpose.playdates);
  bool get isLookingForBreeding => purposes.contains(MatchPurpose.breeding);

  /// Puntuación de compatibilidad puramente de exhibición — más motivos y
  /// rasgos en común suben el número. Estable entre builds (determinista
  /// por par de ids) para que no cambie cada vez que se repinta la tarjeta.
  int compatibilityWith(Dog other) {
    var score = 55;
    score += purposes.where(other.purposes.contains).length * 12;
    score += personalityTags.where(other.personalityTags.contains).length * 8;
    if (breed == other.breed) score += 5;
    score += (id.hashCode ^ other.id.hashCode).abs() % 7;
    return score.clamp(55, 99);
  }

  Dog copyWith({String? description, OwnerIntent? ownerIntent}) {
    return Dog(
      id: id,
      name: name,
      breed: breed,
      ageInMonths: ageInMonths,
      photoUrl: photoUrl,
      description: description ?? this.description,
      purposes: purposes,
      personalityTags: personalityTags,
      distanceKm: distanceKm,
      ownerName: ownerName,
      ownerPhotoUrl: ownerPhotoUrl,
      ownerBio: ownerBio,
      ownerIntent: ownerIntent ?? this.ownerIntent,
    );
  }

  factory Dog.fromMap(Map<String, dynamic> map, String documentId) {
    final purposesList = (map['purposes'] as List<dynamic>?) ?? [];
    final tagsList = (map['personalityTags'] as List<dynamic>?) ?? [];
    final interestsList = (map['ownerInterests'] as List<dynamic>?) ?? [];

    return Dog(
      id: documentId,
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      ageInMonths: map['ageInMonths'] ?? 0,
      photoUrl: map['photoUrl'] ?? '',
      description: map['description'] ?? '',
      purposes: purposesList.map((p) => MatchPurpose.fromStorageKey(p as String)).toList(),
      personalityTags: tagsList.map((t) => t as String).toList(),
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
      ownerName: map['ownerName'] ?? '',
      ownerPhotoUrl: map['ownerPhotoUrl'] ?? '',
      ownerBio: map['ownerBio'] ?? '',
      ownerInterests: interestsList.map((t) => t as String).toList(),
      ownerIntent: OwnerIntent.fromStorageKey(map['ownerIntent'] ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'breed': breed,
      'ageInMonths': ageInMonths,
      'photoUrl': photoUrl,
      'description': description,
      'purposes': purposes.map((p) => p.storageKey).toList(),
      'personalityTags': personalityTags,
      'distanceKm': distanceKm,
      'ownerName': ownerName,
      'ownerPhotoUrl': ownerPhotoUrl,
      'ownerBio': ownerBio,
      'ownerInterests': ownerInterests,
      'ownerIntent': ownerIntent.storageKey,
    };
  }
}