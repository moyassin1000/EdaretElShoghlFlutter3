import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../themes/app_theme.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.88, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    Timer(const Duration(milliseconds: 2600), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final provider = context.read<AppProvider>();
    final route = provider.isLoggedIn ? DashboardScreen.routeName : LoginScreen.routeName;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appName = context.watch<AppProvider>().appName;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.premiumBlack, AppTheme.deepNavy, Color(0xFF0B1020)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [AppTheme.gold, Color(0xFF8B6B2E)]),
                      boxShadow: [BoxShadow(color: AppTheme.gold.withOpacity(0.28), blurRadius: 42, spreadRadius: 8)],
                    ),
                    child: const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 54),
                  ),
                  const SizedBox(height: 26),
                  Text(appName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const Text('إدارة يومية • تقارير • حفظ محلي', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 34),
                  const SizedBox(width: 42, height: 42, child: CircularProgressIndicator(strokeWidth: 3, color: AppTheme.gold)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
