import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import '../models/work_record.dart';
import '../providers/app_provider.dart';
import '../utils/formatters.dart';
import '../widgets/app_drawer.dart';
import '../widgets/premium_card.dart';
import 'add_edit_record_screen.dart';
import 'record_details_screen.dart';

class RecordsScreen extends StatefulWidget {
  static const routeName = '/records';
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final _search = TextEditingController();
  List<WorkRecord> _records = [];
  bool _loading = true;
  String? _startDate;
  String? _endDate;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final q = _search.text.trim();
    List<WorkRecord> data;
    if (q.isNotEmpty) {
      data = await DatabaseHelper.instance.searchRecords(q);
    } else {
      data = await DatabaseHelper.instance.filterRecords(startDate: _startDate, endDate: _endDate);
    }
    if (!mounted) return;
    setState(() {
      _records = data;
      _loading = false;
    });
  }

  Future<void> _pickStart() async {
    final d = await _pickDate(_startDate);
    if (d != null) {
      setState(() => _startDate = d);
      _load();
    }
  }

  Future<void> _pickEnd() async {
    final d = await _pickDate(_endDate);
    if (d != null) {
      setState(() => _endDate = d);
      _load();
    }
  }

  Future<String?> _pickDate(String? current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(current ?? '') ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('ar', 'EG'),
    );
    return picked == null ? null : Formatters.date(picked);
  }

  Future<void> _delete(WorkRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف سجل "${record.title}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirm == true && record.id != null) {
      await DatabaseHelper.instance.deleteRecord(record.id!);
      if (!mounted) return;
      await context.read<AppProvider>().refreshDashboard();
      _load();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف السجل')));
    }
  }

  Future<void> _edit(WorkRecord record) async {
    final changed = await Navigator.pushNamed(context, AddEditRecordScreen.editRouteName, arguments: record.id) == true;
    if (changed) _load();
  }

  void _clearFilter() {
    _search.clear();
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عرض البيانات')),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  controller: _search,
                  onChanged: (_) => _load(),
                  decoration: InputDecoration(
                    labelText: 'بحث باسم البيان أو التاريخ',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: _clearFilter, icon: const Icon(Icons.clear_rounded)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: OutlinedButton.icon(onPressed: _pickStart, icon: const Icon(Icons.date_range), label: Text(_startDate ?? 'من تاريخ'))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton.icon(onPressed: _pickEnd, icon: const Icon(Icons.event), label: Text(_endDate ?? 'إلى تاريخ'))),
                    IconButton(onPressed: _clearFilter, icon: const Icon(Icons.filter_alt_off_rounded)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? const Center(child: Text('لا توجد سجلات'))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                          itemCount: _records.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) => _recordCard(_records[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _recordCard(WorkRecord r) {
    return PremiumCard(
      onTap: () => Navigator.pushNamed(context, RecordDetailsScreen.routeName, arguments: r.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(r.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900))),
              PopupMenuButton<String>(
                onSelected: (v) => v == 'edit' ? _edit(r) : _delete(r),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                  const PopupMenuItem(value: 'delete', child: Text('حذف')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(r.date, style: TextStyle(color: Theme.of(context).hintColor)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _mini('الإيراد', Formatters.money(r.revenue)),
              _mini('المصاريف', Formatters.money(r.totalExpenses)),
              _mini('الصافي', Formatters.money(r.netProfit)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mini(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
