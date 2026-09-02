import 'package:flutter/foundation.dart';
import '../models/dog_model.dart';
import '../services/dog_repository.dart';

class DogProvider extends ChangeNotifier {
  DogProvider(this._repository);

  final DogRepository _repository;

  // Lista completa tal como llega del repositorio — nunca se muta. La cola
  // visible (discoverQueue) se deriva de esta más los ids ya vistos y los
  // filtros activos, así que "rewind" solo tiene que olvidar un id.
  List<Dog> _allDogs = [];
  final Set<String> _seenIds = {};
  final List<String> _swipeHistory = [];

  Set<MatchPurpose> _purposeFilters = {};
  double? _maxDistanceKm;
  OwnerIntent? _intentFilter;

  Dog? _myDog;
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<Dog> get discoverQueue => _allDogs.where((dog) {
        if (_seenIds.contains(dog.id)) return false;
        if (_purposeFilters.isNotEmpty && !dog.purposes.any(_purposeFilters.contains)) return false;
        if (_maxDistanceKm != null && dog.distanceKm > _maxDistanceKm!) return false;
        if (_intentFilter != null && dog.ownerIntent != _intentFilter) return false;
        return true;
      }).toList();

  Dog? get currentDiscoverDog {
    final queue = discoverQueue;
    return queue.isNotEmpty ? queue.first : null;
  }

  Dog? get myDog => _myDog;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get canRewind => _swipeHistory.isNotEmpty;
  Set<MatchPurpose> get purposeFilters => _purposeFilters;
  double? get maxDistanceKm => _maxDistanceKm;
  OwnerIntent? get intentFilter => _intentFilter;

  /// Si CreateProfileScreen ya llamó a setMyDog (cuenta nueva recién
  /// registrada), no lo pisa con el perro mock del repositorio — ese solo
  /// se usa para cuentas que inician sesión con un perfil "ya existente".
  Future<void> loadInitialData() async {
    if (_hasLoaded || _isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final dogs = await _repository.fetchDiscoverableDogs();
      _allDogs = dogs;
      _myDog ??= await _repository.fetchCurrentUserDog();
      _hasLoaded = true;
    } catch (e) {
      _errorMessage = 'Could not load dogs. Try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fija el perro del usuario a partir de lo introducido en
  /// CreateProfileScreen — el equivalente mock de crear el documento en
  /// Firestore la primera vez que alguien completa su perfil.
  void setMyDog(Dog dog) {
    _myDog = dog;
    notifyListeners();
  }

  /// Marca al perro actual como visto y lo devuelve. El llamador decide
  /// qué hacer con un "like" (hoy: MatchProvider.addMockMatch crea la
  /// conversación — cuando haya backend real, aquí se guardaría el like
  /// y el match dependería de que el otro dueño también dé like).
  Dog? swipe({required bool liked}) {
    final swiped = currentDiscoverDog;
    if (swiped == null) return null;
    _seenIds.add(swiped.id);
    _swipeHistory.add(swiped.id);
    notifyListeners();
    return swiped;
  }

  /// Deshace el último swipe, sea like o pass — el perro vuelve al frente
  /// de la cola. Si el swipe deshecho fue un like que ya generó match, ese
  /// match se queda tal cual (igual que el resto del comportamiento mock,
  /// no intenta simular retirar un like ya "enviado").
  void rewind() {
    if (_swipeHistory.isEmpty) return;
    final lastId = _swipeHistory.removeLast();
    _seenIds.remove(lastId);
    notifyListeners();
  }

  /// Aplica los filtros del bottom sheet de Discover. `purposes` vacío
  /// significa "todos"; `maxDistanceKm`/`intent` nulos significan "sin
  /// límite" / "cualquiera".
  void applyFilters({required Set<MatchPurpose> purposes, required double? maxDistanceKm, OwnerIntent? intent}) {
    _purposeFilters = purposes;
    _maxDistanceKm = maxDistanceKm;
    _intentFilter = intent;
    notifyListeners();
  }

  /// Edita la descripción del perro del usuario actual. Mock local — con
  /// backend real esto persistiría el cambio en Firestore.
  void updateMyDogDescription(String description) {
    if (_myDog == null) return;
    _myDog = _myDog!.copyWith(description: description);
    notifyListeners();
  }

  /// Cambia qué busca el DUEÑO (no el perro) — ver OwnerIntent.
  void updateMyDogOwnerIntent(OwnerIntent intent) {
    if (_myDog == null) return;
    _myDog = _myDog!.copyWith(ownerIntent: intent);
    notifyListeners();
  }

  /// Se llama al cerrar sesión, para que el próximo usuario no vea datos
  /// del anterior mientras carga los suyos.
  void reset() {
    _allDogs = [];
    _seenIds.clear();
    _swipeHistory.clear();
    _purposeFilters = {};
    _maxDistanceKm = null;
    _intentFilter = null;
    _myDog = null;
    _hasLoaded = false;
    _errorMessage = null;
    notifyListeners();
  }
}
