import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _agree = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus menyetujui Syarat & Ketentuan.'), backgroundColor: AppColors.warning),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(_namaCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;

    if (ok) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [Icon(Icons.mark_email_read_outlined, color: AppColors.success), SizedBox(width: 8), Text('Registrasi Berhasil')],
          ),
          content: const Text('Kami telah mengirim email verifikasi ke alamat Anda. Silakan cek inbox (atau folder spam) dan klik tautan verifikasi sebelum login.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Kembali ke Login'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Registrasi gagal.'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Akun')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _namaCtrl,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email Aktif',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Masukkan email yang valid' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passCtrl,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) => (v == null || v.length < 6) ? 'Password minimal 6 karakter' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _confirmCtrl,
                  label: 'Konfirmasi Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) => (v != _passCtrl.text) ? 'Konfirmasi password tidak cocok' : null,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _agree,
                      activeColor: AppColors.gold,
                      onChanged: (v) => setState(() => _agree = v ?? false),
                    ),
                    const Expanded(child: Text('Saya menyetujui Syarat & Ketentuan yang berlaku')),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(label: 'Daftar', onPressed: _submit, isLoading: auth.isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
