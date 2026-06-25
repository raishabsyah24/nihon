typedef JsonMap = Map<String, dynamic>;

String? jsonString(dynamic value) => value?.toString();

String jsonRequiredString(dynamic value, {String fallback = '-'}) {
  final text = jsonString(value);
  return text == null || text.isEmpty ? fallback : text;
}

DateTime? jsonDate(dynamic value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value.toString());
}

List<String> jsonStringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  return const [];
}

List<JsonMap> jsonMapList(dynamic value) {
  if (value is List) {
    return value.whereType<JsonMap>().toList();
  }
  return const [];
}

class AppUser {
  const AppUser({
    required this.id,
    required this.role,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
  });

  final String id;
  final String role;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoUrl;

  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  factory AppUser.fromJson(JsonMap json) {
    return AppUser(
      id: jsonRequiredString(json['id']),
      role: jsonRequiredString(json['role'], fallback: 'USER'),
      email: jsonString(json['email']),
      phoneNumber: jsonString(json['phoneNumber']),
      displayName: jsonString(json['displayName']),
      photoUrl: jsonString(json['photoUrl']),
    );
  }
}

class StrokeStep {
  const StrokeStep({required this.step, required this.note});

  final int step;
  final String note;

  factory StrokeStep.fromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return StrokeStep(
        step: int.tryParse(value['step'].toString()) ?? 1,
        note: jsonRequiredString(
          value['note'],
          fallback: 'Ikuti arah goresan.',
        ),
      );
    }
    return const StrokeStep(step: 1, note: 'Ikuti arah goresan.');
  }
}

class KanaCharacter {
  const KanaCharacter({
    required this.id,
    required this.type,
    required this.character,
    required this.romaji,
    required this.example,
    required this.strokeSteps,
  });

  final String id;
  final String type;
  final String character;
  final String romaji;
  final String example;
  final List<StrokeStep> strokeSteps;

  factory KanaCharacter.fromJson(JsonMap json) {
    final rawSteps = json['strokeOrder'];
    final steps = rawSteps is List
        ? rawSteps.map(StrokeStep.fromJson).toList()
        : <StrokeStep>[
            const StrokeStep(step: 1, note: 'Stroke data belum tersedia.'),
          ];

    return KanaCharacter(
      id: jsonRequiredString(
        json['id'],
        fallback: jsonRequiredString(json['character']),
      ),
      type: jsonRequiredString(json['type']),
      character: jsonRequiredString(json['character']),
      romaji: jsonRequiredString(json['romaji']),
      example: jsonRequiredString(json['example'], fallback: '-'),
      strokeSteps: steps,
    );
  }
}

class Kotoba {
  const Kotoba({
    required this.id,
    required this.kana,
    required this.meaning,
    this.kanji,
    this.furigana,
    this.romaji,
    this.exampleSentence,
  });

  final String id;
  final String? kanji;
  final String kana;
  final String? furigana;
  final String? romaji;
  final String meaning;
  final String? exampleSentence;

  factory Kotoba.fromJson(JsonMap json) {
    return Kotoba(
      id: jsonRequiredString(json['id']),
      kanji: jsonString(json['kanji']),
      kana: jsonRequiredString(json['kana']),
      furigana: jsonString(json['furigana']),
      romaji: jsonString(json['romaji']),
      meaning: jsonRequiredString(json['meaning']),
      exampleSentence: jsonString(json['exampleSentence']),
    );
  }
}

class QuestionItem {
  const QuestionItem({
    required this.id,
    required this.prompt,
    required this.options,
    required this.answerIndex,
    this.level,
    this.category,
    this.explanation,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final int answerIndex;
  final String? level;
  final String? category;
  final String? explanation;

  factory QuestionItem.fromJson(JsonMap json) {
    return QuestionItem(
      id: jsonRequiredString(json['id']),
      prompt: jsonRequiredString(json['prompt']),
      options: jsonStringList(json['options']),
      answerIndex: int.tryParse(json['answerIndex'].toString()) ?? 0,
      level: jsonString(json['level']),
      category: jsonString(json['category']),
      explanation: jsonString(json['explanation']),
    );
  }
}

class QuestionSet {
  const QuestionSet({
    required this.id,
    required this.title,
    required this.questions,
    this.description,
    this.level,
    this.category,
    this.durationMinutes,
    this.questionCount,
  });

  final String id;
  final String title;
  final String? description;
  final String? level;
  final String? category;
  final int? durationMinutes;
  final int? questionCount;
  final List<QuestionItem> questions;

  factory QuestionSet.fromJson(JsonMap json) {
    final count = json['_count'];
    final questions = json['questions'] is List
        ? (json['questions'] as List)
              .whereType<JsonMap>()
              .map(QuestionItem.fromJson)
              .toList()
        : <QuestionItem>[];

    return QuestionSet(
      id: jsonRequiredString(json['id']),
      title: jsonRequiredString(json['title']),
      description: jsonString(json['description']),
      level: jsonString(json['level']),
      category: jsonString(json['category']),
      durationMinutes: int.tryParse(jsonString(json['durationMinutes']) ?? ''),
      questionCount: count is JsonMap
          ? int.tryParse(jsonString(count['questions']) ?? '')
          : null,
      questions: questions,
    );
  }
}

class SswCategory {
  const SswCategory({
    required this.id,
    required this.title,
    required this.modules,
    this.description,
  });

  final String id;
  final String title;
  final String? description;
  final List<SswModule> modules;

  factory SswCategory.fromJson(JsonMap json) {
    final modules = json['modules'] is List
        ? (json['modules'] as List)
              .whereType<JsonMap>()
              .map(SswModule.fromJson)
              .toList()
        : <SswModule>[];

    return SswCategory(
      id: jsonRequiredString(json['id']),
      title: jsonRequiredString(json['title']),
      description: jsonString(json['description']),
      modules: modules,
    );
  }
}

class SswModule {
  const SswModule({
    required this.id,
    required this.title,
    required this.content,
    required this.vocabulary,
    required this.examples,
    required this.questions,
    this.summary,
  });

  final String id;
  final String title;
  final String? summary;
  final String content;
  final List<JapaneseVocabulary> vocabulary;
  final List<JapaneseExample> examples;
  final List<QuestionItem> questions;

  factory SswModule.fromJson(JsonMap json) {
    final questions = json['questions'] is List
        ? (json['questions'] as List)
              .whereType<JsonMap>()
              .map(QuestionItem.fromJson)
              .toList()
        : <QuestionItem>[];

    return SswModule(
      id: jsonRequiredString(json['id']),
      title: jsonRequiredString(json['title']),
      summary: jsonString(json['summary']),
      content: jsonRequiredString(json['content'], fallback: ''),
      vocabulary: jsonMapList(
        json['vocabulary'],
      ).map(JapaneseVocabulary.fromJson).toList(),
      examples: jsonMapList(
        json['examples'],
      ).map(JapaneseExample.fromJson).toList(),
      questions: questions,
    );
  }
}

class JapaneseVocabulary {
  const JapaneseVocabulary({
    this.kanji,
    this.kana,
    this.furigana,
    this.romaji,
    this.meaning,
  });

  final String? kanji;
  final String? kana;
  final String? furigana;
  final String? romaji;
  final String? meaning;

  factory JapaneseVocabulary.fromJson(JsonMap json) {
    return JapaneseVocabulary(
      kanji: jsonString(json['kanji']),
      kana: jsonString(json['kana']),
      furigana: jsonString(json['furigana']),
      romaji: jsonString(json['romaji']),
      meaning: jsonString(json['meaning']),
    );
  }
}

class JapaneseExample {
  const JapaneseExample({
    this.japanese,
    this.furigana,
    this.romaji,
    this.meaning,
  });

  final String? japanese;
  final String? furigana;
  final String? romaji;
  final String? meaning;

  factory JapaneseExample.fromJson(JsonMap json) {
    return JapaneseExample(
      japanese: jsonString(json['japanese']),
      furigana: jsonString(json['furigana']),
      romaji: jsonString(json['romaji']),
      meaning: jsonString(json['meaning']),
    );
  }
}

class ExamSchedule {
  const ExamSchedule({
    required this.id,
    required this.type,
    required this.title,
    required this.startsAt,
    this.location,
    this.endsAt,
    this.registerUrl,
    this.description,
  });

  final String id;
  final String type;
  final String title;
  final DateTime? startsAt;
  final String? location;
  final DateTime? endsAt;
  final String? registerUrl;
  final String? description;

  factory ExamSchedule.fromJson(JsonMap json) {
    return ExamSchedule(
      id: jsonRequiredString(json['id']),
      type: jsonRequiredString(json['type']),
      title: jsonRequiredString(json['title']),
      location: jsonString(json['location']),
      startsAt: jsonDate(json['startsAt']),
      endsAt: jsonDate(json['endsAt']),
      registerUrl: jsonString(json['registerUrl']),
      description: jsonString(json['description']),
    );
  }
}

class JapanNews {
  const JapanNews({
    required this.id,
    required this.title,
    required this.body,
    this.slug,
    this.thumbnail,
    this.category,
    this.publishedAt,
  });

  final String id;
  final String title;
  final String? slug;
  final String? thumbnail;
  final String body;
  final String? category;
  final DateTime? publishedAt;

  factory JapanNews.fromJson(JsonMap json) {
    return JapanNews(
      id: jsonRequiredString(json['id']),
      title: jsonRequiredString(json['title']),
      slug: jsonString(json['slug']),
      thumbnail: jsonString(json['thumbnail']),
      body: jsonRequiredString(json['body'], fallback: ''),
      category: jsonString(json['category']),
      publishedAt: jsonDate(json['publishedAt']),
    );
  }
}
