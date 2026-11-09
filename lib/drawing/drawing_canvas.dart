import 'package:flutter/material.dart';
import 'stroke_model.dart';

// Kalem dokunuşlarını yakalayan ve ekrana çizen tuval widget'ı
class DrawingCanvas extends StatefulWidget {
  final List<Stroke> strokes;
  final ValueChanged<Stroke> onStrokeAdded;
  final ValueChanged<double> onPressureChanged;

  const DrawingCanvas({
    super.key,
    required this.strokes,
    required this.onStrokeAdded,
    required this.onPressureChanged,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  // Çizimi devam eden aktif çizgi
  Stroke? _currentStroke;

  // S Pen basınç değerini oku (0 veya desteklenmiyorsa varsayılan 0.5 al)
  double _getPressure(PointerEvent event) {
    if (event.pressure > 0.0) {
      return event.pressure;
    }
    return 0.5;
  }

  void _onPointerDown(PointerDownEvent event) {
    final pressure = _getPressure(event);
    widget.onPressureChanged(pressure);

    final newPoint = StrokePoint(
      x: event.localPosition.dx,
      y: event.localPosition.dy,
      pressure: pressure,
    );

    setState(() {
      _currentStroke = Stroke(
        points: [newPoint],
        color: Colors.black,
        size: 6.0,
      );
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_currentStroke == null) return;

    final pressure = _getPressure(event);
    widget.onPressureChanged(pressure);

    final newPoint = StrokePoint(
      x: event.localPosition.dx,
      y: event.localPosition.dy,
      pressure: pressure,
    );

    setState(() {
      _currentStroke!.points.add(newPoint);
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_currentStroke != null) {
      widget.onStrokeAdded(_currentStroke!);
      setState(() {
        _currentStroke = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: CustomPaint(
        painter: _CanvasPainter(
          strokes: widget.strokes,
          currentStroke: _currentStroke,
        ),
        size: Size.infinite,
      ),
    );
  }
}

// Çizgileri ekrana basan CustomPainter
class _CanvasPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? currentStroke;

  _CanvasPainter({
    required this.strokes,
    required this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Tamamlanmış tüm çizgileri çiz
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // Halen çizilmekte olan aktif çizgiyi çiz
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  // Noktalar arasına basınca bağlı kalınlık uygulayarak çizgi çiz
  void _drawStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Tek nokta varsa nokta olarak bas
    if (stroke.points.length == 1) {
      final p = stroke.points.first;
      paint.strokeWidth = stroke.size * p.pressure;
      canvas.drawCircle(Offset(p.x, p.y), (stroke.size * p.pressure) / 2, paint);
      return;
    }

    // Ardışık iki nokta arasına çizgi çek
    for (int i = 0; i < stroke.points.length - 1; i++) {
      final p1 = stroke.points[i];
      final p2 = stroke.points[i + 1];

      // İki noktanın ortalama basıncına göre kalınlık hesapla
      final avgPressure = (p1.pressure + p2.pressure) / 2;
      paint.strokeWidth = stroke.size * avgPressure;

      canvas.drawLine(
        Offset(p1.x, p1.y),
        Offset(p2.x, p2.y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) {
    return true;
  }
}
