import 'package:flutter/material.dart';
import '../theme/paw_colors.dart';
import 'paw_print_painter.dart';

// Fondo con degradado + huella, usado como placeholder mientras carga
// una foto o cuando no hay ninguna/falla la carga.
class _PawPlaceholder extends StatelessWidget {
  const _PawPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFB74D), PawColors.mustard]),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.biggest.shortestSide * 0.35;
          return Center(child: CustomPaint(size: Size(side, side), painter: PawPrintPainter(color: Colors.white.withValues(alpha: 0.35))));
        },
      ),
    );
  }
}

/// Foto rectangular a pantalla completa (tarjetas de swipe, cabecera de
/// perfil) con estado de carga y fallback si la imagen falla o no hay URL.
class NetworkPhoto extends StatelessWidget {
  final String url;
  final BorderRadius? borderRadius;

  const NetworkPhoto({super.key, required this.url, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final content = url.isEmpty
        ? const _PawPlaceholder()
        : Image.network(
            url,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const _PawPlaceholder();
            },
            errorBuilder: (context, error, stackTrace) => const _PawPlaceholder(),
          );

    if (borderRadius == null) return content;
    return ClipRRect(borderRadius: borderRadius!, child: content);
  }
}

/// Avatar circular con fallback a inicial del nombre si no hay foto o
/// falla la carga — para dueños y perros en listas y tarjetas pequeñas.
class NetworkAvatar extends StatelessWidget {
  final String url;
  final double radius;
  final String fallbackInitial;

  const NetworkAvatar({super.key, required this.url, required this.radius, this.fallbackInitial = '?'});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _initialAvatar();

    return ClipOval(
      child: Image.network(
        url,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _initialAvatar();
        },
        errorBuilder: (context, error, stackTrace) => _initialAvatar(),
      ),
    );
  }

  Widget _initialAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: PawColors.pine,
      child: Text(
        fallbackInitial.isNotEmpty ? fallbackInitial[0].toUpperCase() : '?',
        style: TextStyle(fontSize: radius * 0.6, fontWeight: FontWeight.w700, color: PawColors.mustard),
      ),
    );
  }
}
