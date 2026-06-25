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

  Future<List<SswCategory>> getSswCategories() async {
    final data = await _getList('/ssw/categories');
    return data.whereType<JsonMap>().map(SswCategory.fromJson).toList();
  }

  Future<SswModule> getSswModule(String id) async {
    final data = await _getMap('/ssw/modules/$id');
    return SswModule.fromJson(data);
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
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
