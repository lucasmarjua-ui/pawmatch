import 'package:flutter/material.dart';
import '../theme/paw_colors.dart';
import 'paw_print_painter.dart';

/// Indicador de carga con la huella de la marca en vez del spinner
/// genérico de Material — pequeño detalle que refuerza la identidad
/// en cada pantalla que carga datos.
class PawLoadingIndicator extends StatefulWidget {
  final double size;
  const PawLoadingIndicator({super.key, this.size = 48});

  @override
  State<PawLoadingIndicator> createState() => _PawLoadingIndicatorState();
}

class _PawLoadingIndicatorState extends State<PawLoadingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.85, end: 1.05).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: PawPrintPainter(color: PawColors.mustard),
      ),
    );
  }
}
