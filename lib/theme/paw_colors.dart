import 'package:flutter/material.dart';

/// Paleta compartida por toda la app. Antes cada pantalla definía su
/// propia copia idéntica de esta clase — vive aquí una sola vez.
class PawColors {
  static const cream = Color(0xFFFAF3E8);
  static const pine = Color(0xFF253226);
  static const pineLight = Color(0xFF3D5240);
  static const mustard = Color(0xFFD9A441);
  static const charcoal = Color(0xFF2B2620);
  static const sage = Color(0xFFB9C4AE);

  // Semantic tones — pulled out of individual screens, where the same
  // hex literals used to be copy-pasted per file (chat, matches, dog
  // profile, my profile, onboarding, discover, create-profile).
  static const success = Color(0xFF639922);
  static const successBg = Color(0xFFEAF3DE);
  static const successDark = Color(0xFF3B6D11);
  static const danger = Color(0xFFD85A30);
  static const dating = Color(0xFF993556);
  static const datingBg = Color(0xFFFBEAF0);
  static const info = Color(0xFF185FA5);
  static const infoBg = Color(0xFFE6F1FB);
  static const borderMuted = Color(0xFFE4DBC9);
  static const surfaceMuted = Color(0xFFEFE6D6);
  static const iconMuted = Color(0xFFB0AA97);
  static const photoGradientTop = Color(0xFFFFB74D);
}
