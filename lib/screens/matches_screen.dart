import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/dog_model.dart';
import '../models/match_conversation_model.dart';
import '../providers/match_provider.dart';
import '../theme/paw_colors.dart';
import '../widgets/network_photo.dart';
import '../widgets/paw_loading_indicator.dart';
import 'chat_screen.dart';

typedef _FontFn = TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color});

class _PurposeStyle {
  final IconData icon;
  final Color fg;
  const _PurposeStyle({required this.icon, required this.fg});
}

const Map<MatchPurpose, _PurposeStyle> _purposeStyles = {
  MatchPurpose.walkingBuddy: _PurposeStyle(icon: Icons.directions_walk, fg: Color(0xFF3B6D11)),
  MatchPurpose.playdates: _PurposeStyle(icon: Icons.sports_baseball_outlined, fg: Color(0xFF185FA5)),
  MatchPurpose.breeding: _PurposeStyle(icon: Icons.favorite_border, fg: Color(0xFF993556)),
};

class MatchesScreen extends StatelessWidget {
  final VoidCallback? onStartSwiping;

  const MatchesScreen({super.key, this.onStartSwiping});

  @override
  Widget build(BuildContext context) {
    final displayFont = GoogleFonts.fraunces;
    final bodyFont = GoogleFonts.manrope;
    final matchProvider = context.watch<MatchProvider>();
    final conversations = matchProvider.conversations;
    final unreadCount = conversations.where((c) => c.unread).length;

    return Scaffold(
      backgroundColor: PawColors.cream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Matches', style: displayFont(fontSize: 22, fontWeight: FontWeight.w600, color: PawColors.pine)),
                  const SizedBox(height: 2),
                  Text(
                    unreadCount > 0 ? '$unreadCount new ${unreadCount == 1 ? "message" : "messages"}' : 'All caught up',
                    style: bodyFont(fontSize: 13, color: PawColors.charcoal.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),

            if (conversations.isNotEmpty)
              SizedBox(
                height: 112,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  itemCount: conversations.length,
                  itemBuilder: (context, i) {
                    final c = conversations[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 56, height: 56,
                            padding: EdgeInsets.all(c.unread ? 2 : 0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: c.unread ? Border.all(color: PawColors.mustard, width: 2) : null,
                              boxShadow: [BoxShadow(color: PawColors.charcoal.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 3))],
                            ),
                            child: ClipOval(child: NetworkPhoto(url: c.photoUrl)),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 56,
                            child: Text(
                              c.dogName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: bodyFont(fontSize: 11, color: PawColors.charcoal.withValues(alpha: 0.7)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            if (conversations.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 4),
                child: Text('MESSAGES', style: bodyFont(fontSize: 11, fontWeight: FontWeight.w800, color: PawColors.charcoal.withValues(alpha: 0.5)).copyWith(letterSpacing: 1.2)),
              ),

            Expanded(
              child: _buildList(context, matchProvider, conversations, bodyFont),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, MatchProvider matchProvider, List<MatchConversation> conversations, _FontFn bodyFont) {
    if (matchProvider.isLoading && conversations.isEmpty) {
      return const Center(child: PawLoadingIndicator());
    }
    if (matchProvider.errorMessage != null && conversations.isEmpty) {
      return _ErrorState(message: matchProvider.errorMessage!, bodyFont: bodyFont);
    }
    if (conversations.isEmpty) {
      return _EmptyState(bodyFont: bodyFont, onStartSwiping: onStartSwiping);
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: conversations.length,
      itemBuilder: (context, i) {
        final c = conversations[i];
        return _ConversationTile(
          conversation: c,
          bodyFont: bodyFont,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => ChatScreen(conversationId: c.id, dogName: c.dogName, ownerName: c.ownerName, photoUrl: c.photoUrl),
            ));
          },
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final MatchConversation conversation;
  final VoidCallback onTap;
  final _FontFn bodyFont;

  const _ConversationTile({required this.conversation, required this.onTap, required this.bodyFont});

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final purposeStyle = _purposeStyles[c.matchedOn]!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: PawColors.charcoal.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: NetworkPhoto(url: c.photoUrl, borderRadius: BorderRadius.circular(16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${c.dogName} & ${c.ownerName}', style: bodyFont(fontSize: 14, fontWeight: FontWeight.w600, color: PawColors.pine)),
                      Text(c.timeAgo, style: bodyFont(fontSize: 11, color: c.unread ? PawColors.mustard : PawColors.charcoal.withValues(alpha: 0.4))),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Etiqueta del motivo del match — pequeña, informativa,
                  // sin competir visualmente con el último mensaje
                  Row(
                    children: [
                      Icon(purposeStyle.icon, size: 12, color: purposeStyle.fg),
                      const SizedBox(width: 4),
                      Text(c.matchedOn.label, style: bodyFont(fontSize: 11, fontWeight: FontWeight.w600, color: purposeStyle.fg)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    c.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: bodyFont(fontSize: 13, color: c.unread ? PawColors.charcoal.withValues(alpha: 0.75) : PawColors.charcoal.withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ),
            if (c.unread) ...[
              const SizedBox(width: 8),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: PawColors.mustard, shape: BoxShape.circle)),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final _FontFn bodyFont;
  final VoidCallback? onStartSwiping;
  const _EmptyState({required this.bodyFont, this.onStartSwiping});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border, size: 40, color: PawColors.sage),
          const SizedBox(height: 12),
          Text('No matches yet', style: bodyFont(fontSize: 15, fontWeight: FontWeight.w600, color: PawColors.pine)),
          const SizedBox(height: 4),
          Text('Keep swiping to find one', style: bodyFont(fontSize: 13, color: PawColors.charcoal.withValues(alpha: 0.5))),
          if (onStartSwiping != null) ...[
            const SizedBox(height: 20),
            TextButton(
              onPressed: onStartSwiping,
              style: TextButton.styleFrom(foregroundColor: PawColors.pine),
              child: Text('Start swiping', style: bodyFont(fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final _FontFn bodyFont;
  const _ErrorState({required this.message, required this.bodyFont});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 40, color: PawColors.sage),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: bodyFont(fontSize: 14, color: PawColors.charcoal.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}
