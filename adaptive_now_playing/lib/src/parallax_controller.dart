import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ParallaxController extends ChangeNotifier {
  Offset _offset = Offset.zero;
  Offset get offset => _offset;

  StreamSubscription? _sub;

  void start() {
    _sub = gyroscopeEvents.listen((event) {
      final dx = (event.y * 8).clamp(-12, 12);
      final dy = (event.x * 8).clamp(-12, 12);

      // Smooth interpolation (Apple-like inertia)
      _offset = Offset(
        lerpDouble(_offset.dx, dx, 0.1)!,
        lerpDouble(_offset.dy, dy, 0.1)!,
      );

      notifyListeners();
    });
  }

  void stop() {
    _sub?.cancel();
  }
}