import 'package:flutter/material.dart';

import '../../../domain/models/inr.dart';

class InrTrendCard extends StatelessWidget {
  const InrTrendCard({required this.records, super.key});

  final List<InrRecord> records;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('INR 双曲线', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              width: double.infinity,
              child: records.isEmpty ? const Center(child: Text('暂无趋势数据')) : CustomPaint(painter: _InrTrendPainter(records)),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                _Legend(color: Color(0xFF2563EB), label: '校正后'),
                SizedBox(width: 16),
                _Legend(color: Color(0xFF94A3B8), label: '原始值'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(Icons.circle, color: color, size: 10), const SizedBox(width: 6), Text(label)]);
  }
}

class _InrTrendPainter extends CustomPainter {
  _InrTrendPainter(this.records);

  final List<InrRecord> records;

  @override
  void paint(Canvas canvas, Size size) {
    final ordered = records.reversed.toList();
    final values = ordered.expand((record) => [record.rawValue, record.correctedValue]).toList();
    final minValue = (values.reduce((a, b) => a < b ? a : b) - 0.2).clamp(0.8, 10.0).toDouble();
    final maxValue = (values.reduce((a, b) => a > b ? a : b) + 0.2).clamp(minValue + 0.4, 10.0).toDouble();

    Offset pointFor(double value, int index) {
      final x = ordered.length == 1 ? size.width / 2 : size.width * index / (ordered.length - 1);
      final normalized = (value - minValue) / (maxValue - minValue);
      return Offset(x, size.height - normalized * size.height);
    }

    void drawLine(List<double> series, Color color) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final path = Path()..moveTo(pointFor(series.first, 0).dx, pointFor(series.first, 0).dy);
      for (var index = 1; index < series.length; index++) {
        final point = pointFor(series[index], index);
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    for (final fraction in [0.25, 0.5, 0.75]) {
      canvas.drawLine(Offset(0, size.height * fraction), Offset(size.width, size.height * fraction), gridPaint);
    }

    drawLine(ordered.map((record) => record.rawValue).toList(), const Color(0xFF94A3B8));
    drawLine(ordered.map((record) => record.correctedValue).toList(), const Color(0xFF2563EB));
  }

  @override
  bool shouldRepaint(covariant _InrTrendPainter oldDelegate) => oldDelegate.records != records;
}
