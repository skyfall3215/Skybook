import 'package:flutter/material.dart';

// Renk ve kalınlık seçimlerini barındıran araç çubuğu
class DrawingToolbar extends StatelessWidget {
  final Color selectedColor;
  final double selectedSize;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onSizeChanged;

  const DrawingToolbar({
    super.key,
    required this.selectedColor,
    required this.selectedSize,
    required this.onColorChanged,
    required this.onSizeChanged,
  });

  // Seçilebilir temel renkler
  static const List<Color> _colors = [
    Colors.black,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
  ];

  // Kalınlık seçenekleri: İnce, Orta, Kalın
  static const List<Map<String, dynamic>> _sizes = [
    {'label': 'İnce', 'value': 3.0},
    {'label': 'Orta', 'value': 6.0},
    {'label': 'Kalın', 'value': 12.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Renk butonları
          ..._colors.map((color) {
            final isSelected = selectedColor == color;
            return GestureDetector(
              onTap: () => onColorChanged(color),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
                    width: isSelected ? 3 : 1.5,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 12),
          // Ayraç çizgi
          Container(
            height: 24,
            width: 1,
            color: Colors.grey.shade300,
          ),
          const SizedBox(width: 12),
          // Kalınlık butonları
          ..._sizes.map((item) {
            final sizeVal = item['value'] as double;
            final isSelected = selectedSize == sizeVal;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: ChoiceChip(
                label: Text(item['label'] as String),
                selected: isSelected,
                onSelected: (_) => onSizeChanged(sizeVal),
                visualDensity: VisualDensity.compact,
              ),
            );
          }),
        ],
      ),
    );
  }
}

