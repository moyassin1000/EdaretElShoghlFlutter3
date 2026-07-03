import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import '../models/work_record.dart';
import '../providers/app_provider.dart';
import '../utils/formatters.dart';
import '../widgets/premium_card.dart';
import 'add_edit_record_screen.dart';

class RecordDetailsScreen extends StatefulWidget {
  static const routeName = '/details';
  final int recordId;
  const RecordDetailsScreen({super.key, required this.recordId});

  @override
  State<RecordDetailsScreen> createState() => _RecordDetailsScreenState();
}

class _RecordDetailsScreenState extends State<RecordDetailsScreen> {
  WorkRecord? _record;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await DatabaseHelper.instance.getRecordById(widget.recordId);
    if (!mounted) return;
    setState(() {
      _record = r;
      _loading = false;
    });
  }

  Future<void> _edit() async {
    final changed = await Navigator.pushNamed(context, AddEditRecordScreen.editRouteName, arguments: widget.recordId) == true;
    if (changed) _load();
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تريد حذف هذا السجل نهائيًا؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteRecord(widget.recordId);
      if (!mounted) return;
      await context.read<AppProvider>().refreshDashboard();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _record;
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل السجل')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : r == null
              ? const Center(child: Text('السجل غير موجود'))
              : ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    PremiumCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 8),
                          Text(r.date, style: TextStyle(color: Theme.of(context).hintColor)),
                          const Divider(height: 28),
                          _row('الإيراد', Formatters.money(r.revenue), Icons.trending_up),
                          _row('البنزين', Formatters.money(r.fuel), Icons.local_gas_station),
                          _row('الجراج', Formatters.money(r.garage), Icons.garage),
                          _row('الصيانة', Formatters.money(r.maintenance), Icons.build),
                          _row('مصاريف أخرى', Formatters.money(r.otherExpenses), Icons.receipt_long),
                          const Divider(height: 28),
                          _row('إجمالي المصاريف', Formatters.money(r.totalExpenses), Icons.payments),
                          _row('صافي الربح', Formatters.money(r.netProfit), Icons.account_balance_wallet),
                          const Divider(height: 28),
                          Text('الملاحظات', style: TextStyle(color: Theme.of(context).hintColor)),
                          const SizedBox(height: 8),
                          Text(r.notes.isEmpty ? 'لا توجد ملاحظات' : r.notes),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(child: ElevatedButton.icon(onPressed: _edit, icon: const Icon(Icons.edit), label: const Text('تعديل'))),
                        const SizedBox(width: 10),
                        Expanded(child: FilledButton.tonalIcon(onPressed: _delete, icon: const Icon(Icons.delete), label: const Text('حذف'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text('رجوع')),
                  ],
                ),
    );
  }

  Widget _row(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
