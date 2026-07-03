import 'package:flutter/material.dart';

class SummaryChart extends StatelessWidget {
  final double revenue;
  final double expenses;
  const SummaryChart({super.key, required this.revenue, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: _SummaryChartPainter(
          revenue: revenue,
          expenses: expenses,
          revenueColor: Colors.greenAccent.shade400,
          expensesColor: Colors.redAccent.shade100,
          textColor: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white,
        ),
        child: Container(),
      ),
    );
  }
}

class _SummaryChartPainter extends CustomPainter {
  final double revenue;
  final double expenses;
  final Color revenueColor;
  final Color expensesColor;
  final Color textColor;

  _SummaryChartPainter({required this.revenue, required this.expenses, required this.revenueColor, required this.expensesColor, required this.textColor});

  @override
  void paint(Canvas canvas, Size size) {
    final max = [revenue, expenses, 1].reduce((a, b) => a > b ? a : b);
    final barWidth = size.width * 0.18;
    final base = size.height - 34;
    final maxHeight = size.height - 58;
    final paintRevenue = Paint()..color = revenueColor;
    final paintExpenses = Paint()..color = expensesColor;
    final textPainter = TextPainter(textDirection: TextDirection.rtl, textAlign: TextAlign.center);

    void drawBar(double value, double x, Color color, String label) {
      final h = (value / max) * maxHeight;
      final rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, base - h, barWidth, h), const Radius.circular(14));
      canvas.drawRRect(rect, Paint()..color = color.withOpacity(0.9));
      canvas.drawRRect(rect.shift(const Offset(0, -2)), Paint()..color = color.withOpacity(0.35));
      textPainter.text = TextSpan(text: label, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold));
      textPainter.layout(maxWidth: size.width / 2);
      textPainter.paint(canvas, Offset(x + barWidth / 2 - textPainter.width / 2, base + 10));
    }

    final center = size.width / 2;
    drawBar(revenue, center - barWidth - 22, revenueColor, 'الإيرادات');
    drawBar(expenses, center + 22, expensesColor, 'المصاريف');

    final axisPaint = Paint()
      ..color = textColor.withOpacity(0.18)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(12, base), Offset(size.width - 12, base), axisPaint);
  }

  @override
  bool shouldRepaint(covariant _SummaryChartPainter oldDelegate) => oldDelegate.revenue != revenue || oldDelegate.expenses != expenses;
}
