import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_models.dart';

class ApiClient {
  const ApiClient({required this.baseUrl, required this.tokenProvider});

  final String baseUrl;
  final Future<String?> Function() tokenProvider;

  Future<List<KanaCharacter>> getKana(String type) async {
    final path = type == 'HIRAGANA' ? '/kana/hiragana' : '/kana/katakana';
    final data = await _getList(path);
    return data.whereType<JsonMap>().map(KanaCharacter.fromJson).toList();
  }

  Future<List<Kotoba>> getKotoba() async {
    final data = await _getList('/kotoba');
    return data.whereType<JsonMap>().map(Kotoba.fromJson).toList();
  }

  Future<HomeCatalog> getHomeCatalog() async {
    final data = await _getMap('/catalog/home');
    return HomeCatalog.fromJson(data);
  }

  Future<List<ProductPackage>> getPackages({String? kind, String? level}) async {
    final data = await _getList(
      '/packages',
      query: {'kind': kind, 'level': level},
    );
    return data.whereType<JsonMap>().map(ProductPackage.fromJson).toList();
  }

  Future<ProductPackage> getMyPackage(String idOrSlug) async {
    final data = await _getMap('/me/packages/$idOrSlug');
    return ProductPackage.fromJson(data);
  }

  Future<List<UserEntitlement>> getMyEntitlements() async {
    final data = await _getList('/me/entitlements');
    return data.whereType<JsonMap>().map(UserEntitlement.fromJson).toList();
  }

  Future<List<LearningProgress>> getMyProgress() async {
    final data = await _getList('/me/progress');
    return data.whereType<JsonMap>().map(LearningProgress.fromJson).toList();
  }

  Future<LearningProgress> upsertProgress({
    required String contentType,
    required String contentId,
    String? packageId,
    int? progressPercent,
    String? status,
    int? score,
    int? bestScore,
    int? attempts,
  }) async {
    final data = await _postMap('/me/progress', {
      'contentType': contentType,
      'contentId': contentId,
      if (packageId != null && packageId.trim().isNotEmpty)
        'packageId': packageId,
      'progressPercent': ?progressPercent,
      'status': ?status,
      'score': ?score,
      'bestScore': ?bestScore,
      'attempts': ?attempts,
    });
    return LearningProgress.fromJson(data);
  }

  Future<ExamSchedule?> getMyExamScheduleSelection() async {
    final data = await _getMap('/me/exam-schedule');
    return ExamScheduleSelection.fromJson(data).schedule;
  }

  Future<ExamSchedule?> selectMyExamSchedule(String examScheduleId) async {
    final data = await _postMap('/me/exam-schedule', {
      'examScheduleId': examScheduleId,
    });
    return ExamScheduleSelection.fromJson(data).schedule;
  }

  Future<void> clearMyExamScheduleSelection() async {
    await _deleteMap('/me/exam-schedule');
  }

  Future<UserProfileDetail> getMyProfile() async {
    final data = await _getMap('/me/profile');
    return UserProfileDetail.fromJson(data);
  }

  Future<UserProfileDetail> updateMyProfile({
    String? displayName,
    String? fullName,
    String? phoneNumber,
    String? addressLine,
    String? city,
    String? province,
    String? postalCode,
    String? country,
  }) async {
    final data = await _patchMap('/me/profile', {
      'displayName': displayName,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'addressLine': addressLine,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'country': country,
    });
    return UserProfileDetail.fromJson(data);
  }

  Future<List<QuestionItem>> getJlptQuestions({String? level}) async {
    final data = await _getList('/jlpt/questions', query: {'level': level});
    return data.whereType<JsonMap>().map(QuestionItem.fromJson).toList();
  }

  Future<List<QuestionSet>> getJlptQuestionSets({String? level}) async {
    final data = await _getList('/jlpt/question-sets', query: {'level': level});
    return data.whereType<JsonMap>().map(QuestionSet.fromJson).toList();
  }

  Future<QuestionSet> getJlptQuestionSet(String id) async {
    final data = await _getMap('/jlpt/question-sets/$id');
    return QuestionSet.fromJson(data);
  }

  Future<QuestionSet> getMyJlptQuestionSet(String id) async {
    final data = await _getMap('/me/jlpt/question-sets/$id');
    return QuestionSet.fromJson(data);
  }

  Future<List<QuestionItem>> getJftQuestions({String? category}) async {
    final data = await _getList(
      '/jft/questions',
      query: {'category': category},
    );
    return data.whereType<JsonMap>().map(QuestionItem.fromJson).toList();
  }

  Future<List<QuestionSet>> getJftQuestionSets({String? category}) async {
    final data = await _getList(
      '/jft/question-sets',
      query: {'category': category},
    );
    return data.whereType<JsonMap>().map(QuestionSet.fromJson).toList();
  }

  Future<QuestionSet> getJftQuestionSet(String id) async {
    final data = await _getMap('/jft/question-sets/$id');
    return QuestionSet.fromJson(data);
  }

  Future<QuestionSet> getMyJftQuestionSet(String id) async {
    final data = await _getMap('/me/jft/question-sets/$id');
    return QuestionSet.fromJson(data);
  }

  Future<List<SswCategory>> getSswCategories() async {
    final data = await _getList('/ssw/categories');
    return data.whereType<JsonMap>().map(SswCategory.fromJson).toList();
  }

  Future<SswModule> getSswModule(String id) async {
    final data = await _getMap('/ssw/modules/$id');
    return SswModule.fromJson(data);
  }

  Future<SswModule> getMySswModule(String id) async {
    final data = await _getMap('/me/ssw/modules/$id');
    return SswModule.fromJson(data);
  }

  Future<StudyMaterial> getStudyMaterial(String idOrSlug) async {
    final data = await _getMap('/study-materials/$idOrSlug');
    return StudyMaterial.fromJson(data);
  }

  Future<StudyMaterial> getMyStudyMaterial(String idOrSlug) async {
    final data = await _getMap('/me/study-materials/$idOrSlug');
    return StudyMaterial.fromJson(data);
  }

  Future<List<ExamSchedule>> getExamSchedules({String? type}) async {
    final data = await _getList('/exam-schedules', query: {'type': type});
    return data.whereType<JsonMap>().map(ExamSchedule.fromJson).toList();
  }

  Future<ExamSchedule> getExamSchedule(String id) async {
    final data = await _getMap('/exam-schedules/$id');
    return ExamSchedule.fromJson(data);
  }

  Future<List<JapanNews>> getJapanNews({String? category}) async {
    final data = await _getList('/japan-news', query: {'category': category});
    return data.whereType<JsonMap>().map(JapanNews.fromJson).toList();
  }

  Future<JapanNews> getJapanNewsDetail(String idOrSlug) async {
    final data = await _getMap('/japan-news/$idOrSlug');
    return JapanNews.fromJson(data);
  }

  Future<OrderSummary> createOrder({
    required List<String> packageIds,
    String? voucherCode,
    int pointsToUse = 0,
  }) async {
    final data = await _postMap('/orders', {
      'packageIds': packageIds,
      if (voucherCode != null && voucherCode.trim().isNotEmpty)
        'voucherCode': voucherCode.trim(),
      if (pointsToUse > 0) 'pointsToUse': pointsToUse,
    });
    return OrderSummary.fromJson(data);
  }

  Future<List<OrderSummary>> getMyOrders() async {
    final data = await _getList('/me/orders');
    return data.whereType<JsonMap>().map(OrderSummary.fromJson).toList();
  }

  Future<OrderSummary> getMyOrder(String id) async {
    final data = await _getMap('/me/orders/$id');
    return OrderSummary.fromJson(data);
  }

  Future<OrderSummary> settleDevPayment(String id) async {
    final data = await _postMap('/me/orders/$id/payments/dev/settle', {});
    return OrderSummary.fromJson(data);
  }

  Future<List<dynamic>> _getList(
    String path, {
    Map<String, String?> query = const {},
  }) async {
    final response = await _get(path, query: query);
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded;
    }
    throw ApiException('Response API bukan list.');
  }

  Future<JsonMap> _getMap(
    String path, {
    Map<String, String?> query = const {},
  }) async {
    final response = await _get(path, query: query);
    final decoded = jsonDecode(response.body);
    if (decoded is JsonMap) {
      return decoded;
    }
    throw ApiException('Response API bukan object.');
  }

  Future<JsonMap> _postMap(String path, JsonMap body) async {
    final response = await _sendJson('POST', path, body);
    final decoded = jsonDecode(response.body);
    if (decoded is JsonMap) {
      return decoded;
    }
    throw ApiException('Response API bukan object.');
  }

  Future<JsonMap> _patchMap(String path, JsonMap body) async {
    final response = await _sendJson('PATCH', path, body);
    final decoded = jsonDecode(response.body);
    if (decoded is JsonMap) {
      return decoded;
    }
    throw ApiException('Response API bukan object.');
  }

  Future<JsonMap> _deleteMap(String path) async {
    final token = await tokenProvider();
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('API error ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is JsonMap) {
      return decoded;
    }
    throw ApiException('Response API bukan object.');
  }

  Future<http.Response> _get(
    String path, {
    Map<String, String?> query = const {},
  }) async {
    final token = await tokenProvider();
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: {
        for (final entry in query.entries)
          if (entry.value != null && entry.value!.isNotEmpty)
            entry.key: entry.value,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('API error ${response.statusCode}: ${response.body}');
    }

    return response;
  }

  Future<http.Response> _sendJson(
    String method,
    String path,
    JsonMap body,
  ) async {
    final token = await tokenProvider();
    final uri = Uri.parse('$baseUrl$path');
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final encoded = jsonEncode(body);

    final response = switch (method) {
      'POST' => await http.post(uri, headers: headers, body: encoded),
      'PATCH' => await http.patch(uri, headers: headers, body: encoded),
      _ => throw ApiException('HTTP method tidak didukung.'),
    };

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('API error ${response.statusCode}: ${response.body}');
    }

    return response;
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
