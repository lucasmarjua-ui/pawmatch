import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/paw_colors.dart';
import '../widgets/paw_print_painter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  bool isSignIn = true;
  bool obscurePassword = true;
  String? localError;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordFocus = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  void _switchMode(bool signIn) {
    setState(() {
      isSignIn = signIn;
      localError = null;
    });
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (!_emailRegex.hasMatch(email)) {
      setState(() => localError = 'Enter a valid email address.');
      return;
    }
    if (isSignIn && password.isEmpty) {
      setState(() => localError = 'Enter your password.');
      return;
    }
    if (!isSignIn && password.length < 6) {
      setState(() => localError = 'Password must be at least 6 characters.');
      return;
    }
    setState(() => localError = null);

    if (isSignIn) {
      await auth.signIn(email: email, password: password);
    } else {
      await auth.signUp(email: email, password: password);
    }
    // El error del backend (si lo hay) ya queda expuesto en
    // auth.errorMessage y se pinta en el build de abajo.
  }

  @override
  Widget build(BuildContext context) {
    final displayFont = GoogleFonts.fraunces;
    final bodyFont = GoogleFonts.manrope;
    final auth = context.watch<AuthProvider>();
    final errorMessage = localError ?? auth.errorMessage;

    return Scaffold(
      backgroundColor: PawColors.cream,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabecera con huella de pata
            Container(
              height: 248,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [PawColors.pineLight, PawColors.pine],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomPaint(
                    size: const Size(56, 56),
                    painter: PawPrintPainter(color: PawColors.mustard.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _HeaderFeature(icon: Icons.directions_walk, label: 'Walks'),
                      _HeaderFeature(icon: Icons.sports_baseball_outlined, label: 'Playdates'),
                      _HeaderFeature(icon: Icons.favorite_border, label: 'Breeding'),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(26, 28, 26, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pawmatch',
                    style: displayFont(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: PawColors.pine,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Walks, playdates, and new best friends — for your dog and you.",
                    style: bodyFont(fontSize: 14, color: PawColors.charcoal.withValues(alpha: 0.6)),
                  ),

                  const SizedBox(height: 28),

                  // Toggle Sign in / Sign up
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFE6D6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _ToggleTab(label: 'Sign in', selected: isSignIn, bodyFont: bodyFont, onTap: () => _switchMode(true))),
                        Expanded(child: _ToggleTab(label: 'Sign up', selected: !isSignIn, bodyFont: bodyFont, onTap: () => _switchMode(false))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _FieldLabel(text: 'EMAIL', bodyFont: bodyFont),
                  const SizedBox(height: 6),
                  _AuthField(
                    controller: emailController,
                    hint: 'name@email.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => passwordFocus.requestFocus(),
                  ),

                  const SizedBox(height: 16),

                  _FieldLabel(text: 'PASSWORD', bodyFont: bodyFont),
                  const SizedBox(height: 6),
                  _AuthField(
                    controller: passwordController,
                    focusNode: passwordFocus,
                    hint: '••••••••',
                    obscure: obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: PawColors.charcoal.withValues(alpha: 0.4)),
                      tooltip: obscurePassword ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                    ),
                  ),

                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMessage,
                      style: bodyFont(fontSize: 12.5, color: const Color(0xFFD85A30)),
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
                      onPressed: auth.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PawColors.mustard,
                        foregroundColor: PawColors.pine,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: const StadiumBorder(),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: PawColors.pine),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(14, 14),
                                  painter: PawPrintPainter(color: PawColors.pine),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isSignIn ? 'Sign in' : 'Create account',
                                  style: bodyFont(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: GestureDetector(
                      onTap: () => setState(() => isSignIn = !isSignIn),
                      child: RichText(
                        text: TextSpan(
                          text: isSignIn ? "Don't have an account? " : 'Already have an account? ',
                          style: bodyFont(fontSize: 12, color: PawColors.charcoal.withValues(alpha: 0.55)),
                          children: [
                            TextSpan(
                              text: isSignIn ? 'Sign up' : 'Sign in',
                              style: bodyFont(fontSize: 12, fontWeight: FontWeight.w700, color: PawColors.pine),
                            ),
                          ],
                        ),
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

// Recordatorio, sobre la cabecera, de las tres razones por las que
// alguien está aquí — refuerza que esto es un producto con propósito
// claro, no solo un formulario de login genérico.
class _HeaderFeature extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeaderFeature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: PawColors.mustard),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.85))),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) bodyFont;

  const _ToggleTab({required this.label, required this.selected, required this.onTap, required this.bodyFont});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? PawColors.cream : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: bodyFont(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? PawColors.pine : PawColors.charcoal.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) bodyFont;
  const _FieldLabel({required this.text, required this.bodyFont});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: bodyFont(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: PawColors.charcoal.withValues(alpha: 0.5),
      ).copyWith(letterSpacing: 1.2),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;

  const _AuthField({
    required this.controller,
    required this.hint,
    this.focusNode,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: PawColors.sage.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: PawColors.charcoal.withValues(alpha: 0.3), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          suffixIcon: suffixIcon,
          suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ),
    );
  }
}
