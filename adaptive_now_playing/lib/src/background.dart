import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'parallax_controller.dart';
import 'motion_layer.dart';

class AdaptiveNowPlaying extends StatefulWidget {
  final ImageProvider image;
  final Widget child;

  const AdaptiveNowPlaying({
    super.key,
    required this.image,
    required this.child,
  });

  @override
  State<AdaptiveNowPlaying> createState() => _AdaptiveNowPlayingState();
}

class _AdaptiveNowPlayingState extends State<AdaptiveNowPlaying> {
  final controller = ParallaxController();

  Color top = Colors.black;
  Color mid = Colors.black;
  Color bottom = Colors.black;

  @override
  void initState() {
    super.initState();
    controller.start();
    _updatePalette();
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  Future<void> _updatePalette() async {
    final palette = await PaletteGenerator.fromImageProvider(widget.image);

    final dominant = palette.dominantColor?.color ?? Colors.black;
    final vibrant = palette.vibrantColor?.color ?? dominant;

    final hsl = HSLColor.fromColor(dominant);
    top = hsl.withLightness(hsl.lightness * 0.7).toColor();
    mid = vibrant;
    bottom = Color.lerp(mid, Colors.black, 0.75)!;

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [top, mid, bottom],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0, 0.45, 1],
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        /// Background image (deepest layer)
        MotionLayer(
          controller: controller,
          depth: 0.3,
          child: Image(
            image: widget.image,
            fit: BoxFit.cover,
          ),
        ),

        /// Blur layer
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),

        /// Gradient layer (slight motion)
        MotionLayer(
          controller: controller,
          depth: 0.6,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(gradient: gradient),
          ),
        ),

        /// Noise overlay (static)
        Opacity(
          opacity: 0.03,
          child: Image.asset(
            'assets/noise.png',
            repeat: ImageRepeat.repeat,
          ),
        ),

        /// Foreground UI (strongest motion)
        MotionLayer(
          controller: controller,
          depth: 1.2,
          child: widget.child,
        ),
      ],
    );
  }
}