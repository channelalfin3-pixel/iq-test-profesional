import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import '../models/test_result_model.dart';
import '../repository/test_repository.dart';
import '../config/app_config.dart';

class TestProvider extends ChangeNotifier {
  final _repo = TestRepository();

  bool isLoading = false;
  String? errorMessage;

  String? sessionId;
  List<QuestionModel> questions = [];
  int currentIndex = 0;

  int remainingSeconds = AppConfig.testDurationMinutes * 60;
  Timer? _timer;
  int _elapsedSeconds = 0;

  TestResultModel? lastResult;

  QuestionModel? get currentQuestion => questions.isNotEmpty ? questions[currentIndex] : null;
  int get answeredCount => questions.where((q) => q.jawabanDipilih != null).length;
  double get progress => questions.isEmpty ? 0 : answeredCount / questions.length;

  /// Cek status pembayaran, kembalikan data (paid, price, whatsappNumber, whatsappMessage)
  Future<Map<String, dynamic>?> checkPayment() async {
    isLoading = true;
    notifyListeners();
    final result = await _repo.checkPayment();
    isLoading = false;
    notifyListeners();
    if (result.success) return result.data as Map<String, dynamic>;
    errorMessage = result.message;
    notifyListeners();
    return null;
  }

  Future<bool> requestPayment() async {
    final result = await _repo.requestPayment();
    return result.success;
  }

  /// Muat soal dari server lalu mulai timer
  Future<bool> loadQuestions() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _repo.getQuestions();
    isLoading = false;

    if (!result.success) {
      errorMessage = result.message;
      notifyListeners();
      return false;
    }

    final data = result.data as Map<String, dynamic>;
    sessionId = data['sessionId']?.toString();
    final list = data['questions'] as List<dynamic>? ?? [];
    questions = list.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>)).toList();
    currentIndex = 0;
    remainingSeconds = AppConfig.testDurationMinutes * 60;
    _elapsedSeconds = 0;
    notifyListeners();
    return true;
  }

  void startTimer({required VoidCallback onTimeUp}) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 0) {
        timer.cancel();
        onTimeUp();
        return;
      }
      remainingSeconds -= 1;
      _elapsedSeconds += 1;
      notifyListeners();
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void selectAnswer(String questionId, String optionKey) {
    final q = questions.firstWhere((q) => q.id == questionId);
    q.jawabanDipilih = optionKey;
    notifyListeners();
  }

  void goToQuestion(int index) {
    if (index < 0 || index >= questions.length) return;
    currentIndex = index;
    notifyListeners();
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      currentIndex += 1;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (currentIndex > 0) {
      currentIndex -= 1;
      notifyListeners();
    }
  }

  Future<bool> submitTest() async {
    stopTimer();
    isLoading = true;
    notifyListeners();

    final answers = <String, String>{};
    for (final q in questions) {
      if (q.jawabanDipilih != null) answers[q.id] = q.jawabanDipilih!;
    }

    final result = await _repo.submitAnswers(
      sessionId: sessionId ?? '',
      answers: answers,
      durationSeconds: _elapsedSeconds,
    );

    isLoading = false;
    if (result.success) {
      lastResult = TestResultModel.fromJson(result.data as Map<String, dynamic>);
      notifyListeners();
      return true;
    }
    errorMessage = result.message;
    notifyListeners();
    return false;
  }

  void resetSession() {
    stopTimer();
    sessionId = null;
    questions = [];
    currentIndex = 0;
    lastResult = null;
    errorMessage = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
