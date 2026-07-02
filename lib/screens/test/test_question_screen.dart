import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/test_provider.dart';
import '../../theme/app_theme.dart';
import '../result/result_screen.dart';

class TestQuestionScreen extends StatefulWidget {
  const TestQuestionScreen({super.key});

  @override
  State<TestQuestionScreen> createState() => _TestQuestionScreenState();
}

class _TestQuestionScreenState extends State<TestQuestionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TestProvider>().startTimer(onTimeUp: _autoSubmit);
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _autoSubmit() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Waktu habis! Jawaban Anda otomatis dikirim.'), backgroundColor: AppColors.warning),
    );
    await _submit();
  }

  Future<void> _confirmSubmit() async {
    final provider = context.read<TestProvider>();
    final unanswered = provider.questions.length - provider.answeredCount;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Selesaikan Tes?'),
        content: Text(
          unanswered > 0
              ? 'Anda masih memiliki $unanswered soal yang belum dijawab. Yakin ingin menyelesaikan tes sekarang?'
              : 'Semua soal sudah dijawab. Kirim jawaban Anda sekarang?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Selesaikan')),
        ],
      ),
    );
    if (confirm == true) await _submit();
  }

  Future<void> _submit() async {
    final provider = context.read<TestProvider>();
    final ok = await provider.submitTest();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ResultScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Gagal mengirim jawaban.'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TestProvider>();
    final question = provider.currentQuestion;

    if (question == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isLastQuestion = provider.currentIndex == provider.questions.length - 1;
    final timeIsLow = provider.remainingSeconds <= 60;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Soal ${provider.currentIndex + 1} / ${provider.questions.length}'),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: timeIsLow ? AppColors.danger : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(_formatTime(provider.remainingSeconds), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: provider.progress,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.gold,
              minHeight: 4,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(
                      label: Text(question.kategori, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      backgroundColor: AppColors.navy,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      question.pertanyaan,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    ...question.pilihan.map((opt) {
                      final selected = question.jawabanDipilih == opt.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => context.read<TestProvider>().selectAnswer(question.id, opt.key),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.navy : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: selected ? AppColors.gold : Colors.grey.shade300, width: selected ? 1.6 : 1),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: selected ? AppColors.gold : Colors.grey.shade200,
                                  child: Text(
                                    opt.key,
                                    style: TextStyle(
                                      color: selected ? AppColors.navyDark : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    opt.text,
                                    style: TextStyle(color: selected ? Colors.white : null),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    if (provider.currentIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.read<TestProvider>().previousQuestion(),
                          child: const Text('Sebelumnya'),
                        ),
                      ),
                    if (provider.currentIndex > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isLastQuestion ? _confirmSubmit : () => context.read<TestProvider>().nextQuestion(),
                        child: Text(isLastQuestion ? 'Selesaikan Tes' : 'Selanjutnya'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
