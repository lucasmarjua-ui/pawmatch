import 'dog_model.dart';

// Ahora una conversación de match sabe POR QUÉ se hizo match — puede
// haber sido por interés en pasear juntos, quedadas, o cría. Esto se
// muestra en la lista para que no haya ambigüedad sobre la intención.
class MatchConversation {
  final String id;
  final String dogName;
  final String ownerName;
  final String lastMessage;
  final String timeAgo;
  final bool unread;
  final MatchPurpose matchedOn;
  final String photoUrl;

  const MatchConversation({
    required this.id,
    required this.dogName,
    required this.ownerName,
    required this.lastMessage,
    required this.timeAgo,
    required this.unread,
    required this.matchedOn,
    this.photoUrl = '',
  });
}
