import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class AdaptiveNowPlayingBackground extends StatefulWidget {
  final ImageProvider image;
  final Widget child;
  final Duration duration;
  final bool useArtworkBlur;

  const AdaptiveNowPlayingBackground({
    super.key,
    required this.image,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.useArtworkBlur = true,
  });

  @override
  State<AdaptiveNowPlayingBackground> createState() =>
      _AdaptiveNowPlayingBackgroundState();
}

class _AdaptiveNowPlayingBackgroundState
    extends State<AdaptiveNowPlayingBackground> {
  Color _top = Colors.black;
  Color _mid = Colors.black;
  Color _bottom = Colors.black;

  @override
  void initState() {
    super.initState();
    _updatePalette();
  }

  @override
  void didUpdateWidget(covariant AdaptiveNowPlayingBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) {
      _updatePalette();
    }
  }

  Future<void> _updatePalette() async {
    final palette = await PaletteGenerator.fromImageProvider(widget.image);

    final dominant = palette.dominantColor?.color ?? Colors.black;
    final vibrant =
        palette.vibrantColor?.color ?? palette.mutedColor?.color ?? dominant;

    Color toneDown(Color c, [double amount = .3]) {
      final hsl = HSLColor.fromColor(c);
      return hsl
          .withSaturation((hsl.saturation * (1 - amount)).clamp(0.0, 1.0))
          .withLightness((hsl.lightness * (1 - amount * 0.6))
              .clamp(0.0, 1.0))
          .toColor();
    }

    Color toneUp(Color c, [double amount = .2]) {
      final hsl = HSLColor.fromColor(c);
      return hsl
          .withSaturation((hsl.saturation * (1 + amount)).clamp(0.0, 1.0))
          .withLightness((hsl.lightness * (1 + amount * 0.3))
              .clamp(0.0, 1.0))
          .toColor();
    }

    final top = toneDown(dominant);
    final mid = toneUp(vibrant);
    final bottom = Color.lerp(mid, Colors.black, 0.75)!;

    if (mounted) {
      setState(() {
        _top = top;
        _mid = mid;
        _bottom = bottom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.0, 0.45, 1.0],
      colors: [_top, _mid, _bottom],
    );

    final brightness =
        ThemeData.estimateBrightnessForColor(_mid);
    final overlayOpacity = brightness == Brightness.light ? 0.4 : 0.25;

    return Stack(
      fit: StackFit.expand,
      children: [
        /// 🎵 Blurred artwork background
        if (widget.useArtworkBlur) ...[
          Image(
            image: widget.image,
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(
              color: Colors.black.withOpacity(overlayOpacity),
            ),
          ),
        ],

        /// 🎨 Animated gradient
        AnimatedContainer(
          duration: widget.duration,
          curve: const Cubic(0.4, 0.0, 0.2, 1.0),
          decoration: BoxDecoration(gradient: gradient),
        ),

        /// 🌫 Layered blur
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(color: Colors.transparent),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(
            color: Colors.black.withOpacity(overlayOpacity),
          ),
        ),

        /// 🌑 Vignette
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.2,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.25),
              ],
            ),
          ),
        ),

        /// 🎞 Noise overlay (add your asset)
        // Opacity(
        //   opacity: 0.03,
        //   child: Image.asset(
        //     'assets/noise.png',
        //     fit: BoxFit.cover,
        //     repeat: ImageRepeat.repeat,
        //   ),
        // ),

        /// 📱 Foreground content
        widget.child,
      ],
    );
  }
}