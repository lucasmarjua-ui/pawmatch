import 'package:flutter_test/flutter_test.dart';
import 'package:pawmatch/models/dog_model.dart';
import 'package:pawmatch/providers/dog_provider.dart';
import 'package:pawmatch/services/dog_repository.dart';

void main() {
  group('DogProvider', () {
    test('loadInitialData populates the discover queue and myDog', () async {
      final provider = DogProvider(MockDogRepository());

      await provider.loadInitialData();

      expect(provider.myDog, isNotNull);
      expect(provider.discoverQueue, isNotEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('setMyDog sets myDog directly', () {
      final provider = DogProvider(MockDogRepository());
      final dog = Dog(
        id: 'me-1',
        name: 'Nala',
        breed: 'Poodle',
        ageInMonths: 12,
        photoUrl: '',
        description: '',
        purposes: const [MatchPurpose.playdates],
        ownerName: 'Sam',
      );

      provider.setMyDog(dog);

      expect(provider.myDog, same(dog));
    });

    test('loadInitialData does not overwrite a myDog set by setMyDog', () async {
      final provider = DogProvider(MockDogRepository());
      final dog = Dog(
        id: 'me-1',
        name: 'Nala',
        breed: 'Poodle',
        ageInMonths: 12,
        photoUrl: '',
        description: '',
        purposes: const [MatchPurpose.playdates],
        ownerName: 'Sam',
      );
      provider.setMyDog(dog);

      await provider.loadInitialData();

      expect(provider.myDog, same(dog));
      expect(provider.discoverQueue, isNotEmpty);
    });

    test('loadInitialData only fetches once', () async {
      final repository = MockDogRepository();
      final provider = DogProvider(repository);

      await provider.loadInitialData();
      final idsAfterFirstLoad = provider.discoverQueue.map((d) => d.id).toList();
      await provider.loadInitialData();

      expect(provider.discoverQueue.map((d) => d.id).toList(), idsAfterFirstLoad);
    });

    test('swipe removes the current dog from the queue and returns it', () async {
      final provider = DogProvider(MockDogRepository());
      await provider.loadInitialData();

      final queueLength = provider.discoverQueue.length;
      final firstDog = provider.currentDiscoverDog;
      final swiped = provider.swipe(liked: true);

      expect(swiped, same(firstDog));
      expect(provider.discoverQueue.length, queueLength - 1);
      expect(provider.currentDiscoverDog, isNot(same(firstDog)));
    });

    test('swipe on an empty queue returns null and does not throw', () {
      final provider = DogProvider(MockDogRepository());

      expect(provider.swipe(liked: true), isNull);
    });

    test('rewind brings back the last swiped dog', () async {
      final provider = DogProvider(MockDogRepository());
      await provider.loadInitialData();

      final queueLength = provider.discoverQueue.length;
      final swiped = provider.swipe(liked: false);
      expect(provider.canRewind, isTrue);

      provider.rewind();

      expect(provider.canRewind, isFalse);
      expect(provider.discoverQueue.length, queueLength);
      expect(provider.currentDiscoverDog, same(swiped));
    });

    test('rewind on empty history is a no-op', () {
      final provider = DogProvider(MockDogRepository());

      expect(() => provider.rewind(), returnsNormally);
      expect(provider.canRewind, isFalse);
    });

    test('applyFilters narrows the discover queue by purpose and distance', () async {
      final provider = DogProvider(MockDogRepository());
      await provider.loadInitialData();

      provider.applyFilters(purposes: {MatchPurpose.breeding}, maxDistanceKm: null);
      expect(provider.discoverQueue, isNotEmpty);
      expect(provider.discoverQueue.every((d) => d.isLookingForBreeding), isTrue);

      provider.applyFilters(purposes: {}, maxDistanceKm: 0.1);
      expect(provider.discoverQueue, isEmpty);

      provider.applyFilters(purposes: {}, maxDistanceKm: null);
      expect(provider.discoverQueue, isNotEmpty);
    });

    test('applyFilters narrows the discover queue by owner intent', () async {
      final provider = DogProvider(MockDogRepository());
      await provider.loadInitialData();

      provider.applyFilters(purposes: {}, maxDistanceKm: null, intent: OwnerIntent.datingToo);
      expect(provider.discoverQueue, isNotEmpty);
      expect(provider.discoverQueue.every((d) => d.ownerIntent == OwnerIntent.datingToo), isTrue);

      provider.applyFilters(purposes: {}, maxDistanceKm: null, intent: OwnerIntent.dogsOnly);
      expect(provider.discoverQueue.every((d) => d.ownerIntent == OwnerIntent.dogsOnly), isTrue);
    });

    test('updateMyDogOwnerIntent updates only the owner intent', () async {
      final provider = DogProvider(MockDogRepository());
      await provider.loadInitialData();
      final originalName = provider.myDog!.name;

      provider.updateMyDogOwnerIntent(OwnerIntent.dogsOnly);

      expect(provider.myDog!.ownerIntent, OwnerIntent.dogsOnly);
      expect(provider.myDog!.name, originalName);
    });

    test('updateMyDogDescription updates only the description', () async {
      final provider = DogProvider(MockDogRepository());
      await provider.loadInitialData();
      final originalName = provider.myDog!.name;

      provider.updateMyDogDescription('New bio.');

      expect(provider.myDog!.description, 'New bio.');
      expect(provider.myDog!.name, originalName);
    });

    test('updateMyDogDescription is a no-op before myDog is loaded', () {
      final provider = DogProvider(MockDogRepository());

      expect(() => provider.updateMyDogDescription('New bio.'), returnsNormally);
      expect(provider.myDog, isNull);
    });

    test('reset clears loaded state so data can be reloaded', () async {
      final provider = DogProvider(MockDogRepository());
      await provider.loadInitialData();

      provider.reset();

      expect(provider.myDog, isNull);
      expect(provider.discoverQueue, isEmpty);

      await provider.loadInitialData();
      expect(provider.myDog, isNotNull);
    });
  });
}
