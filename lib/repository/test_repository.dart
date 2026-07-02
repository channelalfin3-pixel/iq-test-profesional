import '../api/api_client.dart';
import '../models/question_model.dart';
import '../models/test_result_model.dart';
import '../utils/session_manager.dart';

class TestRepository {
  final _api = ApiClient.instance;

  Future<String?> _token() => SessionManager.instance.getToken();

  Future<ApiResult> checkPayment() async {
    return _api.post('checkPayment', {'token': await _token()});
  }

  Future<ApiResult> requestPayment() async {
    return _api.post('requestPayment', {'token': await _token()});
  }

  Future<ApiResult> getQuestions() async {
    return _api.post('getQuestions', {'token': await _token()});
  }

  Future<ApiResult> submitAnswers({
    required String sessionId,
    required Map<String, String> answers,
    required int durationSeconds,
  }) async {
    return _api.post('submitAnswers', {
      'token': await _token(),
      'sessionId': sessionId,
      'answers': answers,
      'durationSeconds': durationSeconds,
    });
  }

  Future<ApiResult> getHistory() async {
    return _api.post('getHistory', {'token': await _token()});
  }
}
