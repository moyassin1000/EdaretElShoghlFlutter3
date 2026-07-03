import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/work_record.dart';
import '../services/export_service.dart';
import '../utils/formatters.dart';
import '../widgets/app_drawer.dart';
import '../widgets/premium_card.dart';
import '../widgets/section_title.dart';
import '../widgets/stat_card.dart';
import '../widgets/summary_chart.dart';

class ReportsScreen extends StatefulWidget {
  static const routeName = '/reports';
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _period = 'month';
  DateTime _anchor = DateTime.now();
  String? _customStart;
  String? _customEnd;
  ReportSummary _summary = ReportSummary.empty();
  List<WorkRecord> _records = [];
  bool _loading = true;
  final _exportService = ExportService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  (String?, String?) _range() {
    final now = _anchor;
    if (_period == 'day') {
      final d = Formatters.date(now);
      return (d, d);
    }
    if (_period == 'month') {
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0);
      return (Formatters.date(start), Formatters.date(end));
    }
    if (_period == 'year') {
      return ('${now.year}-01-01', '${now.year}-12-31');
    }
    return (_customStart, _customEnd);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final range = _range();
    final s = await DatabaseHelper.instance.getSummary(startDate: range.$1, endDate: range.$2);
    final records = await DatabaseHelper.instance.filterRecords(startDate: range.$1, endDate: range.$2);
    if (!mounted) return;
    setState(() {
      _summary = s;
      _records = records;
      _loading = false;
    });
  }

  Future<void> _pickAnchor() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _anchor,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('ar', 'EG'),
    );
    if (picked != null) {
      setState(() => _anchor = picked);
      _load();
    }
  }

  Future<void> _pickCustom(bool start) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('ar', 'EG'),
    );
    if (picked != null) {
      setState(() {
        if (start) {
          _customStart = Formatters.date(picked);
        } else {
          _customEnd = Formatters.date(picked);
        }
      });
      _load();
    }
  }

  Future<void> _exportPdf() async {
    final file = await _exportService.exportPdf(summary: _summary, records: _records, title: 'تقرير إدارة الشغل');
    await _exportService.shareFile(file, text: 'تقرير إدارة الشغل PDF');
  }

  Future<void> _exportCsv() async {
    final file = await _exportService.exportCsv(_records, filePrefix: 'edaret_el_shoghl');
    await _exportService.shareFile(file, text: 'تقرير CSV يفتح في Excel');
  }

  Future<void> _shareSummary() async {
    final text = '''تقرير إدارة الشغل
إجمالي الإيرادات: ${Formatters.money(_summary.totalRevenue)}
إجمالي المصاريف: ${Formatters.money(_summary.totalExpenses)}
صافي الربح: ${Formatters.money(_summary.netProfit)}
عدد السجلات: ${_summary.count}''';
    await _exportService.shareText(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير')),
      drawer: const AppDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                PremiumCard(
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _period,
                        decoration: const InputDecoration(labelText: 'نوع التقرير', prefixIcon: Icon(Icons.tune_rounded)),
                        items: const [
                          DropdownMenuItem(value: 'day', child: Text('يومي')),
                          DropdownMenuItem(value: 'month', child: Text('شهري')),
                          DropdownMenuItem(value: 'year', child: Text('سنوي')),
                          DropdownMenuItem(value: 'custom', child: Text('فترة مخصصة')),
                        ],
                        onChanged: (v) {
                          setState(() => _period = v ?? 'month');
                          _load();
                        },
                      ),
                      const SizedBox(height: 12),
                      if (_period == 'custom')
                        Row(
                          children: [
                            Expanded(child: OutlinedButton.icon(onPressed: () => _pickCustom(true), icon: const Icon(Icons.date_range), label: Text(_customStart ?? 'من'))),
                            const SizedBox(width: 8),
                            Expanded(child: OutlinedButton.icon(onPressed: () => _pickCustom(false), icon: const Icon(Icons.event), label: Text(_customEnd ?? 'إلى'))),
                          ],
                        )
                      else
                        OutlinedButton.icon(onPressed: _pickAnchor, icon: const Icon(Icons.calendar_month), label: Text(Formatters.date(_anchor))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: MediaQuery.sizeOf(context).width > 620 ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.05,
                  children: [
                    StatCard(title: 'إجمالي الإيرادات', value: Formatters.money(_summary.totalRevenue), icon: Icons.trending_up, accent: Colors.greenAccent.shade400),
                    StatCard(title: 'إجمالي المصاريف', value: Formatters.money(_summary.totalExpenses), icon: Icons.payments, accent: Colors.redAccent.shade100),
                    StatCard(title: 'صافي الربح', value: Formatters.money(_summary.netProfit), icon: Icons.account_balance_wallet, accent: Colors.amberAccent.shade100),
                    StatCard(title: 'عدد السجلات', value: _summary.count.toString(), icon: Icons.list_alt, accent: Colors.blueAccent.shade100),
                  ],
                ),
                const SizedBox(height: 16),
                const SectionTitle(title: 'الرسم البياني'),
                PremiumCard(child: SummaryChart(revenue: _summary.totalRevenue, expenses: _summary.totalExpenses)),
                const SizedBox(height: 18),
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(onPressed: _exportPdf, icon: const Icon(Icons.picture_as_pdf), label: const Text('تصدير PDF ومشاركة')),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(onPressed: _exportCsv, icon: const Icon(Icons.table_view), label: const Text('تصدير Excel CSV ومشاركة')),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(onPressed: _shareSummary, icon: const Icon(Icons.share), label: const Text('مشاركة ملخص التقرير')),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
