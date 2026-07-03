import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'database/database_helper.dart';
import 'providers/app_provider.dart';
import 'screens/add_edit_record_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/record_details_screen.dart';
import 'screens/records_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/settings_service.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(
        authService: AuthService(),
        settingsService: SettingsService(),
        databaseHelper: DatabaseHelper.instance,
      )..init(),
      child: const EdaretElShoghlApp(),
    ),
  );
}

class EdaretElShoghlApp extends StatelessWidget {
  const EdaretElShoghlApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        title: provider.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeFromName(provider.themeName),
        locale: const Locale('ar', 'EG'),
        supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child ?? const SizedBox.shrink()),
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (_) => const SplashScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          DashboardScreen.routeName: (_) => const DashboardScreen(),
          AddEditRecordScreen.routeName: (_) => const AddEditRecordScreen(),
          RecordsScreen.routeName: (_) => const RecordsScreen(),
          ReportsScreen.routeName: (_) => const ReportsScreen(),
          SettingsScreen.routeName: (_) => const SettingsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == RecordDetailsScreen.routeName) {
            final id = settings.arguments as int;
            return MaterialPageRoute(builder: (_) => RecordDetailsScreen(recordId: id));
          }
          if (settings.name == AddEditRecordScreen.editRouteName) {
            final id = settings.arguments as int;
            return MaterialPageRoute(builder: (_) => AddEditRecordScreen(recordId: id));
          }
          return null;
        },
      ),
    );
  }
}
