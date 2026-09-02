import '../models/chat_message_model.dart';
import '../models/dog_model.dart';
import '../models/match_conversation_model.dart';

/// Contrato para conversaciones y mensajes. Hoy lo implementa
/// MockMatchRepository con datos en memoria; cuando conectemos Firestore,
/// una FirestoreMatchRepository implementa este mismo contrato.
abstract class MatchRepository {
  Future<List<MatchConversation>> fetchConversations();
  Future<List<ChatMessage>> fetchMessages(String conversationId);
  Future<void> sendMessage(String conversationId, String text);
}

class MockMatchRepository implements MatchRepository {
  final List<MatchConversation> _conversations = [
    const MatchConversation(
      id: 'c1',
      dogName: 'Luna',
      ownerName: 'Ana',
      lastMessage: 'Hey! Would love to set up a playdate',
      timeAgo: '2m',
      unread: true,
      matchedOn: MatchPurpose.playdates,
      photoUrl: 'https://placedog.net/500/700?id=2',
    ),
    const MatchConversation(
      id: 'c2',
      dogName: 'Bruno',
      ownerName: 'Tom',
      lastMessage: 'Sounds good, see you Saturday',
      timeAgo: '1h',
      unread: false,
      matchedOn: MatchPurpose.walkingBuddy,
      photoUrl: 'https://placedog.net/500/700?id=3',
    ),
    const MatchConversation(
      id: 'c3',
      dogName: 'Maple',
      ownerName: 'Sofia',
      lastMessage: "Maple says hi 🐶 can't wait to meet Rocky!",
      timeAgo: '3h',
      unread: false,
      matchedOn: MatchPurpose.breeding,
      photoUrl: 'https://placedog.net/500/700?id=4',
    ),
    const MatchConversation(
      id: 'c4',
      dogName: 'Zeus',
      ownerName: 'Marta',
      lastMessage: 'Zeus is still talking about that walk 😂',
      timeAgo: '1d',
      unread: false,
      matchedOn: MatchPurpose.walkingBuddy,
      photoUrl: 'https://placedog.net/500/700?id=5',
    ),
  ];

  final Map<String, List<ChatMessage>> _messages = {
    'c1': [
      const ChatMessage(text: 'Hey! Would love to set up a playdate 🐾', isMe: false, time: '9:12 AM'),
      const ChatMessage(text: 'That sounds great! Rocky loves the park near the river', isMe: true, time: '9:14 AM'),
      const ChatMessage(text: 'Perfect, how about Saturday morning?', isMe: false, time: '9:15 AM'),
    ],
    'c2': [
      const ChatMessage(text: 'Hey Lucas! Bruno and Rocky seem like a good match', isMe: false, time: 'Yesterday'),
      const ChatMessage(text: 'Agreed! Same park as always?', isMe: true, time: 'Yesterday'),
      const ChatMessage(text: 'Works for me — 10am?', isMe: false, time: 'Yesterday'),
      const ChatMessage(text: 'Sounds good, see you Saturday', isMe: false, time: '1h'),
    ],
    'c3': [
      const ChatMessage(text: 'Hi! Maple and Rocky matched on breeding — excited to chat', isMe: false, time: 'Mon'),
      const ChatMessage(text: 'Same here! Rocky is up to date on all his health checks', isMe: true, time: 'Mon'),
      const ChatMessage(text: "Maple says hi 🐶 can't wait to meet Rocky!", isMe: false, time: '3h'),
    ],
    'c4': [
      const ChatMessage(text: "Zeus needs a running partner and Rocky's profile said he loves long walks!", isMe: false, time: '2d'),
      const ChatMessage(text: "Ha, he'll need to keep up with a husky though", isMe: true, time: '2d'),
      const ChatMessage(text: "He'll manage 😄 Sunday morning?", isMe: false, time: '2d'),
      const ChatMessage(text: 'Zeus is still talking about that walk 😂', isMe: false, time: '1d'),
    ],
  };

  @override
  Future<List<MatchConversation>> fetchConversations() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return List.unmodifiable(_conversations);
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_messages[conversationId] ?? const []);
  }

  @override
  Future<void> sendMessage(String conversationId, String text) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _messages.putIfAbsent(conversationId, () => []).add(
          ChatMessage(text: text, isMe: true, time: 'Now'),
        );
  }
}
