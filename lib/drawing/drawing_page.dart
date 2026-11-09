import 'package:flutter/material.dart';
import 'drawing_canvas.dart';
import 'drawing_toolbar.dart';
import 'stroke_model.dart';

// Tuval ve arayüzü birleştiren ana çizim ekranı
class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  // Çizgi listesi sayfa durumunda tutulur
  final List<Stroke> _strokes = [];

  // Seçili renk ve kalınlık
  Color _selectedColor = Colors.black;
  double _selectedSize = 6.0;

  // Sağ üstte gösterilecek son okunan basınç değeri
  double _currentPressure = 0.0;

  void _onStrokeAdded(Stroke stroke) {
    setState(() {
      _strokes.add(stroke);
    });
  }

  void _onPressureChanged(double pressure) {
    setState(() {
      _currentPressure = pressure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Çizim tuvali
          Positioned.fill(
            child: DrawingCanvas(
              strokes: _strokes,
              currentColor: _selectedColor,
              currentSize: _selectedSize,
              onStrokeAdded: _onStrokeAdded,
              onPressureChanged: _onPressureChanged,
            ),
          ),
          // Üst araç çubuğu (renk ve kalınlık seçimi)
          Positioned(
            top: 40,
            left: 20,
            child: DrawingToolbar(
              selectedColor: _selectedColor,
              selectedSize: _selectedSize,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              onSizeChanged: (size) {
                setState(() {
                  _selectedSize = size;
                });
              },
            ),
          ),
          // Basınç göstergesi
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Basınç: ${_currentPressure.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
