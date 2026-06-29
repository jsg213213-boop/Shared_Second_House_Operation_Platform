import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_front/core/storage/secure_storage.dart';

class EventService {
  late final Dio _dio;

  // 💡 싱글톤 인스턴스 사용으로 수정
  final _storage = SecureStorage.instance;

  EventService() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      contentType: 'application/json; charset=UTF-8',
    ));

    // 💡 인터셉터 추가: 모든 요청에 토큰 자동 포함
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await _storage.getAccessToken();
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
    ));
  }

  // 행사 관련 API URL
  String get _baseUrl {
    final ip = dotenv.env['BASE_URL'] ?? '10.0.2.2';
    return 'http://$ip:8080/api/events';
  }

  // 행사 목록 조회
  Future<List<dynamic>> getEventList() async {
    try {
      final response = await _dio.get(_baseUrl);
      return response.data as List<dynamic>;
    } catch (e) {
      print("목록 조회 에러: $e");
      return [];
    }
  }

  // 행사 저장 함수
  Future<bool> registerEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: eventData,
      );
      return response.statusCode != null && response.statusCode! < 300;
    } catch (e) {
      print("행사 등록 에러: $e");
      return false;
    }
  }
}