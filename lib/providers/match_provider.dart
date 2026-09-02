import 'package:flutter/foundation.dart';
import '../models/chat_message_model.dart';
import '../models/dog_model.dart';
import '../models/match_conversation_model.dart';
import '../services/match_repository.dart';

class MatchProvider extends ChangeNotifier {
  MatchProvider(this._repository);

  final MatchRepository _repository;

  List<MatchConversation> _conversations = [];
  final Map<String, List<ChatMessage>> _messagesByConversation = {};
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<MatchConversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadConversations() async {
    if (_hasLoaded || _isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _conversations = await _repository.fetchConversations();
      _hasLoaded = true;
    } catch (e) {
      _errorMessage = 'Could not load your matches. Try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crea una conversación de match nueva a partir de un perro al que se
  /// le dio like. Mock local — cuando haya backend real, esto lo dispararía
  /// un listener sobre la colección de matches de Firestore.
  MatchConversation addMockMatch(Dog dog, {Dog? myDog}) {
    final conversation = MatchConversation(
      id: 'match-${dog.id}-${DateTime.now().millisecondsSinceEpoch}',
      dogName: dog.name,
      ownerName: dog.ownerName,
      lastMessage: "You matched! Say hi 👋",
      timeAgo: 'Now',
      unread: false,
      matchedOn: _sharedPurpose(dog, myDog),
      photoUrl: dog.photoUrl,
    );
    _conversations = [conversation, ..._conversations];
    _messagesByConversation[conversation.id] = [];
    notifyListeners();
    return conversation;
  }

  MatchPurpose _sharedPurpose(Dog dog, Dog? myDog) {
    if (myDog != null) {
      for (final purpose in dog.purposes) {
        if (myDog.purposes.contains(purpose)) return purpose;
      }
    }
    return dog.purposes.isNotEmpty ? dog.purposes.first : MatchPurpose.walkingBuddy;
  }

  List<ChatMessage> messagesFor(String conversationId) => _messagesByConversation[conversationId] ?? const [];

  Future<void> loadMessages(String conversationId) async {
    if (_messagesByConversation.containsKey(conversationId)) return;
    final messages = await _repository.fetchMessages(conversationId);
    // El repositorio devuelve una lista inmutable — la copiamos a una lista
    // normal porque sendMessage() necesita poder añadirle elementos.
    _messagesByConversation[conversationId] = List<ChatMessage>.of(messages);
    notifyListeners();
  }

  Future<void> sendMessage(String conversationId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final optimistic = ChatMessage(text: trimmed, isMe: true, time: 'Now');
    _messagesByConversation.putIfAbsent(conversationId, () => []).add(optimistic);
    notifyListeners();
    await _repository.sendMessage(conversationId, trimmed);
  }

  /// Quita una conversación — usado por "Unmatch" y "Block" en el chat.
  /// Ambos tienen el mismo efecto en este mock; con backend real, block
  /// además impediría que ese dueño vuelva a aparecer en Discover.
  void removeConversation(String conversationId) {
    _conversations = _conversations.where((c) => c.id != conversationId).toList();
    _messagesByConversation.remove(conversationId);
    notifyListeners();
  }

  /// Se llama al cerrar sesión, para que el próximo usuario no vea datos
  /// del anterior mientras carga los suyos.
  void reset() {
    _conversations = [];
    _messagesByConversation.clear();
    _hasLoaded = false;
    _errorMessage = null;
    notifyListeners();
  }
}
