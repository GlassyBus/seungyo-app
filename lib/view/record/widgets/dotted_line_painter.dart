// DottedLinePainter.dart
// 이전 응답의 코드를 그대로 사용하시거나, 필요시 dashHeight, dashSpace 값을 조정합니다.
// 예시 (피그마와 유사하게 조정된 값):
import 'package:flutter/material.dart';

class DottedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashHeight;
  final double dashSpace;

  DottedLinePainter({
    this.color = const Color(0xFFE6EAF2), // 피그마 점선 색상
    this.strokeWidth = 1.0,
    this.dashHeight = 3.0, // 점의 길이
    this.dashSpace = 2.5, // 점 사이의 간격
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
