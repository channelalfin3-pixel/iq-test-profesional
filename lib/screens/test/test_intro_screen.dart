import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/test_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import 'test_question_screen.dart';

class TestIntroScreen extends StatefulWidget {
  const TestIntroScreen({super.key});

  @override
  State<TestIntroScreen> createState() => _TestIntroScreenState();
}

class _TestIntroScreenState extends State<TestIntroScreen> {
  bool _checking = true;
  bool _paid = false;
  int _price = 0;
  String _waNumber = '';
  String _waMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    setState(() => _checking = true);
    final data = await context.read<TestProvider>().checkPayment();
    if (!mounted) return;
    if (data != null) {
      setState(() {
        _paid = data['paid'] == true;
        _price = data['price'] ?? 0;
        _waNumber = data['whatsappNumber']?.toString() ?? '';
        _waMessage = data['whatsappMessage']?.toString() ?? '';
      });
      // sinkronkan status paid ke AuthProvider agar konsisten di seluruh app
      context.read<AuthProvider>().updatePaidStatus(_paid);
    }
    setState(() => _checking = false);
  }

  Future<void> _openWhatsapp() async {
    await context.read<TestProvider>().requestPayment();
    final uri = Uri.parse('https://wa.me/$_waNumber?text=${Uri.encodeComponent(_waMessage)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp. Pastikan aplikasi terpasang.')),
      );
    }
  }

  Future<void> _startTest() async {
    final ok = await context.read<TestProvider>().loadQuestions();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TestQuestionScreen()),
      );
    } else {
      final err = context.read<TestProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'Gagal memuat soal.'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final testProvider = context.watch<TestProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tes IQ Profesional')),
      body: _checking
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.navyGoldGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Informasi Tes', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          _InfoRow(icon: Icons.quiz_outlined, text: '40 Soal'),
                          _InfoRow(icon: Icons.timer_outlined, text: '45 Menit'),
                          _InfoRow(icon: Icons.category_outlined, text: '9 Kategori (Verbal, Numerik, Logika, dll)'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!_paid) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.lock_outline, color: AppColors.warning),
                                  SizedBox(width: 8),
                                  Text('Pembayaran Diperlukan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Untuk mengikuti Tes IQ Profesional, Anda harus melakukan pembayaran sebesar Rp${_price.toString()}.',
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Setelah menekan tombol di bawah, Anda akan diarahkan ke WhatsApp Admin untuk konfirmasi. Admin akan mengaktifkan akses Anda secara manual.',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              PrimaryButton(label: 'Bayar Sekarang', onPressed: _openWhatsapp, icon: Icons.chat),
                              const SizedBox(height: 8),
                              Center(
                                child: TextButton(
                                  onPressed: _check,
                                  child: const Text('Saya sudah bayar, cek ulang status'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Icon(Icons.check_circle_outline, color: AppColors.success, size: 40),
                              const SizedBox(height: 10),
                              const Text('Akses tes Anda sudah aktif', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              const Text(
                                'Pastikan Anda memiliki waktu 45 menit tanpa gangguan sebelum memulai. Tes tidak dapat dijeda.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              PrimaryButton(
                                label: 'Mulai Tes Sekarang',
                                onPressed: _startTest,
                                isLoading: testProvider.isLoading,
                                icon: Icons.play_arrow_rounded,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}
