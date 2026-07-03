import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import '../models/work_record.dart';
import '../providers/app_provider.dart';
import '../utils/formatters.dart';
import '../widgets/app_drawer.dart';
import '../widgets/premium_card.dart';
import '../widgets/primary_button.dart';

class AddEditRecordScreen extends StatefulWidget {
  static const routeName = '/add';
  static const editRouteName = '/edit';
  final int? recordId;

  const AddEditRecordScreen({super.key, this.recordId});

  @override
  State<AddEditRecordScreen> createState() => _AddEditRecordScreenState();
}

class _AddEditRecordScreenState extends State<AddEditRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _date = TextEditingController();
  final _title = TextEditingController();
  final _revenue = TextEditingController();
  final _fuel = TextEditingController();
  final _garage = TextEditingController();
  final _maintenance = TextEditingController();
  final _other = TextEditingController();
  final _notes = TextEditingController();
  bool _loading = false;
  WorkRecord? _editing;

  bool get _isEdit => widget.recordId != null;

  @override
  void initState() {
    super.initState();
    _date.text = Formatters.date(DateTime.now());
    for (final c in [_revenue, _fuel, _garage, _maintenance, _other]) {
      c.addListener(() => setState(() {}));
    }
    if (_isEdit) _load();
  }

  Future<void> _load() async {
    final record = await DatabaseHelper.instance.getRecordById(widget.recordId!);
    if (record == null || !mounted) return;
    _editing = record;
    _date.text = record.date;
    _title.text = record.title;
    _revenue.text = record.revenue.toString();
    _fuel.text = record.fuel.toString();
    _garage.text = record.garage.toString();
    _maintenance.text = record.maintenance.toString();
    _other.text = record.otherExpenses.toString();
    _notes.text = record.notes;
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in [_date, _title, _revenue, _fuel, _garage, _maintenance, _other, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  double _toDouble(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.').trim()) ?? 0;
  double get _totalExpenses => _toDouble(_fuel) + _toDouble(_garage) + _toDouble(_maintenance) + _toDouble(_other);
  double get _net => _toDouble(_revenue) - _totalExpenses;

  Future<void> _pickDate() async {
    final current = DateTime.tryParse(_date.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('ar', 'EG'),
    );
    if (picked != null) _date.text = Formatters.date(picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final record = WorkRecord.create(
      date: _date.text,
      title: _title.text.trim(),
      revenue: _toDouble(_revenue),
      fuel: _toDouble(_fuel),
      garage: _toDouble(_garage),
      maintenance: _toDouble(_maintenance),
      otherExpenses: _toDouble(_other),
      notes: _notes.text.trim(),
    );
    if (_isEdit && _editing != null) {
      await DatabaseHelper.instance.updateRecord(record.copyWith(id: _editing!.id, createdAt: _editing!.createdAt));
    } else {
      await DatabaseHelper.instance.insertRecord(record);
    }
    if (!mounted) return;
    await context.read<AppProvider>().refreshDashboard();
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEdit ? 'تم تعديل السجل بنجاح' : 'تم حفظ البيانات بنجاح')));
    if (_isEdit) {
      Navigator.pop(context, true);
    } else {
      _formKey.currentState!.reset();
      _date.text = Formatters.date(DateTime.now());
      for (final c in [_title, _revenue, _fuel, _garage, _maintenance, _other, _notes]) {
        c.clear();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'تعديل السجل' : 'إضافة بيانات')),
      drawer: _isEdit ? null : const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          PremiumCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _date,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: const InputDecoration(labelText: 'التاريخ', prefixIcon: Icon(Icons.date_range_rounded)),
                    validator: (v) => (v == null || v.isEmpty) ? 'اختر التاريخ' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'اسم البيان / العملية', prefixIcon: Icon(Icons.edit_note_rounded)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'اكتب اسم البيان' : null,
                  ),
                  const SizedBox(height: 12),
                  _moneyField(_revenue, 'الإيراد', Icons.attach_money_rounded),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _moneyField(_fuel, 'البنزين', Icons.local_gas_station_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: _moneyField(_garage, 'الجراج', Icons.garage_rounded)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _moneyField(_maintenance, 'الصيانة', Icons.build_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: _moneyField(_other, 'أخرى', Icons.receipt_long_rounded)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notes,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'ملاحظات', prefixIcon: Icon(Icons.notes_rounded)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          PremiumCard(
            child: Column(
              children: [
                _calcRow('إجمالي المصاريف', Formatters.money(_totalExpenses), Icons.payments_rounded),
                const Divider(height: 22),
                _calcRow('صافي الربح', Formatters.money(_net), Icons.account_balance_wallet_rounded),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(text: _isEdit ? 'حفظ التعديل' : 'حفظ البيانات', icon: Icons.save_rounded, loading: _loading, onPressed: _save),
        ],
      ),
    );
  }

  Widget _moneyField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }

  Widget _calcRow(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
      ],
    );
  }
}
