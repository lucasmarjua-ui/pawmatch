import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dog_model.dart';
import '../theme/paw_colors.dart';
import '../widgets/network_photo.dart';

// Cada MatchPurpose tiene su propio color e icono para que sea
// reconocible de un vistazo tanto aquí como en Discover.
class _PurposeStyle {
  final IconData icon;
  final Color bg;
  final Color fg;
  const _PurposeStyle({required this.icon, required this.bg, required this.fg});
}

const Map<MatchPurpose, _PurposeStyle> _purposeStyles = {
  MatchPurpose.walkingBuddy: _PurposeStyle(icon: Icons.directions_walk, bg: PawColors.successBg, fg: PawColors.successDark),
  MatchPurpose.playdates: _PurposeStyle(icon: Icons.sports_baseball_outlined, bg: PawColors.infoBg, fg: PawColors.info),
  MatchPurpose.breeding: _PurposeStyle(icon: Icons.favorite_border, bg: PawColors.datingBg, fg: PawColors.dating),
};

class DogProfileScreen extends StatelessWidget {
  final Dog dog;

  const DogProfileScreen({super.key, required this.dog});

  @override
  Widget build(BuildContext context) {
    final displayFont = GoogleFonts.fraunces;
    final bodyFont = GoogleFonts.manrope;

    return Scaffold(
      backgroundColor: PawColors.cream,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ClipPath(
              clipper: _WaveClipper(),
              child: SizedBox(
                height: 300,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.15), BlendMode.darken),
                  child: NetworkPhoto(url: dog.photoUrl),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dog.name, style: displayFont(fontSize: 32, fontWeight: FontWeight.w600, color: PawColors.pine, height: 1.0)),
                    const SizedBox(height: 4),
                    Container(width: 40, height: 3, decoration: BoxDecoration(color: PawColors.mustard, borderRadius: BorderRadius.circular(2))),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        _DogTagChip(label: dog.breed, bodyFont: bodyFont),
                        const SizedBox(width: 10),
                        _DogTagChip(label: '${(dog.ageInMonths / 12).floor()} yrs', bodyFont: bodyFont),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Qué busca este perfil — lo más importante para dejar
                    // claro el tipo de conexión antes de que nadie haga match
                    _EyebrowLabel(text: 'LOOKING FOR', bodyFont: bodyFont),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: dog.purposes.map((p) => _PurposeBadge(purpose: p, bodyFont: bodyFont)).toList(),
                    ),

                    if (dog.personalityTags.isNotEmpty) ...[
                      const SizedBox(height: 26),
                      _EyebrowLabel(text: 'PERSONALITY', bodyFont: bodyFont),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: dog.personalityTags.map((tag) => _DogTagChip(label: tag, bodyFont: bodyFont)).toList(),
                      ),
                    ],

                    const SizedBox(height: 26),

                    _EyebrowLabel(text: 'ABOUT', bodyFont: bodyFont),
                    const SizedBox(height: 8),
                    Text(dog.description, style: bodyFont(fontSize: 15.5, height: 1.55, color: PawColors.charcoal.withValues(alpha: 0.78))),

                    const SizedBox(height: 26),

                    // Tarjeta del dueño — con más peso que antes, porque
                    // el objetivo también es que se conozcan las personas
                    _EyebrowLabel(text: 'OWNER', bodyFont: bodyFont),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: PawColors.sage.withValues(alpha: 0.4)),
                        boxShadow: [BoxShadow(color: PawColors.charcoal.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NetworkAvatar(url: dog.ownerPhotoUrl, radius: 26, fallbackInitial: dog.ownerName),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(dog.ownerName, style: bodyFont(fontSize: 15, fontWeight: FontWeight.w700, color: PawColors.pine)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: dog.ownerIntent == OwnerIntent.datingToo ? PawColors.datingBg : PawColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${dog.ownerIntent.emoji} ${dog.ownerIntent.label}',
                                    style: bodyFont(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: dog.ownerIntent == OwnerIntent.datingToo ? PawColors.dating : PawColors.charcoal.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (dog.ownerBio.isNotEmpty)
                                  Text(dog.ownerBio, style: bodyFont(fontSize: 13, color: PawColors.charcoal.withValues(alpha: 0.6)).copyWith(height: 1.4))
                                else
                                  Text("${dog.name}'s owner", style: bodyFont(fontSize: 13, color: PawColors.charcoal.withValues(alpha: 0.4))),
                                if (dog.ownerInterests.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: dog.ownerInterests.map((interest) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: PawColors.cream, borderRadius: BorderRadius.circular(999), border: Border.all(color: PawColors.sage.withValues(alpha: 0.5))),
                                        child: Text(interest, style: bodyFont(fontSize: 10.5, fontWeight: FontWeight.w600, color: PawColors.pine)),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Este perfil es siempre el del propio perro del usuario
                    // (ver MainShell) — no botones de "Pass"/"Match" aquí,
                    // esos son acciones de Discover sobre perfiles ajenos.
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Etiqueta tipo "busca: paseo / quedadas / cría" — cada una con su
// propio color e icono para reconocerla de un vistazo
class _PurposeBadge extends StatelessWidget {
  final MatchPurpose purpose;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) bodyFont;
  const _PurposeBadge({required this.purpose, required this.bodyFont});

  @override
  Widget build(BuildContext context) {
    final style = _purposeStyles[purpose]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: style.bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.fg),
          const SizedBox(width: 6),
          Text(purpose.label, style: bodyFont(fontSize: 12.5, fontWeight: FontWeight.w700, color: style.fg)),
        ],
      ),
    );
  }
}

class _EyebrowLabel extends StatelessWidget {
  final String text;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) bodyFont;
  const _EyebrowLabel({required this.text, required this.bodyFont});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: bodyFont(fontSize: 11.5, fontWeight: FontWeight.w800, color: PawColors.pine.withValues(alpha: 0.5)).copyWith(letterSpacing: 2.2));
  }
}

class _DogTagChip extends StatelessWidget {
  final String label;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) bodyFont;
  const _DogTagChip({required this.label, required this.bodyFont});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: PawColors.sage.withValues(alpha: 0.6))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: PawColors.mustard, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: bodyFont(fontSize: 13, fontWeight: FontWeight.w700, color: PawColors.pine)),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height - 36);
    path.quadraticBezierTo(size.width * 0.25, size.height, size.width * 0.5, size.height - 18);
    path.quadraticBezierTo(size.width * 0.75, size.height - 36, size.width, size.height - 12);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}