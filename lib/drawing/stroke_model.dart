import 'package:flutter/material.dart';

// S Pen veya dokunma noktasının koordinat ve basınç verisi
class StrokePoint {
  final double x;
  final double y;
  final double pressure;

  StrokePoint({
    required this.x,
    required this.y,
    required this.pressure,
  });
}

// Noktalardan oluşan tek bir çizgi nesnesi
class Stroke {
  final List<StrokePoint> points;
  final Color color;
  final double size;

  Stroke({
    required this.points,
    required this.color,
    required this.size,
  });
}
