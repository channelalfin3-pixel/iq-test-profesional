import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../providers/test_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../utils/certificate_generator.dart';
import '../home/home_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _generatingCert = false;

  Color _categoryColor(String kategori) {
    switch (kategori) {
      case 'Very Superior':
      case 'Superior':
        return AppColors.success;
      case 'Di atas rata-rata':
      case 'Normal':
        return AppColors.gold;
      default:
        return AppColors.warning;
    }
  }

  Future<void> _downloadCertificate() async {
    final testProvider = context.read<TestProvider>();
    final user = context.read<AuthProvider>().currentUser;
    final result = testProvider.lastResult;
    if (user == null || result == null) return;

    setState(() => _generatingCert = true);
    try {
      await CertificateGenerator.openPreview(user: user, result: result, tanggal: DateTime.now());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat sertifikat: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _generatingCert = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = context.watch<TestProvider>().lastResult;

    if (result == null) {
      return const Scaffold(body: Center(child: Text('Data hasil tidak ditemukan.')));
    }

    final catColor = _categoryColor(result.kategori);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Tes'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.navyGoldGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text('Skor IQ Anda', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 12),
                    CircularPercentIndicator(
                      radius: 70,
                      lineWidth: 12,
                      percent: (result.persentase / 100).clamp(0.0, 1.0),
                      animation: true,
                      animationDuration: 1000,
                      circularStrokeCap: CircularStrokeCap.round,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      progressColor: AppColors.gold,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${result.iq}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          const Text('IQ Score', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(20)),
                      child: Text(result.kategori, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Unduh Sertifikat (PDF)',
                onPressed: _downloadCertificate,
                isLoading: _generatingCert,
                icon: Icons.workspace_premium_outlined,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _StatCard(label: 'Benar', value: '${result.benar}', color: AppColors.success)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Salah', value: '${result.salah}', color: AppColors.danger)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Durasi', value: _formatDuration(result.durasiDetik), color: AppColors.navyLight)),
                ],
              ),
              const SizedBox(height: 20),
              if (result.kekuatan.isNotEmpty)
                _AnalysisCard(
                  title: 'Kekuatan',
                  icon: Icons.trending_up_rounded,
                  color: AppColors.success,
                  items: result.kekuatan,
                ),
              if (result.perluDitingkatkan.isNotEmpty) ...[
                const SizedBox(height: 12),
                _AnalysisCard(
                  title: 'Perlu Ditingkatkan',
                  icon: Icons.trending_down_rounded,
                  color: AppColors.warning,
                  items: result.perluDitingkatkan,
                ),
              ],
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.work_outline_rounded, color: AppColors.navy),
                          SizedBox(width: 8),
                          Text('Rekomendasi Profesi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: result.rekomendasi.map((r) => Chip(label: Text(r))).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Catatan: Hasil ini adalah self-assessment untuk latihan, bukan alat diagnosa psikologi klinis resmi.',
                style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Kembali ke Beranda',
                onPressed: () {
                  context.read<TestProvider>().resetSession();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _AnalysisCard({required this.title, required this.icon, required this.color, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: color), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))]),
            const SizedBox(height: 10),
            ...items.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(children: [Icon(Icons.circle, size: 6, color: color), const SizedBox(width: 8), Text(i)]),
                )),
          ],
        ),
      ),
    );
  }
}
