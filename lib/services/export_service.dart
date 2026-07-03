import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../database/database_helper.dart';
import '../models/work_record.dart';
import '../utils/formatters.dart';

class ExportService {
  Future<File> exportCsv(List<WorkRecord> records, {String filePrefix = 'report'}) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, '${filePrefix}_${DateTime.now().millisecondsSinceEpoch}.csv'));
    final rows = <String>[
      'date,title,revenue,fuel,garage,maintenance,other_expenses,total_expenses,net_profit,notes',
      ...records.map((r) => [
            r.date,
            _escapeCsv(r.title),
            r.revenue,
            r.fuel,
            r.garage,
            r.maintenance,
            r.otherExpenses,
            r.totalExpenses,
            r.netProfit,
            _escapeCsv(r.notes),
          ].join(',')),
    ];
    await file.writeAsString(rows.join('\n'));
    return file;
  }

  Future<File> exportPdf({
    required ReportSummary summary,
    required List<WorkRecord> records,
    required String title,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          pw.Header(level: 0, child: pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _pdfStat('إجمالي الإيرادات', Formatters.money(summary.totalRevenue)),
              _pdfStat('إجمالي المصاريف', Formatters.money(summary.totalExpenses)),
              _pdfStat('صافي الربح', Formatters.money(summary.netProfit)),
              _pdfStat('عدد السجلات', summary.count.toString()),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['التاريخ', 'البيان', 'الإيراد', 'المصاريف', 'الصافي'],
            data: records
                .map((r) => [
                      r.date,
                      r.title,
                      Formatters.money(r.revenue),
                      Formatters.money(r.totalExpenses),
                      Formatters.money(r.netProfit),
                    ])
                .toList(),
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerRight,
            headerAlignment: pw.Alignment.centerRight,
          ),
        ],
      ),
    );
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'report_${DateTime.now().millisecondsSinceEpoch}.pdf'));
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> shareFile(File file, {String? text}) async {
    await Share.shareXFiles([XFile(file.path)], text: text);
  }

  Future<void> shareText(String text) async {
    await Share.share(text);
  }

  pw.Widget _pdfStat(String title, String value) {
    return pw.Container(
      width: 115,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey500),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  String _escapeCsv(String value) {
    final v = value.replaceAll('"', '""');
    return '"$v"';
  }
}
