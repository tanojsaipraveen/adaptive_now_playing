import 'package:flutter/material.dart';
import 'parallax_controller.dart';

class MotionLayer extends StatelessWidget {
  final Widget child;
  final ParallaxController controller;
  final double depth;

  const MotionLayer({
    super.key,
    required this.child,
    required this.controller,
    this.depth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final offset = controller.offset;

        return Transform.translate(
          offset: Offset(offset.dx * depth, offset.dy * depth),
          child: child,
        );
      },
    );
  }
}