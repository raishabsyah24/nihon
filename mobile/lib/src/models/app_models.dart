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

int jsonInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? fallback;
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

class PackageAccess {
  const PackageAccess({
    required this.isFree,
    required this.hasAccess,
    this.lockedQuestionCount = 0,
  });

  final bool isFree;
  final bool hasAccess;
  final int lockedQuestionCount;

  factory PackageAccess.fromJson(dynamic value) {
    if (value is JsonMap) {
      return PackageAccess(
        isFree: value['isFree'] == true,
        hasAccess: value['hasAccess'] == true,
        lockedQuestionCount: jsonInt(value['lockedQuestionCount']),
      );
    }
    return const PackageAccess(isFree: true, hasAccess: true);
  }
}

class ProductPackage {
  const ProductPackage({
    required this.id,
    required this.kind,
    required this.title,
    required this.slug,
    required this.price,
    required this.currency,
    required this.status,
    required this.contents,
    required this.benefits,
    this.subtitle,
    this.previewDescription,
    this.description,
    this.level,
    this.category,
    this.access,
  });

  final String id;
  final String kind;
  final String title;
  final String slug;
  final String? subtitle;
  final String? previewDescription;
  final String? description;
  final String? level;
  final String? category;
  final int price;
  final String currency;
  final String status;
  final List<PackageContent> contents;
  final List<String> benefits;
  final PackageAccess? access;

  bool get hasAccess => access?.hasAccess ?? false;
  bool get isMaterial => kind == 'JFT_MATERIAL' || kind == 'JLPT_MATERIAL';
  bool get isQuestionPackage => kind.endsWith('_QUESTION');

  factory ProductPackage.fromJson(JsonMap json) {
    return ProductPackage(
      id: jsonRequiredString(json['id']),
      kind: jsonRequiredString(json['kind']),
      title: jsonRequiredString(json['title']),
      slug: jsonRequiredString(json['slug']),
      subtitle: jsonString(json['subtitle']),
      previewDescription: jsonString(json['previewDescription']),
      description: jsonString(json['description']),
      level: jsonString(json['level']),
      category: jsonString(json['category']),
      price: jsonInt(json['price']),
      currency: jsonRequiredString(json['currency'], fallback: 'IDR'),
      status: jsonRequiredString(json['status'], fallback: 'DRAFT'),
      contents: jsonMapList(
        json['contents'],
      ).map(PackageContent.fromJson).toList(),
      benefits: jsonStringList(json['benefits']),
      access: json['access'] == null
          ? null
          : PackageAccess.fromJson(json['access']),
    );
  }
}

class PackageContent {
  const PackageContent({
    required this.contentType,
    required this.contentId,
    required this.sortOrder,
    this.title,
  });

  final String contentType;
  final String contentId;
  final String? title;
  final int sortOrder;

  factory PackageContent.fromJson(JsonMap json) {
    return PackageContent(
      contentType: jsonRequiredString(json['contentType']),
      contentId: jsonRequiredString(json['contentId']),
      title: jsonString(json['title']),
      sortOrder: jsonInt(json['sortOrder']),
    );
  }
}

class HomeCatalog {
  const HomeCatalog({required this.freeMenus, required this.paidMenus});

  final List<CatalogMenu> freeMenus;
  final List<CatalogMenu> paidMenus;

  factory HomeCatalog.fromJson(JsonMap json) {
    return HomeCatalog(
      freeMenus: jsonMapList(
        json['freeMenus'],
      ).map(CatalogMenu.fromJson).toList(),
      paidMenus: jsonMapList(
        json['paidMenus'],
      ).map(CatalogMenu.fromJson).toList(),
    );
  }
}

class CatalogMenu {
  const CatalogMenu({
    required this.key,
    required this.title,
    required this.description,
    required this.isFree,
    this.itemCount,
    this.packageCount,
    this.minPrice,
    this.currency = 'IDR',
  });

  final String key;
  final String title;
  final String description;
  final bool isFree;
  final int? itemCount;
  final int? packageCount;
  final int? minPrice;
  final String currency;

  factory CatalogMenu.fromJson(JsonMap json) {
    return CatalogMenu(
      key: jsonRequiredString(json['key']),
      title: jsonRequiredString(json['title']),
      description: jsonRequiredString(json['description'], fallback: ''),
      isFree: json['isFree'] == true,
      itemCount: json['itemCount'] == null ? null : jsonInt(json['itemCount']),
      packageCount: json['packageCount'] == null
          ? null
          : jsonInt(json['packageCount']),
      minPrice: json['minPrice'] == null ? null : jsonInt(json['minPrice']),
      currency: jsonRequiredString(json['currency'], fallback: 'IDR'),
    );
  }
}

class UserEntitlement {
  const UserEntitlement({
    required this.id,
    required this.package,
    this.startsAt,
    this.expiresAt,
  });

  final String id;
  final ProductPackage package;
  final DateTime? startsAt;
  final DateTime? expiresAt;

  factory UserEntitlement.fromJson(JsonMap json) {
    final packageJson = json['package'];
    return UserEntitlement(
      id: jsonRequiredString(json['id']),
      package: packageJson is JsonMap
          ? ProductPackage.fromJson(packageJson)
          : ProductPackage.fromJson(const <String, dynamic>{}),
      startsAt: jsonDate(json['startsAt']),
      expiresAt: jsonDate(json['expiresAt']),
    );
  }
}

class UserProfileDetail {
  const UserProfileDetail({
    required this.id,
    required this.role,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
    this.profile,
    this.loyaltyAccount,
  });

  final String id;
  final String role;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoUrl;
  final UserProfileRecord? profile;
  final LoyaltyAccount? loyaltyAccount;

  String get primaryName =>
      profile?.fullName ??
      displayName ??
      email ??
      phoneNumber ??
      'Pengguna Nihon e Ikitai';

  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  factory UserProfileDetail.fromJson(JsonMap json) {
    final profileJson = json['profile'];
    final loyaltyJson = json['loyaltyAccount'];

    return UserProfileDetail(
      id: jsonRequiredString(json['id']),
      role: jsonRequiredString(json['role'], fallback: 'USER'),
      email: jsonString(json['email']),
      phoneNumber: jsonString(json['phoneNumber']),
      displayName: jsonString(json['displayName']),
      photoUrl: jsonString(json['photoUrl']),
      profile: profileJson is JsonMap
          ? UserProfileRecord.fromJson(profileJson)
          : null,
      loyaltyAccount: loyaltyJson is JsonMap
          ? LoyaltyAccount.fromJson(loyaltyJson)
          : null,
    );
  }
}

class UserProfileRecord {
  const UserProfileRecord({
    this.fullName,
    this.phoneNumber,
    this.addressLine,
    this.city,
    this.province,
    this.postalCode,
    this.country,
    this.birthDate,
  });

  final String? fullName;
  final String? phoneNumber;
  final String? addressLine;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? country;
  final DateTime? birthDate;

  String get addressSummary {
    final parts = [
      addressLine,
      city,
      province,
      postalCode,
      country,
    ].whereType<String>().where((item) => item.trim().isNotEmpty);

    return parts.join(', ');
  }

  factory UserProfileRecord.fromJson(JsonMap json) {
    return UserProfileRecord(
      fullName: jsonString(json['fullName']),
      phoneNumber: jsonString(json['phoneNumber']),
      addressLine: jsonString(json['addressLine']),
      city: jsonString(json['city']),
      province: jsonString(json['province']),
      postalCode: jsonString(json['postalCode']),
      country: jsonString(json['country']),
      birthDate: jsonDate(json['birthDate']),
    );
  }
}

class LoyaltyAccount {
  const LoyaltyAccount({
    required this.pointsBalance,
    required this.lifetimeEarned,
    required this.lifetimeSpent,
  });

  final int pointsBalance;
  final int lifetimeEarned;
  final int lifetimeSpent;

  factory LoyaltyAccount.fromJson(JsonMap json) {
    return LoyaltyAccount(
      pointsBalance: jsonInt(json['pointsBalance']),
      lifetimeEarned: jsonInt(json['lifetimeEarned']),
      lifetimeSpent: jsonInt(json['lifetimeSpent']),
    );
  }
}

class LearningProgress {
  const LearningProgress({
    required this.id,
    required this.contentType,
    required this.contentId,
    required this.status,
    required this.progressPercent,
    this.packageId,
    this.bestScore,
    this.lastAccessedAt,
  });

  final String id;
  final String contentType;
  final String contentId;
  final String? packageId;
  final String status;
  final int progressPercent;
  final int? bestScore;
  final DateTime? lastAccessedAt;

  factory LearningProgress.fromJson(JsonMap json) {
    return LearningProgress(
      id: jsonRequiredString(json['id']),
      contentType: jsonRequiredString(json['contentType']),
      contentId: jsonRequiredString(json['contentId']),
      packageId: jsonString(json['packageId']),
      status: jsonRequiredString(json['status'], fallback: 'NOT_STARTED'),
      progressPercent: jsonInt(json['progressPercent']),
      bestScore: json['bestScore'] == null ? null : jsonInt(json['bestScore']),
      lastAccessedAt: jsonDate(json['lastAccessedAt']),
    );
  }
}

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.subtotal,
    required this.promoDiscount,
    required this.voucherDiscount,
    required this.pointDiscount,
    required this.total,
    required this.currency,
    required this.pointsUsed,
    required this.pointsEarned,
    required this.items,
    this.createdAt,
  });

  final String id;
  final String orderNumber;
  final String status;
  final int subtotal;
  final int promoDiscount;
  final int voucherDiscount;
  final int pointDiscount;
  final int total;
  final String currency;
  final int pointsUsed;
  final int pointsEarned;
  final List<OrderItemSummary> items;
  final DateTime? createdAt;

  factory OrderSummary.fromJson(JsonMap json) {
    return OrderSummary(
      id: jsonRequiredString(json['id']),
      orderNumber: jsonRequiredString(json['orderNumber']),
      status: jsonRequiredString(json['status']),
      subtotal: jsonInt(json['subtotal']),
      promoDiscount: jsonInt(json['promoDiscount']),
      voucherDiscount: jsonInt(json['voucherDiscount']),
      pointDiscount: jsonInt(json['pointDiscount']),
      total: jsonInt(json['total']),
      currency: jsonRequiredString(json['currency'], fallback: 'IDR'),
      pointsUsed: jsonInt(json['pointsUsed']),
      pointsEarned: jsonInt(json['pointsEarned']),
      items: jsonMapList(json['items']).map(OrderItemSummary.fromJson).toList(),
      createdAt: jsonDate(json['createdAt']),
    );
  }
}

class OrderItemSummary {
  const OrderItemSummary({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.package,
  });

  final String id;
  final String title;
  final int price;
  final int quantity;
  final int subtotal;
  final ProductPackage? package;

  factory OrderItemSummary.fromJson(JsonMap json) {
    final packageJson = json['package'];

    return OrderItemSummary(
      id: jsonRequiredString(json['id']),
      title: jsonRequiredString(json['titleSnapshot'], fallback: 'Paket'),
      price: jsonInt(json['price']),
      quantity: jsonInt(json['quantity'], fallback: 1),
      subtotal: jsonInt(json['subtotal']),
      package: packageJson is JsonMap
          ? ProductPackage.fromJson(packageJson)
          : null,
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

class StudyMaterialSection {
  const StudyMaterialSection({this.title, this.body});

  final String? title;
  final String? body;

  factory StudyMaterialSection.fromJson(JsonMap json) {
    return StudyMaterialSection(
      title: jsonString(json['title']),
      body: jsonString(json['body']),
    );
  }
}

class StudyMaterial {
  const StudyMaterial({
    required this.id,
    required this.kind,
    required this.title,
    required this.slug,
    required this.sections,
    required this.vocabulary,
    required this.examples,
    this.level,
    this.category,
    this.summary,
    this.content,
    this.access,
  });

  final String id;
  final String kind;
  final String title;
  final String slug;
  final String? level;
  final String? category;
  final String? summary;
  final String? content;
  final List<StudyMaterialSection> sections;
  final List<JapaneseVocabulary> vocabulary;
  final List<JapaneseExample> examples;
  final PackageAccess? access;

  bool get hasAccess => access?.hasAccess ?? false;

  factory StudyMaterial.fromJson(JsonMap json) {
    return StudyMaterial(
      id: jsonRequiredString(json['id']),
      kind: jsonRequiredString(json['kind']),
      title: jsonRequiredString(json['title']),
      slug: jsonRequiredString(json['slug']),
      level: jsonString(json['level']),
      category: jsonString(json['category']),
      summary: jsonString(json['summary']),
      content: jsonString(json['content']),
      sections: jsonMapList(
        json['sections'],
      ).map(StudyMaterialSection.fromJson).toList(),
      vocabulary: jsonMapList(
        json['vocabulary'],
      ).map(JapaneseVocabulary.fromJson).toList(),
      examples: jsonMapList(
        json['examples'],
      ).map(JapaneseExample.fromJson).toList(),
      access: json['access'] == null
          ? null
          : PackageAccess.fromJson(json['access']),
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

class ExamScheduleSelection {
  const ExamScheduleSelection({this.schedule});

  final ExamSchedule? schedule;

  factory ExamScheduleSelection.fromJson(JsonMap json) {
    final scheduleJson = json['schedule'];
    return ExamScheduleSelection(
      schedule: scheduleJson is JsonMap
          ? ExamSchedule.fromJson(scheduleJson)
          : null,
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
