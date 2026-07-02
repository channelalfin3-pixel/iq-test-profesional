import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../test/test_intro_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar'),
        content: const Text('Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Keluar')),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => auth.checkSession(),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.navy,
                    backgroundImage: (user?.foto.isNotEmpty ?? false) ? NetworkImage(user!.foto) : null,
                    child: (user?.foto.isEmpty ?? true)
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Halo,', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        Text(
                          user?.nama ?? '-',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    tooltip: 'Logout',
                    onPressed: () => _confirmLogout(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppTheme.navyGoldGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.emoji_events_outlined, color: AppColors.gold, size: 32),
                    const SizedBox(height: 10),
                    const Text(
                      'Tes IQ Profesional',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ukur kemampuan verbal, numerik, logika, dan visual Anda dalam 40 soal terstruktur.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.15,
                children: [
                  _MenuCard(
                    icon: Icons.play_circle_fill_rounded,
                    label: 'Mulai Tes IQ',
                    color: AppColors.gold,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TestIntroScreen())),
                  ),
                  _MenuCard(
                    icon: Icons.history_rounded,
                    label: 'Riwayat Tes',
                    color: AppColors.navyLight,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
                  ),
                  _MenuCard(
                    icon: Icons.info_outline_rounded,
                    label: 'Tentang Tes',
                    color: AppColors.navyLight,
                    onTap: () => _showAboutSheet(context),
                  ),
                  _MenuCard(
                    icon: Icons.person_outline_rounded,
                    label: 'Profil',
                    color: AppColors.navyLight,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Tentang Tes IQ Profesional', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Tes ini terdiri dari 40 soal mencakup 9 kategori: Verbal, Numerik, Logika, Visual, Analytical, Pattern Recognition, Spatial Reasoning, Critical Thinking, dan Word Analogy. Durasi pengerjaan 45 menit.'),
            SizedBox(height: 12),
            Text(
              'Catatan: Hasil tes ini adalah self-assessment untuk latihan dan hiburan, bukan alat diagnosa psikologi klinis resmi.',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 34),
              const SizedBox(height: 10),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
