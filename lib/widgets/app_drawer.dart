import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../screens/add_edit_record_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/records_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/settings_screen.dart';
import '../themes/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.deepNavy, AppTheme.gold], begin: Alignment.topRight, end: Alignment.bottomLeft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.directions_car, size: 32, color: Colors.white)),
                  const SizedBox(height: 14),
                  Text(provider.appName, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('إدارة يومية وتقارير محلية', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            _item(context, Icons.dashboard_rounded, 'الرئيسية', () => _go(context, DashboardScreen.routeName)),
            _item(context, Icons.add_circle_outline, 'إضافة بيانات', () => _go(context, AddEditRecordScreen.routeName)),
            _item(context, Icons.table_rows_rounded, 'عرض البيانات', () => _go(context, RecordsScreen.routeName)),
            _item(context, Icons.bar_chart_rounded, 'التقارير', () => _go(context, ReportsScreen.routeName)),
            _item(context, Icons.settings_rounded, 'الإعدادات', () => _go(context, SettingsScreen.routeName)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('يعمل بدون إنترنت • SQLite', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(text), onTap: onTap);
  }

  void _go(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(context, route, route == DashboardScreen.routeName ? (_) => false : ModalRoute.withName(DashboardScreen.routeName));
  }
}
