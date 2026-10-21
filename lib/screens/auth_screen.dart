import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_client.dart';
import 'app_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final api = ApiClient();
  final storage = const FlutterSecureStorage();
  bool restoring = true;
  String? error;

  @override
  void initState() {
    super.initState();
    api.onUnauthorized = () => unawaited(logout());
    restore();
  }

  Future<void> restore() async {
    try {
      final token = await storage.read(key: 'intent_auth_token');
      if (mounted) api.token = token;
    } catch (_) {
      error = 'Không đọc được phiên đăng nhập. Vui lòng đăng nhập lại.';
    }
    if (mounted) setState(() => restoring = false);
  }

  Future<void> login(String email, String password) async {
    final token = await api.login(email, password);
    try {
      await storage.write(key: 'intent_auth_token', value: token);
    } catch (_) {
      throw const ApiException('Không lưu được phiên đăng nhập trên thiết bị.');
    }
    if (mounted) setState(() { api.token = token; error = null; });
  }

  Future<void> logout() async {
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() { api.token = null; error = null; });
    try {
      await storage.delete(key: 'intent_auth_token');
    } catch (_) {
      if (mounted) setState(() => error = 'Không xóa được phiên đã lưu. Vui lòng thử đăng xuất lại sau khi đăng nhập.');
    }
  }

  @override
  void dispose() { api.close(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (restoring) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (api.token == null) return LoginScreen(onLogin: login, notice: error);
    return AppShell(key: ValueKey(api.token), api: api, onLogout: logout);
  }
}

class LoginScreen extends StatefulWidget {
  final Future<void> Function(String, String) onLogin;
  final String? notice;
  const LoginScreen({super.key, required this.onLogin, this.notice});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? error;

  Future<void> submit() async {
    if (busy || !form.currentState!.validate()) return;
    setState(() { busy = true; error = null; });
    try {
      await widget.onLogin(email.text.trim(), password.text);
    } catch (e) {
      if (mounted) setState(() => error = e is ApiException ? e.message : 'Không đăng nhập được. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Center(
    child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460),
      child: ListView(shrinkWrap: true, padding: const EdgeInsets.all(24), children: [
        const Icon(Icons.hub, size: 54, color: Color(0xFF6750A4)),
        const SizedBox(height: 20),
        const Text('Đăng nhập INTENT', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
        const SizedBox(height: 24),
        Form(key: form, child: Column(children: [
          TextFormField(controller: email, enabled: !busy, keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập email' : null),
          const SizedBox(height: 16),
          TextFormField(controller: password, enabled: !busy, obscureText: true,
            decoration: const InputDecoration(labelText: 'Mật khẩu'),
            validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập mật khẩu' : null),
          const SizedBox(height: 16),
          if (error != null || widget.notice != null)
            Text(error ?? widget.notice!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 16),
          FilledButton(onPressed: busy ? null : submit,
            child: Text(busy ? 'Đang đăng nhập...' : 'Đăng nhập')),
        ])),
      ]),
    ),
  )));
}
