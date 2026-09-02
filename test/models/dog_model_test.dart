import 'package:flutter_test/flutter_test.dart';
import 'package:pawmatch/models/dog_model.dart';

void main() {
  group('MatchPurpose', () {
    test('fromStorageKey round-trips a valid key', () {
      expect(MatchPurpose.fromStorageKey('breeding'), MatchPurpose.breeding);
    });

    test('fromStorageKey falls back to walkingBuddy for an unknown key', () {
      expect(MatchPurpose.fromStorageKey('unknown'), MatchPurpose.walkingBuddy);
    });
  });

  group('OwnerIntent', () {
    test('fromStorageKey round-trips a valid key', () {
      expect(OwnerIntent.fromStorageKey('datingToo'), OwnerIntent.datingToo);
    });

    test('fromStorageKey falls back to dogsOnly for an unknown key', () {
      expect(OwnerIntent.fromStorageKey('unknown'), OwnerIntent.dogsOnly);
    });

    test('Dog defaults to dogsOnly when not specified', () {
      final dog = Dog(
        id: 'd5',
        name: 'Buddy',
        breed: 'Mixed',
        ageInMonths: 12,
        photoUrl: '',
        description: '',
        purposes: const [MatchPurpose.walkingBuddy],
        ownerName: 'Sam',
      );

      expect(dog.ownerIntent, OwnerIntent.dogsOnly);
    });
  });

  group('Dog', () {
    test('toMap/fromMap round-trips all fields', () {
      final dog = Dog(
        id: 'd1',
        name: 'Rocky',
        breed: 'Golden Retriever',
        ageInMonths: 24,
        photoUrl: 'https://example.com/rocky.jpg',
        description: 'Friendly.',
        purposes: const [MatchPurpose.walkingBuddy, MatchPurpose.breeding],
        personalityTags: const ['Energetic', 'Good with kids'],
        distanceKm: 1.5,
        ownerName: 'Lucas',
        ownerPhotoUrl: 'https://example.com/lucas.jpg',
        ownerBio: 'Dog lover.',
        ownerIntent: OwnerIntent.datingToo,
      );

      final rebuilt = Dog.fromMap(dog.toMap(), dog.id);

      expect(rebuilt.id, dog.id);
      expect(rebuilt.name, dog.name);
      expect(rebuilt.breed, dog.breed);
      expect(rebuilt.ageInMonths, dog.ageInMonths);
      expect(rebuilt.photoUrl, dog.photoUrl);
      expect(rebuilt.description, dog.description);
      expect(rebuilt.purposes, dog.purposes);
      expect(rebuilt.personalityTags, dog.personalityTags);
      expect(rebuilt.distanceKm, dog.distanceKm);
      expect(rebuilt.ownerName, dog.ownerName);
      expect(rebuilt.ownerPhotoUrl, dog.ownerPhotoUrl);
      expect(rebuilt.ownerBio, dog.ownerBio);
      expect(rebuilt.ownerIntent, dog.ownerIntent);
    });

    test('copyWith replaces only the description', () {
      final dog = Dog(
        id: 'd4',
        name: 'Rocky',
        breed: 'Golden Retriever',
        ageInMonths: 24,
        photoUrl: 'https://example.com/rocky.jpg',
        description: 'Old bio.',
        purposes: const [MatchPurpose.walkingBuddy],
        ownerName: 'Lucas',
      );

      final updated = dog.copyWith(description: 'New bio.');

      expect(updated.description, 'New bio.');
      expect(updated.id, dog.id);
      expect(updated.name, dog.name);
      expect(updated.purposes, dog.purposes);
    });

    test('fromMap fills in defaults for missing fields', () {
      final dog = Dog.fromMap(const {}, 'd2');

      expect(dog.name, '');
      expect(dog.ageInMonths, 0);
      expect(dog.purposes, isEmpty);
    });

    test('isLookingFor* reflects the purposes list', () {
      final dog = Dog(
        id: 'd3',
        name: 'Luna',
        breed: 'Border Collie',
        ageInMonths: 18,
        photoUrl: '',
        description: '',
        purposes: const [MatchPurpose.playdates],
        ownerName: 'Ana',
      );

      expect(dog.isLookingForPlaydates, isTrue);
      expect(dog.isLookingForWalkingBuddy, isFalse);
      expect(dog.isLookingForBreeding, isFalse);
    });
  });
}
