import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart' hide StrokePoint;
import 'stroke_model.dart';

// Kalem dokunuşlarını yakalayan ve ekrana çizen tuval widget'ı
class DrawingCanvas extends StatefulWidget {
  final List<Stroke> strokes;
  final Color currentColor;
  final double currentSize;
  final ValueChanged<Stroke> onStrokeAdded;
  final ValueChanged<double> onPressureChanged;

  const DrawingCanvas({
    super.key,
    required this.strokes,
    required this.currentColor,
    required this.currentSize,
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
        color: widget.currentColor,
        size: widget.currentSize,
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
    // Tamamlanmış tüm çizgileri pürüzsüzleştirerek çiz
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, isComplete: true);
    }

    // Halen çizilmekte olan aktif çizgiyi pürüzsüzleştirerek çiz
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!, isComplete: false);
    }
  }

  // perfect_freehand ile basınca duyarlı pürüzsüz dış hat hesaplayıp çiz
  void _drawStroke(Canvas canvas, Stroke stroke, {required bool isComplete}) {
    if (stroke.points.isEmpty) return;

    // StrokePoint listesini PointVector listesine dönüştür
    final inputPoints = stroke.points
        .map((p) => PointVector(p.x, p.y, p.pressure))
        .toList();

    // Pürüzsüz dış hat noktalarını hesapla
    final outlinePoints = getStroke(
      inputPoints,
      options: StrokeOptions(
        size: stroke.size,
        simulatePressure: false,
        isComplete: isComplete,
      ),
    );

    if (outlinePoints.isEmpty) return;

    // Dış hat noktalarını Path nesnesine dönüştür
    final path = Path();
    path.moveTo(outlinePoints.first.dx, outlinePoints.first.dy);
    for (int i = 1; i < outlinePoints.length; i++) {
      path.lineTo(outlinePoints[i].dx, outlinePoints[i].dy);
    }
    path.close();

    final paint = Paint()
      ..color = stroke.color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) {
    return true;
  }
}
