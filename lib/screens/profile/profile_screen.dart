import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _namaCtrl;
  final _newPassCtrl = TextEditingController();
  final _picker = ImagePicker();
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _namaCtrl = TextEditingController(text: user?.nama ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 800);
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);
    final bytes = await File(picked.path).readAsBytes();
    final base64Data = base64Encode(bytes);
    final mimeType = picked.mimeType ?? 'image/jpeg';

    final ok = await context.read<AuthProvider>().uploadPhoto(base64Data, mimeType);
    setState(() => _uploadingPhoto = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Foto profil berhasil diperbarui.' : (context.read<AuthProvider>().errorMessage ?? 'Gagal mengunggah foto.')),
        backgroundColor: ok ? AppColors.success : AppColors.danger,
      ),
    );
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthProvider>();
    if (_newPassCtrl.text.isNotEmpty && _newPassCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password baru minimal 6 karakter.'), backgroundColor: AppColors.warning),
      );
      return;
    }

    final ok = await auth.updateProfile(
      nama: _namaCtrl.text.trim(),
      newPassword: _newPassCtrl.text.isEmpty ? null : _newPassCtrl.text,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Profil berhasil diperbarui.' : (auth.errorMessage ?? 'Gagal memperbarui profil.')),
        backgroundColor: ok ? AppColors.success : AppColors.danger,
      ),
    );
    if (ok) _newPassCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.navy,
                    backgroundImage: (user?.foto.isNotEmpty ?? false) ? NetworkImage(user!.foto) : null,
                    child: (user?.foto.isEmpty ?? true) ? const Icon(Icons.person, size: 44, color: Colors.white) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _uploadingPhoto ? null : _pickAndUploadPhoto,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                        child: _uploadingPhoto
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navyDark),
                              )
                            : const Icon(Icons.camera_alt_rounded, size: 18, color: AppColors.navyDark),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppTextField(controller: _namaCtrl, label: 'Nama Lengkap', icon: Icons.person_outline),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: user?.email ?? '',
                enabled: false,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _newPassCtrl,
                label: 'Password Baru (kosongkan jika tidak diubah)',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Simpan Perubahan', onPressed: _saveProfile, isLoading: auth.isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
