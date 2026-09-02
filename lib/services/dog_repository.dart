import '../models/dog_model.dart';

/// Contrato para obtener perros. Hoy lo implementa MockDogRepository con
/// datos en memoria; cuando conectemos Firestore, una FirestoreDogRepository
/// implementa este mismo contrato y el resto de la app no cambia.
abstract class DogRepository {
  Future<List<Dog>> fetchDiscoverableDogs();
  Future<Dog?> fetchDogById(String id);
  Future<Dog> fetchCurrentUserDog();
}

class MockDogRepository implements DogRepository {
  final Dog _myDog = Dog(
    id: 'me-1',
    name: 'Rocky',
    breed: 'Golden Retriever',
    ageInMonths: 24,
    photoUrl: 'https://placedog.net/500/700?id=1',
    description: 'Friendly and playful, loves long walks by the river and '
        'chasing tennis balls until his legs give out. Still working on '
        'not jumping on visitors — we\'re getting there.',
    purposes: const [MatchPurpose.walkingBuddy, MatchPurpose.breeding],
    personalityTags: const ['Energetic', 'Good with kids', 'Loves water'],
    ownerName: 'Lucas',
    ownerPhotoUrl: 'https://i.pravatar.cc/300?img=12',
    ownerBio: 'Weekend hiker, always up for a new trail with Rocky — and open to company on it.',
    ownerIntent: OwnerIntent.datingToo,
  );

  final List<Dog> _discoverable = [
    Dog(
      id: '2',
      name: 'Luna',
      breed: 'Border Collie',
      ageInMonths: 18,
      photoUrl: 'https://placedog.net/500/700?id=2',
      description: 'Very energetic, great with other dogs, and always up '
          'for a game of fetch. Needs a job to do or she\'ll invent one — '
          'usually herding the cat.',
      purposes: const [MatchPurpose.walkingBuddy, MatchPurpose.playdates],
      personalityTags: const ['Energetic', 'Smart', 'Herder'],
      distanceKm: 0.8,
      ownerName: 'Ana',
      ownerPhotoUrl: 'https://i.pravatar.cc/300?img=47',
      ownerBio: 'Runs the local dog park meetups every Sunday.',
      ownerIntent: OwnerIntent.datingToo,
    ),
    Dog(
      id: '3',
      name: 'Bruno',
      breed: 'Labrador',
      ageInMonths: 36,
      photoUrl: 'https://placedog.net/500/700?id=3',
      description: 'Calm and gentle, good with kids and other dogs. The '
          'unofficial mayor of the block — everyone on the street knows '
          'his name before they know mine.',
      purposes: const [MatchPurpose.walkingBuddy],
      personalityTags: const ['Calm', 'Good with kids', 'Foodie'],
      distanceKm: 1.4,
      ownerName: 'Tom',
      ownerPhotoUrl: 'https://i.pravatar.cc/300?img=53',
      ownerBio: "Works from home, so Bruno's never short of walks. Happily married — just here for the dog friends.",
      ownerIntent: OwnerIntent.dogsOnly,
    ),
    Dog(
      id: '4',
      name: 'Maple',
      breed: 'Cocker Spaniel',
      ageInMonths: 30,
      photoUrl: 'https://placedog.net/500/700?id=4',
      description: 'Sweet-natured, looking for a playdate buddy in the '
          'park. Loves belly rubs more than food, which is really saying '
          'something.',
      purposes: const [MatchPurpose.playdates, MatchPurpose.breeding],
      personalityTags: const ['Affectionate', 'Gentle', 'Cuddly'],
      distanceKm: 2.1,
      ownerName: 'Sofia',
      ownerPhotoUrl: 'https://i.pravatar.cc/300?img=32',
      ownerBio: 'First-time dog owner, learning the ropes with Maple.',
      ownerIntent: OwnerIntent.dogsOnly,
    ),
    Dog(
      id: '5',
      name: 'Zeus',
      breed: 'Siberian Husky',
      ageInMonths: 27,
      photoUrl: 'https://placedog.net/500/700?id=5',
      description: 'Talks back — a lot. If you\'re after a dog with an '
          'opinion on everything and enough energy for two marathons a '
          'day, Zeus is your guy.',
      purposes: const [MatchPurpose.walkingBuddy, MatchPurpose.playdates],
      personalityTags: const ['Vocal', 'Energetic', 'Escape artist'],
      distanceKm: 3.6,
      ownerName: 'Marta',
      ownerPhotoUrl: 'https://i.pravatar.cc/300?img=25',
      ownerBio: 'Runner — Zeus is training for his first 10K with me. Wouldn\'t mind a running partner either.',
      ownerIntent: OwnerIntent.datingToo,
    ),
    Dog(
      id: '6',
      name: 'Coco',
      breed: 'French Bulldog',
      ageInMonths: 14,
      photoUrl: 'https://placedog.net/500/700?id=6',
      description: 'Short walks, long naps, and an unmatched talent for '
          'snoring. Looking for playdates that don\'t involve too much '
          'running — she gets the point across in five minutes flat.',
      purposes: const [MatchPurpose.playdates],
      personalityTags: const ['Lazy', 'Affectionate', 'Snorty'],
      distanceKm: 0.5,
      ownerName: 'Diego',
      ownerPhotoUrl: 'https://i.pravatar.cc/300?img=15',
      ownerBio: 'Coco is basically a small, loud roommate at this point.',
      ownerIntent: OwnerIntent.dogsOnly,
    ),
    Dog(
      id: '7',
      name: 'Nala',
      breed: 'German Shepherd',
      ageInMonths: 42,
      photoUrl: 'https://placedog.net/500/700?id=7',
      description: 'Protective, loyal, and surprisingly gentle once she '
          'warms up. Retired from search-and-rescue training — now just '
          'looking for good company on long walks.',
      purposes: const [MatchPurpose.walkingBuddy, MatchPurpose.breeding],
      personalityTags: const ['Loyal', 'Well-trained', 'Protective'],
      distanceKm: 4.2,
      ownerName: 'Priya',
      ownerPhotoUrl: 'https://i.pravatar.cc/300?img=44',
      ownerBio: "Former handler — Nala's manners are impeccable.",
      ownerIntent: OwnerIntent.dogsOnly,
    ),
    Dog(
      id: '8',
      name: 'Biscuit',
      breed: 'Beagle',
      ageInMonths: 20,
      photoUrl: 'https://placedog.net/500/700?id=8',
      description: 'Nose to the ground, always. Biscuit has never met a '
          'smell he didn\'t want to investigate for exactly twelve minutes.',
      purposes: const [MatchPurpose.walkingBuddy, MatchPurpose.playdates],
      personalityTags: const ['Curious', 'Foodie', 'Stubborn'],
      distanceKm: 1.9,
      ownerName: 'Elena',
      ownerPhotoUrl: 'https://i.pravatar.cc/300?img=36',
      ownerBio: 'Elena and Biscuit take the scenic (slow) route everywhere.',
      ownerIntent: OwnerIntent.datingToo,
    ),
  ];

  @override
  Future<List<Dog>> fetchDiscoverableDogs() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_discoverable);
  }

  @override
  Future<Dog> fetchCurrentUserDog() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _myDog;
  }

  @override
  Future<Dog?> fetchDogById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final all = [_myDog, ..._discoverable];
    for (final dog in all) {
      if (dog.id == id) return dog;
    }
    return null;
  }
}
