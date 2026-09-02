import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/chat_message_model.dart';
import '../providers/match_provider.dart';
import '../theme/paw_colors.dart';
import '../widgets/network_photo.dart';

typedef _FontFn = TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color});

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String dogName;
  final String ownerName;
  final String photoUrl;

  const ChatScreen({super.key, required this.conversationId, required this.dogName, required this.ownerName, this.photoUrl = ''});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final textController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MatchProvider>().loadMessages(widget.conversationId);
    });
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? text]) {
    final message = text ?? textController.text;
    if (message.trim().isEmpty) return;

    context.read<MatchProvider>().sendMessage(widget.conversationId, message);
    textController.clear();

    // Auto-scroll al final tras enviar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<String> get _icebreakers => [
        'Would love to set up a playdate with ${widget.dogName}! 🎾',
        "What's ${widget.dogName}'s favorite walk spot? 📍",
        '${widget.dogName} has such a great profile! 🐾',
      ];

  Future<void> _confirmAndRemove({required String title, required String message, required String confirmLabel, required String snackbarMessage}) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: PawColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title, style: GoogleFonts.fraunces(fontWeight: FontWeight.w600, color: PawColors.pine)),
        content: Text(message, style: GoogleFonts.manrope(fontSize: 13.5, color: PawColors.charcoal.withValues(alpha: 0.7))),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text('Cancel', style: GoogleFonts.manrope(color: PawColors.charcoal.withValues(alpha: 0.6)))),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(confirmLabel, style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: PawColors.danger))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    context.read<MatchProvider>().removeConversation(widget.conversationId);
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(snackbarMessage),
        backgroundColor: PawColors.pine,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _report() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: PawColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Report ${widget.ownerName}?', style: GoogleFonts.fraunces(fontWeight: FontWeight.w600, color: PawColors.pine)),
        content: Text("We'll review this conversation and take action if needed.", style: GoogleFonts.manrope(fontSize: 13.5, color: PawColors.charcoal.withValues(alpha: 0.7))),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text('Cancel', style: GoogleFonts.manrope(color: PawColors.charcoal.withValues(alpha: 0.6)))),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('🐾 Report submitted — thanks for flagging this'),
                  backgroundColor: PawColors.pine,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Text('Report', style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: PawColors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyFont = GoogleFonts.manrope;
    final messages = context.watch<MatchProvider>().messagesFor(widget.conversationId);

    return Scaffold(
      backgroundColor: PawColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: PawColors.borderMuted, width: 0.5))),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: PawColors.pine),
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(width: 40, height: 40, child: NetworkPhoto(url: widget.photoUrl)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${widget.dogName} & ${widget.ownerName}', style: bodyFont(fontSize: 14, fontWeight: FontWeight.w600, color: PawColors.pine)),
                        Text('Active now', style: bodyFont(fontSize: 11, color: PawColors.success)),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: PawColors.charcoal.withValues(alpha: 0.5), size: 20),
                    tooltip: 'More options',
                    onSelected: (value) {
                      if (value == 'report') _report();
                      if (value == 'unmatch') {
                        _confirmAndRemove(
                          title: 'Unmatch with ${widget.ownerName}?',
                          message: "You'll no longer be able to message each other.",
                          confirmLabel: 'Unmatch',
                          snackbarMessage: '🐾 Unmatched with ${widget.ownerName}',
                        );
                      }
                      if (value == 'block') {
                        _confirmAndRemove(
                          title: 'Block ${widget.ownerName}?',
                          message: "They won't be able to see your profile or message you again.",
                          confirmLabel: 'Block',
                          snackbarMessage: '🐾 Blocked ${widget.ownerName}',
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'report', child: Text('Report')),
                      const PopupMenuItem(value: 'unmatch', child: Text('Unmatch')),
                      const PopupMenuItem(value: 'block', child: Text('Block')),
                    ],
                  ),
                ],
              ),
            ),

            // Mensajes
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        "Say hi to ${widget.dogName}'s owner!",
                        style: bodyFont(fontSize: 13, color: PawColors.charcoal.withValues(alpha: 0.4)),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(18),
                      itemCount: messages.length,
                      itemBuilder: (context, i) => _MessageBubble(message: messages[i], bodyFont: bodyFont),
                    ),
            ),

            // Sugerencias para romper el hielo — solo antes del primer
            // mensaje, para no estorbar una conversación ya empezada
            if (messages.isEmpty)
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _icebreakers.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => ActionChip(
                    label: Text(_icebreakers[i], style: bodyFont(fontSize: 12, fontWeight: FontWeight.w600, color: PawColors.pine)),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: PawColors.sage.withValues(alpha: 0.5)),
                    onPressed: () => _sendMessage(_icebreakers[i]),
                  ),
                ),
              ),

            // Campo de envío
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: PawColors.sage.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(999)),
                      child: TextField(
                        controller: textController,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: bodyFont(fontSize: 13, color: PawColors.charcoal.withValues(alpha: 0.3)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Semantics(
                    button: true,
                    label: 'Send message',
                    child: GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 44, height: 44,
                        decoration: const BoxDecoration(color: PawColors.mustard, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_upward, color: PawColors.pine, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final _FontFn bodyFont;

  const _MessageBubble({required this.message, required this.bodyFont});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? PawColors.pine : Colors.white,
              border: isMe ? null : Border.all(color: PawColors.borderMuted),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
            ),
            child: Text(
              message.text,
              style: bodyFont(fontSize: 14, color: isMe ? Colors.white : PawColors.charcoal).copyWith(height: 1.4),
            ),
          ),
          const SizedBox(height: 3),
          Padding(
            padding: EdgeInsets.only(left: isMe ? 0 : 6, right: isMe ? 6 : 0),
            child: Text(message.time, style: bodyFont(fontSize: 10, color: PawColors.charcoal.withValues(alpha: 0.35))),
          ),
        ],
      ),
    );
  }
}
