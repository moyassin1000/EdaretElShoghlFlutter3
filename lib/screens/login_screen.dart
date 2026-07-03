import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../themes/app_theme.dart';
import '../widgets/primary_button.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController(text: 'admin');
  final _password = TextEditingController(text: 'admin123');
  bool _remember = true;
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await context.read<AppProvider>().login(_username.text, _password.text, _remember);
    setState(() => _loading = false);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اسم المستخدم أو كلمة المرور غير صحيحة')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appName = context.watch<AppProvider>().appName;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.premiumBlack, AppTheme.deepNavy], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827).withOpacity(0.92),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppTheme.gold.withOpacity(0.28)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 35, offset: const Offset(0, 18))],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CircleAvatar(radius: 38, backgroundColor: AppTheme.gold, child: Icon(Icons.lock_rounded, color: Colors.white, size: 38)),
                      const SizedBox(height: 18),
                      Text(appName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      const Text('تسجيل الدخول للنظام', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 26),
                      TextFormField(
                        controller: _username,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'اسم المستخدم', prefixIcon: Icon(Icons.person_outline)),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'اكتب اسم المستخدم' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.password_rounded),
                          suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscure = !_obscure)),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'اكتب كلمة المرور' : null,
                        onFieldSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: _remember,
                        onChanged: (v) => setState(() => _remember = v ?? true),
                        title: const Text('تذكرني'),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(text: 'تسجيل الدخول', icon: Icons.login_rounded, loading: _loading, onPressed: _login),
                      const SizedBox(height: 16),
                      const Text('بيانات تجربة: admin / admin123', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
