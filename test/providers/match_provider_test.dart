import 'package:flutter_test/flutter_test.dart';
import 'package:pawmatch/models/dog_model.dart';
import 'package:pawmatch/providers/match_provider.dart';
import 'package:pawmatch/services/match_repository.dart';

Dog _buildDog({required String id, required List<MatchPurpose> purposes}) {
  return Dog(
    id: id,
    name: 'Buddy',
    breed: 'Mixed',
    ageInMonths: 12,
    photoUrl: '',
    description: '',
    purposes: purposes,
    ownerName: 'Sam',
  );
}

void main() {
  group('MatchProvider', () {
    test('loadConversations populates the conversation list', () async {
      final provider = MatchProvider(MockMatchRepository());

      await provider.loadConversations();

      expect(provider.conversations, isNotEmpty);
      expect(provider.isLoading, isFalse);
    });

    test('sendMessage appends an optimistic message immediately', () async {
      final provider = MatchProvider(MockMatchRepository());
      await provider.loadConversations();
      final conversationId = provider.conversations.first.id;
      await provider.loadMessages(conversationId);
      final before = provider.messagesFor(conversationId).length;

      final future = provider.sendMessage(conversationId, 'Hello!');

      expect(provider.messagesFor(conversationId).length, before + 1);
      expect(provider.messagesFor(conversationId).last.text, 'Hello!');
      await future;
    });

    test('sendMessage ignores blank text', () async {
      final provider = MatchProvider(MockMatchRepository());
      await provider.loadConversations();
      final conversationId = provider.conversations.first.id;
      await provider.loadMessages(conversationId);
      final before = provider.messagesFor(conversationId).length;

      await provider.sendMessage(conversationId, '   ');

      expect(provider.messagesFor(conversationId).length, before);
    });

    test('addMockMatch prepends a new conversation matched on a shared purpose', () {
      final provider = MatchProvider(MockMatchRepository());
      final myDog = _buildDog(id: 'me', purposes: const [MatchPurpose.playdates, MatchPurpose.breeding]);
      final theirDog = _buildDog(id: 'them', purposes: const [MatchPurpose.walkingBuddy, MatchPurpose.breeding]);

      final conversation = provider.addMockMatch(theirDog, myDog: myDog);

      expect(provider.conversations.first.id, conversation.id);
      expect(conversation.dogName, theirDog.name);
      expect(conversation.matchedOn, MatchPurpose.breeding);
      expect(provider.messagesFor(conversation.id), isEmpty);
    });

    test('addMockMatch falls back to the dog\'s first purpose with no overlap', () {
      final provider = MatchProvider(MockMatchRepository());
      final myDog = _buildDog(id: 'me', purposes: const [MatchPurpose.breeding]);
      final theirDog = _buildDog(id: 'them', purposes: const [MatchPurpose.walkingBuddy]);

      final conversation = provider.addMockMatch(theirDog, myDog: myDog);

      expect(conversation.matchedOn, MatchPurpose.walkingBuddy);
    });

    test('removeConversation drops the conversation and its messages', () async {
      final provider = MatchProvider(MockMatchRepository());
      await provider.loadConversations();
      final conversationId = provider.conversations.first.id;
      await provider.loadMessages(conversationId);

      provider.removeConversation(conversationId);

      expect(provider.conversations.any((c) => c.id == conversationId), isFalse);
      expect(provider.messagesFor(conversationId), isEmpty);
    });
  });
}
