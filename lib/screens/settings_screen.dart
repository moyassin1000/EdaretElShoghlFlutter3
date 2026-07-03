import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import '../providers/app_provider.dart';
import '../services/export_service.dart';
import '../utils/app_constants.dart';
import '../widgets/app_drawer.dart';
import '../widgets/premium_card.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _appName = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _exportService = ExportService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appName.text = context.read<AppProvider>().appName;
  }

  @override
  void dispose() {
    _appName.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _saveAppName() async {
    await context.read<AppProvider>().setAppName(_appName.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ اسم التطبيق داخل الواجهة')));
  }

  Future<void> _changePassword() async {
    if (_password.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمة المرور يجب ألا تقل عن 4 أحرف')));
      return;
    }
    if (_password.text != _confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تأكيد كلمة المرور غير مطابق')));
      return;
    }
    await context.read<AppProvider>().changePassword(_password.text);
    _password.clear();
    _confirmPassword.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تغيير كلمة المرور')));
  }

  Future<void> _backup() async {
    final path = await DatabaseHelper.instance.backupDatabase();
    await _exportService.shareFile(File(path), text: 'نسخة احتياطية من بيانات إدارة الشغل');
  }

  Future<void> _restore() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
    final path = picked?.files.single.path;
    if (path == null) return;
    await DatabaseHelper.instance.restoreDatabase(path);
    if (!mounted) return;
    await context.read<AppProvider>().refreshDashboard();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم استرجاع النسخة الاحتياطية')));
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('مسح كل البيانات'),
        content: const Text('هل أنت متأكد؟ لا يمكن التراجع عن هذه العملية إلا إذا كان لديك نسخة احتياطية.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('مسح')),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<AppProvider>().clearAllData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم مسح كل البيانات')));
    }
  }

  Future<void> _logout() async {
    await context.read<AppProvider>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('اسم التطبيق', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                TextField(controller: _appName, decoration: const InputDecoration(prefixIcon: Icon(Icons.drive_file_rename_outline), labelText: 'اسم التطبيق')),
                const SizedBox(height: 12),
                ElevatedButton.icon(onPressed: _saveAppName, icon: const Icon(Icons.save), label: const Text('حفظ الاسم')),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الثيم', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                RadioListTile<String>(value: AppConstants.premiumTheme, groupValue: provider.themeName, onChanged: (v) => provider.setTheme(v!), title: const Text('Premium Mode')),
                RadioListTile<String>(value: AppConstants.darkTheme, groupValue: provider.themeName, onChanged: (v) => provider.setTheme(v!), title: const Text('Dark Mode')),
                RadioListTile<String>(value: AppConstants.lightTheme, groupValue: provider.themeName, onChanged: (v) => provider.setTheme(v!), title: const Text('Light Mode')),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('تغيير كلمة المرور', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                TextField(controller: _password, obscureText: true, decoration: const InputDecoration(prefixIcon: Icon(Icons.lock), labelText: 'كلمة المرور الجديدة')),
                const SizedBox(height: 12),
                TextField(controller: _confirmPassword, obscureText: true, decoration: const InputDecoration(prefixIcon: Icon(Icons.verified_user), labelText: 'تأكيد كلمة المرور')),
                const SizedBox(height: 12),
                ElevatedButton.icon(onPressed: _changePassword, icon: const Icon(Icons.password), label: const Text('تغيير كلمة المرور')),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('البيانات', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                ElevatedButton.icon(onPressed: _backup, icon: const Icon(Icons.backup), label: const Text('نسخ احتياطي ومشاركة')),
                const SizedBox(height: 10),
                OutlinedButton.icon(onPressed: _restore, icon: const Icon(Icons.restore), label: const Text('استرجاع نسخة احتياطية')),
                const SizedBox(height: 10),
                FilledButton.tonalIcon(onPressed: _clearAll, icon: const Icon(Icons.delete_forever), label: const Text('مسح كل البيانات')),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(onPressed: _logout, icon: const Icon(Icons.logout), label: const Text('تسجيل الخروج')),
        ],
      ),
    );
  }
}
