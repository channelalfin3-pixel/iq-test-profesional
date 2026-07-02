import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  bool _codeSent = false;

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.forgotPassword(_emailCtrl.text.trim());
    if (!mounted) return;
    if (ok) {
      setState(() => _codeSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jika email terdaftar, kode reset telah dikirim.'), backgroundColor: AppColors.success),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Gagal mengirim kode.'), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (_tokenCtrl.text.trim().isEmpty || _newPassCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi kode reset dan password baru (min. 6 karakter).'), backgroundColor: AppColors.warning),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.resetPassword(_emailCtrl.text.trim(), _tokenCtrl.text.trim(), _newPassCtrl.text);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil direset. Silakan login.'), backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Gagal reset password.'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _codeSent
                      ? 'Masukkan kode reset yang dikirim ke email Anda, beserta password baru.'
                      : 'Masukkan email terdaftar Anda. Kami akan mengirimkan kode reset password.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Masukkan email yang valid' : null,
                ),
                const SizedBox(height: 16),
                if (!_codeSent)
                  PrimaryButton(label: 'Kirim Kode Reset', onPressed: _sendCode, isLoading: auth.isLoading),
                if (_codeSent) ...[
                  AppTextField(
                    controller: _tokenCtrl,
                    label: 'Kode Reset (dari email)',
                    icon: Icons.vpn_key_outlined,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _newPassCtrl,
                    label: 'Password Baru',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(label: 'Reset Password', onPressed: _resetPassword, isLoading: auth.isLoading),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: _sendCode,
                      child: const Text('Kirim ulang kode'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
