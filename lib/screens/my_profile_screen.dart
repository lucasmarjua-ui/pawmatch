import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/dog_model.dart';
import '../providers/dog_provider.dart';
import '../providers/match_provider.dart';
import '../theme/paw_colors.dart';
import '../widgets/network_photo.dart';

void _showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('🐾 $feature is coming soon'),
      backgroundColor: PawColors.pine,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

Future<void> _editDogInfo(BuildContext context, Dog dog) async {
  final controller = TextEditingController(text: dog.description);
  var selectedIntent = dog.ownerIntent;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
            decoration: const BoxDecoration(
              color: PawColors.cream,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit ${dog.name}\'s bio', style: GoogleFonts.fraunces(fontSize: 19, fontWeight: FontWeight.w600, color: PawColors.pine)),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  maxLength: 240,
                  style: GoogleFonts.manrope(fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: PawColors.sage.withValues(alpha: 0.5))),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "WHAT ARE YOU LOOKING FOR, AS THE OWNER?",
                  style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: PawColors.charcoal.withValues(alpha: 0.5)).copyWith(letterSpacing: 1.0),
                ),
                const SizedBox(height: 4),
                Text(
                  "This is separate from what ${dog.name} is looking for — it's about you.",
                  style: GoogleFonts.manrope(fontSize: 12, color: PawColors.charcoal.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: OwnerIntent.values.map((intent) {
                    final selected = selectedIntent == intent;
                    return ChoiceChip(
                      label: Text('${intent.emoji} ${intent.label}'),
                      selected: selected,
                      onSelected: (_) => setSheetState(() => selectedIntent = intent),
                      selectedColor: PawColors.pine,
                      labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: selected ? Colors.white : PawColors.pine),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: PawColors.sage.withValues(alpha: 0.5)),
                      showCheckmark: false,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final dogProvider = sheetContext.read<DogProvider>();
                      dogProvider.updateMyDogDescription(controller.text.trim());
                      dogProvider.updateMyDogOwnerIntent(selectedIntent);
                      Navigator.of(sheetContext).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PawColors.mustard,
                      foregroundColor: PawColors.pine,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(),
                    ),
                    child: Text('Save', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class MyProfileScreen extends StatelessWidget {
  final Dog dog;
  final String location;
  final VoidCallback? onSignOut;

  const MyProfileScreen({
    super.key,
    required this.dog,
    required this.location,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final displayFont = GoogleFonts.fraunces;
    final bodyFont = GoogleFonts.manrope;
    final matchCount = context.watch<MatchProvider>().conversations.length;

    return Scaffold(
      backgroundColor: PawColors.cream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 4),
              child: Text('My profile', style: displayFont(fontSize: 22, fontWeight: FontWeight.w600, color: PawColors.pine)),
            ),

            // Tarjeta de resumen del perro
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: PawColors.charcoal.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: NetworkPhoto(url: dog.photoUrl, borderRadius: BorderRadius.circular(20)),
                      ),
                      Positioned(
                        bottom: -4, right: -4,
                        child: Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(color: PawColors.pine, shape: BoxShape.circle, border: Border.all(color: PawColors.cream, width: 2)),
                          child: const Icon(Icons.camera_alt, size: 11, color: PawColors.mustard),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dog.name, style: displayFont(fontSize: 19, fontWeight: FontWeight.w600, color: PawColors.pine)),
                        Text('${dog.breed} · ${(dog.ageInMonths / 12).floor()} yrs', style: bodyFont(fontSize: 13, color: PawColors.charcoal.withValues(alpha: 0.55))),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: dog.ownerIntent == OwnerIntent.datingToo ? PawColors.datingBg : PawColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${dog.ownerIntent.emoji} ${dog.ownerIntent.label}',
                            style: bodyFont(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: dog.ownerIntent == OwnerIntent.datingToo ? PawColors.dating : PawColors.charcoal.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (dog.isLookingForBreeding)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(color: PawColors.successBg, borderRadius: BorderRadius.circular(999)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 6, height: 6, decoration: const BoxDecoration(color: PawColors.success, shape: BoxShape.circle)),
                                const SizedBox(width: 5),
                                Text('Available for breeding', style: bodyFont(fontSize: 11, fontWeight: FontWeight.w600, color: PawColors.successDark)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: _StatsRow(
                bodyFont: bodyFont,
                displayFont: displayFont,
                stats: [
                  _Stat(value: '$matchCount', label: matchCount == 1 ? 'Match' : 'Matches'),
                  _Stat(value: '${dog.purposes.length}', label: 'Goals'),
                  _Stat(value: '${dog.personalityTags.length}', label: 'Traits'),
                ],
              ),
            ),

            _SectionLabel(text: 'DOG PROFILE', bodyFont: bodyFont),
            _SettingsCard(children: [
              _SettingsRow(icon: Icons.edit_outlined, label: 'Edit dog info', bodyFont: bodyFont, onTap: () => _editDogInfo(context, dog)),
              _SettingsRow(icon: Icons.photo_outlined, label: 'Manage photos', bodyFont: bodyFont, onTap: () => _showComingSoon(context, 'Photo management')),
            ]),

            const SizedBox(height: 20),

            _SectionLabel(text: 'ACCOUNT', bodyFont: bodyFont),
            _SettingsCard(children: [
              _SettingsRow(icon: Icons.notifications_outlined, label: 'Notifications', bodyFont: bodyFont, onTap: () => _showComingSoon(context, 'Notification settings')),
              _SettingsRow(icon: Icons.location_on_outlined, label: 'Location', bodyFont: bodyFont, trailing: location, onTap: () => _showComingSoon(context, 'Location settings')),
              _SettingsRow(icon: Icons.logout, label: 'Sign out', bodyFont: bodyFont, isDestructive: true, onTap: onSignOut ?? () {}),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Stat {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});
}

class _StatsRow extends StatelessWidget {
  final List<_Stat> stats;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) bodyFont;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) displayFont;

  const _StatsRow({required this.stats, required this.bodyFont, required this.displayFont});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PawColors.borderMuted),
        boxShadow: [BoxShadow(color: PawColors.charcoal.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: stats
            .map(
              (stat) => Expanded(
                child: Column(
                  children: [
                    Text(stat.value, style: displayFont(fontSize: 20, fontWeight: FontWeight.w600, color: PawColors.pine)),
                    const SizedBox(height: 2),
                    Text(stat.label, style: bodyFont(fontSize: 11.5, color: PawColors.charcoal.withValues(alpha: 0.5))),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) bodyFont;
  const _SectionLabel({required this.text, required this.bodyFont});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
      child: Text(text, style: bodyFont(fontSize: 11, fontWeight: FontWeight.w800, color: PawColors.charcoal.withValues(alpha: 0.5)).copyWith(letterSpacing: 1.2)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PawColors.borderMuted),
        boxShadow: [BoxShadow(color: PawColors.charcoal.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final bool isDestructive;
  final VoidCallback onTap;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) bodyFont;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.bodyFont,
    required this.onTap,
    this.trailing,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? PawColors.danger : PawColors.pine;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: PawColors.surfaceMuted, width: 0.5))),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: bodyFont(fontSize: 14, color: color))),
            if (trailing != null)
              Text(trailing!, style: bodyFont(fontSize: 13, color: PawColors.charcoal.withValues(alpha: 0.5)))
            else if (!isDestructive)
              Icon(Icons.chevron_right, size: 16, color: PawColors.charcoal.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}