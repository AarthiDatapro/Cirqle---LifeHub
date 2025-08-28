    import 'package:flutter/material.dart';
import 'dart:math';

class GeometricBackground extends StatefulWidget {
  final Widget child;
  const GeometricBackground({super.key, required this.child});

  @override
  State<GeometricBackground> createState() => _GeometricBackgroundState();
}

class _GeometricBackgroundState extends State<GeometricBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Shape> _shapes;
  final _rand = Random(42);

  @override
  void initState() {
    super.initState();
    _shapes = List.generate(6, (i) => _Shape.random(_rand, i));
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _GeomPainter(shapes: _shapes, t: _controller.value),
          child: widget.child,
        );
      },
    );
  }
}

class _Shape {
  final Offset center;
  final double radius;
  final Color color;
  final double rotationMax;
  final int sides;

  _Shape({required this.center, required this.radius, required this.color, required this.rotationMax, required this.sides});

  factory _Shape.random(Random r, int i) {
    final center = Offset(r.nextDouble(), r.nextDouble());
    final radius = 0.08 + r.nextDouble() * 0.22;
    final colors = [Color(0x333E8E7E), Color(0x22F2A154), Color(0x22F7E9D7)];
    return _Shape(center: center, radius: radius, color: colors[i % colors.length], rotationMax: r.nextDouble() * pi, sides: 3 + r.nextInt(5));
  }
}

class _GeomPainter extends CustomPainter {
  final List<_Shape> shapes;
  final double t;

  _GeomPainter({required this.shapes, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < shapes.length; i++) {
      final s = shapes[i];
      final cx = s.center.dx * size.width;
      final cy = s.center.dy * size.height;
      final path = Path();
      final angle = t * s.rotationMax + i;
      final r = s.radius * size.width;
      for (int k = 0; k < s.sides; k++) {
        final theta = angle + (2 * pi * k / s.sides);
        final x = cx + r * cos(theta);
        final y = cy + r * sin(theta);
        if (k == 0) path.moveTo(x, y);
        else path.lineTo(x, y);
      }
      path.close();
      final paint = Paint()..color = s.color.withOpacity(0.9 - (0.4 * (t)));
      canvas.drawShadow(path, Colors.black.withOpacity(0.05), 6, true);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GeomPainter old) => old.t != t;
}
