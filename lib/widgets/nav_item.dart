import 'package:flutter/material.dart';
import '../theme/paw_colors.dart';

/// Un icono de la barra de navegación inferior.
class NavItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String label;

  const NavItem({super.key, required this.icon, required this.selected, required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? PawColors.pine.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected ? PawColors.pine : PawColors.iconMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
