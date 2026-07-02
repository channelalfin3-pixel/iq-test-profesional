import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../repository/test_repository.dart';
import '../../models/test_result_model.dart';
import '../../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _repo = TestRepository();
  bool _loading = true;
  String? _error;
  List<HistoryItemModel> _history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _repo.getHistory();
    if (!mounted) return;
    if (result.success) {
      final list = (result.data['history'] as List<dynamic>? ?? [])
          .map((e) => HistoryItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _history = list;
        _loading = false;
      });
    } else {
      setState(() {
        _error = result.message;
        _loading = false;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Tes')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 80),
                      Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Center(child: Text(_error!, textAlign: TextAlign.center)),
                    ],
                  )
                : _history.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          Icon(Icons.history_toggle_off_rounded, size: 56, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Center(child: Text('Belum ada riwayat tes.\nMulai tes pertama Anda sekarang!', textAlign: TextAlign.center)),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final item = _history[index];
                          final color = _categoryColor(item.kategori);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                                    child: Center(
                                      child: Text('${item.iq}', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.kategori, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('dd MMM yyyy, HH:mm').format(item.tanggal),
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Benar ${item.benar} · Salah ${item.salah} · Skor ${item.skor}%',
                                            style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
