import 'package:flutter/material.dart';

/// Isometric Grid Widget - Creates a Clash of Clans style grid
class IsometricGrid extends StatelessWidget {
  final int gridSize; // e.g., 20x20
  final double cellSize; // Size of each grid cell

  const IsometricGrid({
    super.key,
    required this.gridSize,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: IsometricGridPainter(gridSize: gridSize, cellSize: cellSize),
      size: Size.infinite,
    );
  }
}

class IsometricGridPainter extends CustomPainter {
  final int gridSize;
  final double cellSize;

  IsometricGridPainter({required this.gridSize, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF33691E).withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final halfGridSize = (gridSize * cellSize) / 2;

    // Draw Vertical Lines
    for (int i = 0; i <= gridSize; i++) {
      final x = centerX - halfGridSize + (i * cellSize);
      canvas.drawLine(
        Offset(x, centerY - halfGridSize),
        Offset(x, centerY + halfGridSize),
        paint,
      );
    }

    // Draw Horizontal Lines
    for (int i = 0; i <= gridSize; i++) {
      final y = centerY - halfGridSize + (i * cellSize);
      canvas.drawLine(
        Offset(centerX - halfGridSize, y),
        Offset(centerX + halfGridSize, y),
        paint,
      );
    }

    // Center Crosshair
    final centerPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(centerX - 15, centerY),
      Offset(centerX + 15, centerY),
      centerPaint,
    );
    canvas.drawLine(
      Offset(centerX, centerY - 15),
      Offset(centerX, centerY + 15),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
