import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/dog_model.dart';
import '../providers/dog_provider.dart';
import '../providers/match_provider.dart';
import '../theme/paw_colors.dart';
import '../widgets/network_photo.dart';
import '../widgets/paw_loading_indicator.dart';
import '../widgets/paw_print_painter.dart';
import 'chat_screen.dart';

typedef _FontFn = TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color});

class _PurposeStyle {
  final IconData icon;
  const _PurposeStyle({required this.icon});
}

const Map<MatchPurpose, _PurposeStyle> _purposeStyles = {
  MatchPurpose.walkingBuddy: _PurposeStyle(icon: Icons.directions_walk),
  MatchPurpose.playdates: _PurposeStyle(icon: Icons.sports_baseball_outlined),
  MatchPurpose.breeding: _PurposeStyle(icon: Icons.favorite_border),
};

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  Offset dragOffset = Offset.zero;

  void _onPanUpdate(DragUpdateDetails details) => setState(() => dragOffset += details.delta);

  void _onPanEnd(DragEndDetails details) {
    const threshold = 100;
    if (dragOffset.dx > threshold) {
      _swipe(liked: true);
    } else if (dragOffset.dx < -threshold) {
      _swipe(liked: false);
    } else {
      setState(() => dragOffset = Offset.zero);
    }
  }

  void _swipe({required bool liked}) {
    final dogProvider = context.read<DogProvider>();
    final swiped = dogProvider.swipe(liked: liked);
    setState(() => dragOffset = Offset.zero);

    // Mock: todo like sobre un candidato de la cola de descubrimiento
    // resulta en match — son perfiles ya pre-filtrados. Con backend real,
    // esto dependería de que el otro dueño también diera like.
    if (liked && swiped != null) {
      final conversation = context.read<MatchProvider>().addMockMatch(swiped, myDog: dogProvider.myDog);
      _showMatchDialog(swiped, conversation.id);
    }
  }

  void _showMatchDialog(Dog dog, String conversationId) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (dialogContext, animation, secondaryAnimation) => _MatchDialog(
        dog: dog,
        onSendMessage: () {
          Navigator.of(dialogContext).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(conversationId: conversationId, dogName: dog.name, ownerName: dog.ownerName, photoUrl: dog.photoUrl),
            ),
          );
        },
        onKeepSwiping: () => Navigator.of(dialogContext).pop(),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween(begin: 0.7, end: 1.0).animate(curved),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  void _openFilters(BuildContext context) {
    final dogProvider = context.read<DogProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        initialPurposes: dogProvider.purposeFilters,
        initialMaxDistanceKm: dogProvider.maxDistanceKm,
        initialIntent: dogProvider.intentFilter,
        onApply: (purposes, maxDistanceKm, intent) => dogProvider.applyFilters(purposes: purposes, maxDistanceKm: maxDistanceKm, intent: intent),
      ),
    );
  }

  void _openLikesYouTeaser(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, animation, secondaryAnimation) => const _LikesYouTeaser(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return ScaleTransition(scale: Tween(begin: 0.7, end: 1.0).animate(curved), child: FadeTransition(opacity: animation, child: child));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayFont = GoogleFonts.fraunces;
    final bodyFont = GoogleFonts.manrope;
    final dogProvider = context.watch<DogProvider>();
    final queue = dogProvider.discoverQueue;
    final rotation = dragOffset.dx / 300;
    final hasFilters = dogProvider.purposeFilters.isNotEmpty || dogProvider.maxDistanceKm != null || dogProvider.intentFilter != null;

    return Scaffold(
      backgroundColor: PawColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomPaint(size: const Size(20, 20), painter: PawPrintPainter(color: PawColors.pine)),
                      const SizedBox(width: 8),
                      Text('Pawmatch', style: displayFont(fontSize: 17, fontWeight: FontWeight.w600, color: PawColors.pine)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _openFilters(context),
                    child: Semantics(
                      button: true,
                      label: 'Filters',
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: hasFilters ? PawColors.pine : const Color(0xFFEFE6D6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.tune, size: 16, color: hasFilters ? PawColors.mustard : PawColors.pine),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: _LikesYouBanner(onTap: () => _openLikesYouTeaser(context)),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: _buildBody(dogProvider, queue, bodyFont, displayFont, rotation),
              ),
            ),

            if (queue.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionButton(
                      icon: Icons.replay,
                      bg: Colors.white,
                      iconColor: dogProvider.canRewind ? const Color(0xFFD9A441) : PawColors.charcoal.withValues(alpha: 0.2),
                      size: 42,
                      label: 'Rewind',
                      onTap: dogProvider.canRewind ? () => dogProvider.rewind() : null,
                    ),
                    const SizedBox(width: 14),
                    _ActionButton(icon: Icons.close, bg: Colors.white, iconColor: PawColors.charcoal.withValues(alpha: 0.4), label: 'Pass', onTap: () => _swipe(liked: false)),
                    const SizedBox(width: 14),
                    _ActionButton(icon: Icons.star, bg: PawColors.pine, iconColor: PawColors.mustard, size: 46, label: 'Super like', onTap: () => _swipe(liked: true)),
                    const SizedBox(width: 14),
                    _ActionButton(icon: Icons.favorite, bg: PawColors.mustard, iconColor: PawColors.pine, label: 'Like', onTap: () => _swipe(liked: true)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(DogProvider dogProvider, List<Dog> queue, _FontFn bodyFont, _FontFn displayFont, double rotation) {
    if (dogProvider.isLoading && queue.isEmpty) {
      return const Center(child: PawLoadingIndicator());
    }
    if (dogProvider.errorMessage != null && queue.isEmpty) {
      return _ErrorState(message: dogProvider.errorMessage!, bodyFont: bodyFont);
    }
    if (queue.isEmpty) {
      return _EmptyState(bodyFont: bodyFont);
    }

    final myDog = dogProvider.myDog;
    final stack = queue.take(3).toList();

    return Stack(
      alignment: Alignment.center,
      children: [
        for (var i = stack.length - 1; i >= 1; i--)
          Transform.translate(
            offset: Offset(0, 10.0 * i),
            child: Transform.scale(
              scale: 1 - (0.045 * i),
              child: IgnorePointer(
                child: _DogSwipeCard(
                  dog: stack[i],
                  displayFont: displayFont,
                  bodyFont: bodyFont,
                  dragDx: 0,
                  interactive: false,
                  compatibility: myDog?.compatibilityWith(stack[i]),
                ),
              ),
            ),
          ),
        GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Transform.translate(
            offset: dragOffset,
            child: Transform.rotate(
              angle: rotation,
              child: _DogSwipeCard(
                dog: stack.first,
                displayFont: displayFont,
                bodyFont: bodyFont,
                dragDx: dragOffset.dx,
                compatibility: myDog?.compatibilityWith(stack.first),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DogSwipeCard extends StatelessWidget {
  final Dog dog;
  final double dragDx;
  final _FontFn displayFont;
  final _FontFn bodyFont;
  final int? compatibility;
  final bool interactive;

  const _DogSwipeCard({
    required this.dog,
    required this.displayFont,
    required this.bodyFont,
    required this.dragDx,
    this.compatibility,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    final likeOpacity = interactive ? (dragDx / 120).clamp(0.0, 1.0) : 0.0;
    final passOpacity = interactive ? (-dragDx / 120).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: PawColors.charcoal.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
        fit: StackFit.expand,
        children: [
          NetworkPhoto(url: dog.photoUrl),

          // Badges de "busca..." — arriba a la izquierda, visibles antes
          // incluso de leer la descripción o dar swipe
          Positioned(
            top: 18, left: 18, right: 18,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    children: dog.purposes.map((p) => _PurposeChip(purpose: p, bodyFont: bodyFont)).toList(),
                  ),
                ),
                if (compatibility != null) _CompatibilityBadge(percent: compatibility!, bodyFont: bodyFont),
              ],
            ),
          ),

          Positioned(
            top: 60, left: 20,
            child: Opacity(opacity: likeOpacity, child: _SwipeStamp(text: 'LIKE', color: PawColors.pine, bodyFont: bodyFont)),
          ),
          Positioned(
            top: 60, right: 20,
            child: Opacity(opacity: passOpacity, child: _SwipeStamp(text: 'NOPE', color: Colors.grey.shade700, bodyFont: bodyFont)),
          ),

          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, PawColors.pine.withValues(alpha: 0.78)])),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(dog.name, style: displayFont(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(width: 8),
                      Text('${(dog.ageInMonths / 12).floor()} yrs', style: bodyFont(fontSize: 14, color: Colors.white.withValues(alpha: 0.85))),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dog.distanceKm > 0 ? '${dog.breed} · ${dog.distanceKm.toStringAsFixed(1)} km away' : dog.breed,
                    style: bodyFont(fontSize: 13, color: Colors.white.withValues(alpha: 0.85)),
                  ),

                  if (dog.personalityTags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: dog.personalityTags.map((tag) => _TraitChip(label: tag, bodyFont: bodyFont)).toList(),
                    ),
                  ],

                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 10),

                  // El dueño, presente también en la tarjeta de swipe — con
                  // su propia intención, no la del perro (ver OwnerIntent)
                  Row(
                    children: [
                      NetworkAvatar(url: dog.ownerPhotoUrl, radius: 12, fallbackInitial: dog.ownerName),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Owner: ${dog.ownerName}', style: bodyFont(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.9)))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(999)),
                        child: Text(
                          '${dog.ownerIntent.emoji} ${dog.ownerIntent == OwnerIntent.datingToo ? 'Open to dating' : 'Dogs only'}',
                          style: bodyFont(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

// Badge compacto para la tarjeta de swipe — versión reducida del
// _PurposeBadge de DogProfileScreen, pensado para caber varios en una fila
class _PurposeChip extends StatelessWidget {
  final MatchPurpose purpose;
  final _FontFn bodyFont;
  const _PurposeChip({required this.purpose, required this.bodyFont});

  @override
  Widget build(BuildContext context) {
    final style = _purposeStyles[purpose]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(purpose.label, style: bodyFont(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}

// Puntuación de compatibilidad tipo Hinge — refuerza que el match no es
// aleatorio, hay algo en común entre los dos perfiles.
class _CompatibilityBadge extends StatelessWidget {
  final int percent;
  final _FontFn bodyFont;
  const _CompatibilityBadge({required this.percent, required this.bodyFont});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: PawColors.mustard, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, size: 11, color: PawColors.pine),
          const SizedBox(width: 4),
          Text('$percent%', style: bodyFont(fontSize: 11, fontWeight: FontWeight.w800, color: PawColors.pine)),
        ],
      ),
    );
  }
}

// Rasgo de personalidad tipo "Energetic" / "Good with kids" — con borde en
// vez de relleno, para no competir visualmente con los _PurposeChip.
class _TraitChip extends StatelessWidget {
  final String label;
  final _FontFn bodyFont;
  const _TraitChip({required this.label, required this.bodyFont});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: 0.6)), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: bodyFont(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }
}

class _SwipeStamp extends StatelessWidget {
  final String text;
  final Color color;
  final _FontFn bodyFont;
  const _SwipeStamp({required this.text, required this.color, required this.bodyFont});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.25,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(border: Border.all(color: color, width: 3), borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: bodyFont(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color iconColor;
  final VoidCallback? onTap;
  final double size;
  final String label;
  const _ActionButton({required this.icon, required this.bg, required this.iconColor, required this.onTap, required this.label, this.size = 54});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: bg == Colors.white ? Border.all(color: PawColors.sage.withValues(alpha: 0.5)) : null),
          child: Icon(icon, color: iconColor, size: size * 0.4),
        ),
      ),
    );
  }
}

class _MatchDialog extends StatelessWidget {
  final Dog dog;
  final VoidCallback onSendMessage;
  final VoidCallback onKeepSwiping;

  const _MatchDialog({required this.dog, required this.onSendMessage, required this.onKeepSwiping});

  @override
  Widget build(BuildContext context) {
    final displayFont = GoogleFonts.fraunces;
    final bodyFont = GoogleFonts.manrope;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
        decoration: BoxDecoration(
          color: PawColors.cream,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 32, offset: const Offset(0, 12))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(size: const Size(48, 48), painter: PawPrintPainter(color: PawColors.mustard)),
            const SizedBox(height: 14),
            Text("It's a match!", style: displayFont(fontSize: 24, fontWeight: FontWeight.w600, color: PawColors.pine)),
            const SizedBox(height: 8),
            Text(
              'You and ${dog.ownerName} both liked ${dog.name}',
              textAlign: TextAlign.center,
              style: bodyFont(fontSize: 14, color: PawColors.charcoal.withValues(alpha: 0.65)),
            ),
            if (dog.ownerIntent == OwnerIntent.datingToo) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFBEAF0), borderRadius: BorderRadius.circular(999)),
                child: Text(
                  '💕 ${dog.ownerName} is open to more than a walk too',
                  style: bodyFont(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF993556)),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                boxShadow: [BoxShadow(color: PawColors.mustard.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: ElevatedButton(
                onPressed: onSendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PawColors.mustard,
                  foregroundColor: PawColors.pine,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                child: Text('Send a message', style: bodyFont(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onKeepSwiping,
              child: Text('Keep swiping', style: bodyFont(fontWeight: FontWeight.w600, color: PawColors.charcoal.withValues(alpha: 0.55))),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final _FontFn bodyFont;
  const _EmptyState({required this.bodyFont});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(size: const Size(48, 48), painter: PawPrintPainter(color: PawColors.sage)),
          const SizedBox(height: 16),
          Text('No more dogs nearby', style: bodyFont(fontSize: 16, fontWeight: FontWeight.w600, color: PawColors.pine)),
          const SizedBox(height: 4),
          Text('Check back later', style: bodyFont(fontSize: 13, color: PawColors.charcoal.withValues(alpha: 0.5))),
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

// Avatar "bloqueado" — foto real detrás de una capa oscura + candado, para
// insinuar contenido sin mostrarlo del todo (el gancho clásico del "quién
// te ha dado like" de las apps de citas de pago).
class _LockedAvatar extends StatelessWidget {
  final int placedogId;
  final double size;
  const _LockedAvatar({required this.placedogId, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: PawColors.cream, width: 2)),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetworkPhoto(url: 'https://placedog.net/150/150?id=$placedogId'),
            Container(color: Colors.black.withValues(alpha: 0.45)),
            Center(child: Icon(Icons.lock, size: size * 0.35, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// Banner que asoma sobre la cola de descubrimiento — el gancho de
// conversión más probado de las apps de citas: "alguien ya te dio like".
class _LikesYouBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _LikesYouBanner({required this.onTap});

  static const _likerPhotoIds = [9, 10, 11];

  @override
  Widget build(BuildContext context) {
    final bodyFont = GoogleFonts.manrope;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: PawColors.pine, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 32,
              child: Stack(
                children: [
                  for (var i = 0; i < _likerPhotoIds.length; i++)
                    Positioned(left: i * 16.0, child: _LockedAvatar(placedogId: _likerPhotoIds[i])),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${_likerPhotoIds.length} dogs already liked yours 🐾',
                style: bodyFont(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: Colors.white.withValues(alpha: 0.8)),
          ],
        ),
      ),
    );
  }
}

// Paywall de mentira — deja claro el modelo de negocio (freemium) sin
// fingir procesar un pago real.
class _LikesYouTeaser extends StatelessWidget {
  const _LikesYouTeaser();

  @override
  Widget build(BuildContext context) {
    final displayFont = GoogleFonts.fraunces;
    final bodyFont = GoogleFonts.manrope;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
        decoration: BoxDecoration(
          color: PawColors.cream,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 32, offset: const Offset(0, 12))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _LikesYouBanner._likerPhotoIds.length; i++)
                  Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 14),
                    child: _LockedAvatar(placedogId: _LikesYouBanner._likerPhotoIds[i], size: 64),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text('3 dogs already like Rocky', style: displayFont(fontSize: 22, fontWeight: FontWeight.w600, color: PawColors.pine), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Unlock PawMatch Plus to see who — and skip straight to matching.',
              textAlign: TextAlign.center,
              style: bodyFont(fontSize: 14, color: PawColors.charcoal.withValues(alpha: 0.65)),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                boxShadow: [BoxShadow(color: PawColors.mustard.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("🐾 PawMatch Plus isn't real yet — but now you've seen the pitch"),
                      backgroundColor: PawColors.pine,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PawColors.mustard,
                  foregroundColor: PawColors.pine,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                child: Text('Unlock PawMatch Plus', style: bodyFont(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Maybe later', style: bodyFont(fontWeight: FontWeight.w600, color: PawColors.charcoal.withValues(alpha: 0.55))),
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom sheet de filtros — motivo (walking/playdates/breeding) y
// distancia máxima. Aplica sobre DogProvider.discoverQueue vía
// DogProvider.applyFilters.
class _FilterSheet extends StatefulWidget {
  final Set<MatchPurpose> initialPurposes;
  final double? initialMaxDistanceKm;
  final OwnerIntent? initialIntent;
  final void Function(Set<MatchPurpose> purposes, double? maxDistanceKm, OwnerIntent? intent) onApply;

  const _FilterSheet({required this.initialPurposes, required this.initialMaxDistanceKm, required this.initialIntent, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<MatchPurpose> selectedPurposes = {...widget.initialPurposes};
  late double maxDistance = widget.initialMaxDistanceKm ?? 5.0;
  late bool anyDistance = widget.initialMaxDistanceKm == null;
  late OwnerIntent? selectedIntent = widget.initialIntent;

  @override
  Widget build(BuildContext context) {
    final displayFont = GoogleFonts.fraunces;
    final bodyFont = GoogleFonts.manrope;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
        decoration: const BoxDecoration(color: PawColors.cream, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: displayFont(fontSize: 19, fontWeight: FontWeight.w600, color: PawColors.pine)),
                TextButton(
                  onPressed: () => setState(() {
                    selectedPurposes = {};
                    anyDistance = true;
                    selectedIntent = null;
                  }),
                  child: Text('Reset', style: bodyFont(fontWeight: FontWeight.w700, color: PawColors.charcoal.withValues(alpha: 0.5))),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('LOOKING FOR', style: bodyFont(fontSize: 11, fontWeight: FontWeight.w800, color: PawColors.charcoal.withValues(alpha: 0.5)).copyWith(letterSpacing: 1.2)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MatchPurpose.values.map((purpose) {
                final selected = selectedPurposes.contains(purpose);
                return ChoiceChip(
                  label: Text(purpose.label),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    if (selected) {
                      selectedPurposes.remove(purpose);
                    } else {
                      selectedPurposes.add(purpose);
                    }
                  }),
                  selectedColor: PawColors.pine,
                  labelStyle: bodyFont(fontWeight: FontWeight.w600, color: selected ? Colors.white : PawColors.pine),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: PawColors.sage.withValues(alpha: 0.5)),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('MAX DISTANCE', style: bodyFont(fontSize: 11, fontWeight: FontWeight.w800, color: PawColors.charcoal.withValues(alpha: 0.5)).copyWith(letterSpacing: 1.2)),
                Text(anyDistance ? 'Any' : '${maxDistance.toStringAsFixed(1)} km', style: bodyFont(fontWeight: FontWeight.w700, color: PawColors.pine)),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(activeTrackColor: PawColors.mustard, thumbColor: PawColors.pine, inactiveTrackColor: PawColors.sage.withValues(alpha: 0.4)),
              child: Slider(
                value: maxDistance,
                min: 0.5,
                max: 5,
                divisions: 9,
                onChanged: (value) => setState(() {
                  maxDistance = value;
                  anyDistance = false;
                }),
              ),
            ),
            const SizedBox(height: 22),
            Text('CONNECTION', style: bodyFont(fontSize: 11, fontWeight: FontWeight.w800, color: PawColors.charcoal.withValues(alpha: 0.5)).copyWith(letterSpacing: 1.2)),
            const SizedBox(height: 4),
            Text(
              "PawMatch is for dogs and their people — say whether you're open to more than a walk.",
              style: bodyFont(fontSize: 12, color: PawColors.charcoal.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _IntentChoiceChip(label: 'Anyone', selected: selectedIntent == null, onTap: () => setState(() => selectedIntent = null), bodyFont: bodyFont),
                for (final intent in OwnerIntent.values)
                  _IntentChoiceChip(
                    label: '${intent.emoji} ${intent.label}',
                    selected: selectedIntent == intent,
                    onTap: () => setState(() => selectedIntent = intent),
                    bodyFont: bodyFont,
                  ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(selectedPurposes, anyDistance ? null : maxDistance, selectedIntent);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PawColors.mustard,
                  foregroundColor: PawColors.pine,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                child: Text('Show results', style: bodyFont(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntentChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final _FontFn bodyFont;
  const _IntentChoiceChip({required this.label, required this.selected, required this.onTap, required this.bodyFont});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: PawColors.pine,
      labelStyle: bodyFont(fontWeight: FontWeight.w600, color: selected ? Colors.white : PawColors.pine),
      backgroundColor: Colors.white,
      side: BorderSide(color: PawColors.sage.withValues(alpha: 0.5)),
      showCheckmark: false,
    );
  }
}
